# The no-audio song clock: position advances by the deltas it is ticked with
# while playing, and holds still while paused.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SilentSongClock
extends SongClock

var _position := 0.0
var _playing := false


func play() -> void:
	_position = 0.0
	_playing = true


func pause() -> void:
	_playing = false


func resume() -> void:
	_playing = true


func seek(seconds: float) -> void:
	_position = maxf(seconds, 0.0)


func tick(delta: float) -> void:
	if _playing:
		_position += delta


func get_position() -> float:
	return _position


func is_playing() -> bool:
	return _playing
