# The song clock interface. The fight code only talks to this, so an audio
# backend (a track's playback position, corrected for output latency) can replace
# the silent one without touching the fight. Subclasses override everything.
#   tick(delta)  called every frame the song should run; a backend that reads a
#                stream's position may ignore it
#   position     seconds into the song
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
