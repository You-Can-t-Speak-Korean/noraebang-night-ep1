# Draws the 눈치 row from shapes: one squinting eye per point of the cap, bright
# and filled when held, dim and outlined when empty. The iris sits to the right.
# No number and no image files.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Control

const WHITE_COLOR := Color(0.96, 0.94, 0.88)
const IRIS_COLOR := Color(0.55, 0.32, 0.1)
const PUPIL_COLOR := Color(0.05, 0.03, 0.03)
const HELD_OUTLINE := Color(0.05, 0.03, 0.03)
const EMPTY_FILL := Color(0.12, 0.1, 0.1, 0.55)
const EMPTY_OUTLINE := Color(0.62, 0.6, 0.58, 0.7)
const EMPTY_IRIS := Color(0.45, 0.43, 0.42, 0.35)
const EYE_STEPS := 16
const IRIS_STEPS := 20
## Where the iris sits along the eye (0 = left corner, 1 = right corner).
const IRIS_AT := 0.68

@export var eye_width := 38.0
@export var eye_height := 22.0
@export var gap := 8.0

var held := 0
var cap := 7

var _eye := PackedVector2Array()
var _iris := PackedVector2Array()
var _pupil := PackedVector2Array()


func _ready() -> void:
	add_to_group("nunchi_display")  # the fight's click-to-cross-out looks the eyes up here
	_eye = eye_polygon(eye_width, eye_height)
	var iris_r := eye_height * 0.36
	var center := Vector2(eye_width * IRIS_AT, eye_height / 2.0)
	# Clipped to the lid line, so a squint hides the top and bottom of the iris.
	var clipped := Geometry2D.intersect_polygons(_eye, circle_polygon(center, iris_r))
	_iris = clipped[0] if not clipped.is_empty() else PackedVector2Array()
	_pupil = circle_polygon(center, iris_r * 0.45)
	_update_size()


func set_nunchi(new_held: int, new_cap: int) -> void:
	held = new_held
	cap = new_cap
	_update_size()
	queue_redraw()


## True for the eyes that are filled: the first `held_count` from the left.
static func eye_held(index: int, held_count: int) -> bool:
	return index < held_count


## An almond: pointed at both corners, flat enough to look squinted.
static func eye_polygon(width: float, height: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in EYE_STEPS + 1:
		var t := float(i) / EYE_STEPS
		var lid := 1.0 - pow(2.0 * t - 1.0, 2.0)
		points.append(Vector2(t * width, height / 2.0 - lid * height / 2.0))
	for i in range(EYE_STEPS - 1, 0, -1):
		var t := float(i) / EYE_STEPS
		var lid := 1.0 - pow(2.0 * t - 1.0, 2.0)
		points.append(Vector2(t * width, height / 2.0 + lid * height / 2.0))
	return points


static func circle_polygon(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in IRIS_STEPS:
		var a := TAU * i / IRIS_STEPS
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	return points


func _update_size() -> void:
	custom_minimum_size = Vector2(cap * (eye_width + gap) - gap, eye_height)


func _draw() -> void:
	if _eye.is_empty():
		return
	for i in cap:
		draw_set_transform(Vector2(i * (eye_width + gap), 0))
		if eye_held(i, held):
			draw_colored_polygon(_eye, WHITE_COLOR)
			if not _iris.is_empty():
				draw_colored_polygon(_iris, IRIS_COLOR)
				draw_colored_polygon(_pupil, PUPIL_COLOR)
			draw_polyline(_closed(_eye), HELD_OUTLINE, 2.5, true)
		else:
			draw_colored_polygon(_eye, EMPTY_FILL)
			if not _iris.is_empty():
				draw_colored_polygon(_iris, EMPTY_IRIS)
			draw_polyline(_closed(_eye), EMPTY_OUTLINE, 2.0, true)
	draw_set_transform(Vector2.ZERO)


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var closed := points.duplicate()
	closed.append(points[0])
	return closed
