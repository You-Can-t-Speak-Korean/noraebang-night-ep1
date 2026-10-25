# Draws the hearts row from shapes: full, half or empty. No glyphs, so no font
# has to carry them. One heart is two halves.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Control

const FULL_COLOR := Color(0.85, 0.12, 0.15)
const EMPTY_COLOR := Color(0.12, 0.1, 0.1, 0.75)
const OUTLINE_COLOR := Color(0.95, 0.9, 0.88)
const HEART_STEPS := 48

@export var heart_size := 52.0
@export var gap := 10.0

var halves := 0
var max_halves := 10

var _heart := PackedVector2Array()
var _left_half := PackedVector2Array()


func _ready() -> void:
	_heart = heart_polygon(heart_size)
	var clipped := Geometry2D.intersect_polygons(_heart, PackedVector2Array([
		Vector2(0, 0), Vector2(heart_size / 2.0, 0), Vector2(heart_size / 2.0, heart_size), Vector2(0, heart_size)]))
	_left_half = clipped[0] if not clipped.is_empty() else PackedVector2Array()
	_update_size()


func set_hearts(new_halves: int, new_max_halves: int) -> void:
	halves = new_halves
	max_halves = new_max_halves
	_update_size()
	queue_redraw()


## 2 = full, 1 = half, 0 = empty, for the heart at `index` (0 = leftmost).
static func heart_state(index: int, total_halves: int) -> int:
	return clampi(total_halves - index * 2, 0, 2)


static func heart_count(total_max_halves: int) -> int:
	return ceili(total_max_halves / 2.0)


## The classic parametric heart, stretched to fill a size x size box.
static func heart_polygon(size: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in HEART_STEPS:
		var t := TAU * i / HEART_STEPS
		var x := 16.0 * pow(sin(t), 3.0)
		var y := 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		points.append(Vector2(x, -y))
	var lo := points[0]
	var hi := points[0]
	for p in points:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for i in points.size():
		points[i] = (points[i] - lo) / (hi - lo) * size
	return points


func _update_size() -> void:
	var count := heart_count(max_halves)
	custom_minimum_size = Vector2(count * (heart_size + gap) - gap, heart_size)


func _draw() -> void:
	if _heart.is_empty():
		return
	for i in heart_count(max_halves):
		var offset := Vector2(i * (heart_size + gap), 0)
		var state := heart_state(i, halves)
		draw_set_transform(offset)
		draw_colored_polygon(_heart, FULL_COLOR if state == 2 else EMPTY_COLOR)
		if state == 1 and not _left_half.is_empty():
			draw_colored_polygon(_left_half, FULL_COLOR)
		draw_polyline(_closed(_heart), OUTLINE_COLOR, 3.0, true)
	draw_set_transform(Vector2.ZERO)


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var closed := points.duplicate()
	closed.append(points[0])
	return closed
