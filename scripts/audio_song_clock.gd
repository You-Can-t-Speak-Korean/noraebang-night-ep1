# The audio song clock: plays the song's track on the Master bus and reads the time from the
# stream's playback position, corrected for the mix buffer and the output latency (the Godot
# audio sync recipe):
#   time = get_playback_position() + AudioServer.get_time_since_last_mix()
#          - AudioServer.get_output_latency() + audio_offset
# never going backwards except on an explicit seek or a restart. Fight mounts it as a child.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name AudioSongClock
extends SongClock

## After a seek the player reports its old position for a moment; the clock then counts the
## ticks itself until the player is within this many seconds of where it was sent.
const SETTLE_TOLERANCE := 0.3
const SETTLE_GIVE_UP := 1.0

var player: AudioStreamPlayer
var offset := 0.0

var _last := -INF
var _held := 0.0
var _paused := true
var _ended := false
var _settling := false
var _settle_target := 0.0
var _settle_elapsed := 0.0


func _init(stream: AudioStream = null, audio_offset := 0.0) -> void:
	offset = audio_offset
	player = AudioStreamPlayer.new()
	player.name = "SongAudio"
	player.bus = "Master"
	player.stream = stream
	player.finished.connect(_on_stream_finished)


## The clock's time for these readings (a pure function, so the maths is testable).
static func compute_time(playback_position: float, since_last_mix: float, output_latency: float, audio_offset: float) -> float:
	return playback_position + since_last_mix - output_latency + audio_offset


## `candidate`, but never earlier than `last` (the clock only goes forward between seeks).
static func never_backwards(candidate: float, last: float) -> float:
	return maxf(candidate, last)


## Audio is used only when the song names a track, the tuning allows it, and this is a
## real run: not --no-audio, not --fight-auto, not a --capture* mode, not a script run
## (the tests), and a real display driver (not "headless").
static func should_use(song: Dictionary, tuning_audio: bool, user_args: PackedStringArray, display_driver: String, engine_args: PackedStringArray = PackedStringArray()) -> bool:
	if str(song.get("audio", "")) == "" or not tuning_audio or display_driver == "headless":
		return false
	if engine_args.has("-s") or engine_args.has("--script"):
		return false
	for a in user_args:
		if a == "--no-audio" or a == "--fight-auto" or a.begins_with("--capture"):
			return false
	return true


## The clock for `song`, or null (with a warning) when its track will not load.
static func create(song: Dictionary, audio_offset: float) -> AudioSongClock:
	var path := str(song.get("audio", ""))
	var stream = load(path) if ResourceLoader.exists(path) else null
	if not stream is AudioStream:
		push_warning("AudioSongClock: %s will not load; using the silent clock" % path)
		return null
	return AudioSongClock.new(stream, audio_offset)


func stops_at_length() -> bool:
	return false


## The stream ran out: the clock holds at the end of the track and nothing else happens.
func _on_stream_finished() -> void:
	if _paused:
		return
	_held = maxf(_last, _held)
	_ended = true
	_paused = true


func mount(host: Node) -> void:
	if player.get_parent() == null:
		host.add_child(player)


func has_audio() -> bool:
	return true


func play() -> void:
	_last = -INF
	_held = 0.0
	_paused = false
	_settling = false
	_ended = false
	player.stream_paused = false
	player.play(0.0)


func pause() -> void:
	if _paused:
		return
	_held = get_position()
	_settle_elapsed = 0.0
	_paused = true
	player.stream_paused = true


func hold_at(_seconds: float) -> void:
	pause()


func resume() -> void:
	if not _paused or _ended:
		return
	_paused = false
	player.stream_paused = false


func stop() -> void:
	_paused = true
	_ended = false
	player.stop()


func seek(seconds: float) -> void:
	var t := maxf(seconds, 0.0)
	_last = -INF
	_held = t
	_settle_target = maxf(t - offset, 0.0)
	_settle_elapsed = 0.0
	_settling = true
	if not player.playing:
		player.play(_settle_target)
		player.stream_paused = _paused
	else:
		player.seek(_settle_target)


func tick(delta: float) -> void:
	if _settling and not _paused:
		_settle_elapsed += delta


func get_position() -> float:
	if _paused:
		return _held
	var raw := player.get_playback_position()
	if _settling:
		if absf(raw - _settle_target) <= SETTLE_TOLERANCE or _settle_elapsed >= SETTLE_GIVE_UP:
			_settling = false
		else:
			return _held + _settle_elapsed
	var t := compute_time(raw, AudioServer.get_time_since_last_mix(), AudioServer.get_output_latency(), offset)
	_last = never_backwards(t, _last)
	return maxf(_last, 0.0)


func is_playing() -> bool:
	return player.playing and not _paused
