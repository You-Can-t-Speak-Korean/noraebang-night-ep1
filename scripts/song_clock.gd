# The song clock interface. The fight code only talks to this, so an audio
# backend (a track's playback position, corrected for output latency) can replace
# the silent one without touching the fight. Subclasses override everything.
#   tick(delta)  called every frame the song should run; a backend that reads a
#                stream's position may ignore it
#   position     seconds into the song
#   hold_at/stop/mount/has_audio  have working defaults; an audio backend overrides them
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongClock
extends RefCounted


func play() -> void:
	push_error("SongClock.play: not implemented")


func pause() -> void:
	push_error("SongClock.pause: not implemented")


func resume() -> void:
	push_error("SongClock.resume: not implemented")


func seek(_seconds: float) -> void:
	push_error("SongClock.seek: not implemented")


func tick(_delta: float) -> void:
	push_error("SongClock.tick: not implemented")


func get_position() -> float:
	push_error("SongClock.get_position: not implemented")
	return 0.0


func is_playing() -> bool:
	push_error("SongClock.is_playing: not implemented")
	return false


## Gives a backend that needs nodes (an audio player) a place in the tree. Default: nothing.
func mount(_host: Node) -> void:
	pass


## True when this backend makes sound (so sound effects may play too).
func has_audio() -> bool:
	return false


## Ends the song for good (the game over, the fight freed). Default: a pause.
func stop() -> void:
	pause()


## True when the song's `length` ends the clock (the silent clock). An audio backend runs
## to the end of its stream instead, whatever the song's length says.
func stops_at_length() -> bool:
	return true


## Pauses with the song at `seconds` (a freeze at a blank). Default: seek there and pause; an
## audio backend only pauses, so the track does not seek (and stutter) at every freeze.
func hold_at(seconds: float) -> void:
	seek(seconds)
	pause()
