# A small padlock drawn from shapes, for the "secret lost" cue.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Control

const BODY_COLOR := Color(0.95, 0.8, 0.3)
const OUTLINE_COLOR := Color(0.1, 0.07, 0.02)


func _ready() -> void:
	custom_minimum_size = Vector2(26, 32)


func _draw() -> void:
	var shackle := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		shackle.append(Vector2(13.0 + cos(a) * 7.0, 12.0 + sin(a) * 9.0))
	draw_polyline(shackle, OUTLINE_COLOR, 6.0, true)
	draw_polyline(shackle, BODY_COLOR, 3.0, true)
	draw_rect(Rect2(2, 12, 22, 18), OUTLINE_COLOR)
	draw_rect(Rect2(4, 14, 18, 14), BODY_COLOR)
	draw_circle(Vector2(13, 21), 2.5, OUTLINE_COLOR)
