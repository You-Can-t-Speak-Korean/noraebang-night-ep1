# Draws a white 송편 (half-moon rice cake) from shapes: a rounded dome on a
# slightly bulging base, with the pinched seam ticked along the bottom edge.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Control

const FILL_COLOR := Color(0.98, 0.97, 0.94)
const SHADE_COLOR := Color(0.82, 0.8, 0.76)
const OUTLINE_COLOR := Color(0.2, 0.17, 0.16)
const DOME_STEPS := 24
const PLEATS := 6

@export var icon_width := 46.0
@export var icon_height := 26.0

var _shape := PackedVector2Array()


func _ready() -> void:
	_shape = songpyeon_polygon(icon_width, icon_height)
	custom_minimum_size = Vector2(icon_width, icon_height)


## Dome across the top, then back along a base that bulges a little downward.
## Fits the width x height box exactly.
static func songpyeon_polygon(width: float, height: float) -> PackedVector2Array:
	var bulge := height * 0.14
	var dome_h := height - bulge
	var points := PackedVector2Array()
	for i in DOME_STEPS + 1:
		var a := PI * i / DOME_STEPS
		points.append(Vector2(width / 2.0 - cos(a) * width / 2.0, dome_h - sin(a) * dome_h))
	for i in range(DOME_STEPS - 1, 0, -1):
		var t := float(i) / DOME_STEPS
		points.append(Vector2(t * width, dome_h + sin(PI * t) * bulge))
	return points


func _draw() -> void:
	if _shape.is_empty():
		return
	draw_colored_polygon(_shape, FILL_COLOR)
	var bulge := icon_height * 0.14
	var dome_h := icon_height - bulge
	# Seam: short ticks standing on the base edge.
	for i in range(1, PLEATS):
		var t := float(i) / PLEATS
		var base_y := dome_h + sin(PI * t) * bulge
		draw_line(Vector2(t * icon_width, base_y), Vector2(t * icon_width, base_y - icon_height * 0.2), SHADE_COLOR, 2.0, true)
	var closed := _shape.duplicate()
	closed.append(_shape[0])
	draw_polyline(closed, OUTLINE_COLOR, 2.5, true)
