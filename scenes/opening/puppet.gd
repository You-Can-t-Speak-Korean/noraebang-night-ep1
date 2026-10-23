# Placeholder character: blocky figure drawn in code until real pixel art exists.
# Swap for a Sprite2D / AnimatedSprite2D with the same node name later.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Puppet
extends Node2D

@export var skin := Color(0.96, 0.8, 0.65)
@export var hair := Color(0.08, 0.06, 0.05)
@export var clothes := Color(0.3, 0.3, 0.35)
@export var height := 40.0          # body height in px (kids ~28, adults ~44)
@export var sunglasses := false
@export var pigtails := false
@export var curly := false
@export var label_text := ""

var head_visible := true
var facing := 1                     # 1 = right, -1 = left


func _draw() -> void:
	var w := height * 0.45
	var head_r := height * 0.22
	# body
	draw_rect(Rect2(-w / 2, -height, w, height), clothes)
	if not head_visible:
		# neck stump
		draw_rect(Rect2(-w / 5, -height - 3, w / 2.5, 3), Color(0.55, 0.0, 0.0))
		return
	var hc := Vector2(0, -height - head_r)
	# hair behind
	if curly:
		for i in 7:
			var a := PI + i * PI / 6.0
			draw_circle(hc + Vector2(cos(a), sin(a)) * head_r * 0.95, head_r * 0.45, hair)
	draw_circle(hc, head_r, skin)
	# fringe
	if curly:
		draw_circle(hc + Vector2(-head_r * 0.5, -head_r * 0.75), head_r * 0.4, hair)
		draw_circle(hc + Vector2(head_r * 0.2, -head_r * 0.85), head_r * 0.42, hair)
		draw_circle(hc + Vector2(head_r * 0.75, -head_r * 0.6), head_r * 0.38, hair)
	else:
		draw_rect(Rect2(hc.x - head_r, hc.y - head_r, head_r * 2, head_r * 0.7), hair)
	if pigtails:
		draw_circle(hc + Vector2(-head_r * 1.2, 0), head_r * 0.45, hair)
		draw_circle(hc + Vector2(head_r * 1.2, 0), head_r * 0.45, hair)
	# eyes
	var eye_y := hc.y + head_r * 0.05
	if sunglasses:
		draw_rect(Rect2(hc.x - head_r * 0.85, eye_y - 2, head_r * 1.7, 4), Color.BLACK)
	else:
		draw_rect(Rect2(hc.x + facing * head_r * 0.15 - 4, eye_y - 1, 2, 2), Color.BLACK)
		draw_rect(Rect2(hc.x + facing * head_r * 0.15 + 2, eye_y - 1, 2, 2), Color.BLACK)


func head_top() -> Vector2:
	return position + Vector2(0, -height - height * 0.44)


func neck() -> Vector2:
	return position + Vector2(0, -height)


func lose_head() -> void:
	head_visible = false
	queue_redraw()


func face(dir: int) -> void:
	facing = dir
	queue_redraw()
