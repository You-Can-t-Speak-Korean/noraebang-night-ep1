# A placeholder character: a labelled capsule with a hand that can go up.
# Simple tweens only: walk to a point, raise a hand, bob, leave.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

signal arrived

const FONT := preload("res://art/fonts/NotoSansKR/NotoSansKR-VF.ttf")
const BODY_HEIGHT := 1.5
const HAND_DOWN := Vector3(0.38, 0.9, 0.0)
const HAND_UP := Vector3(0.38, 1.75, 0.0)

var display_name := ""
var moving := false
var hand_raised := false

var _hand: MeshInstance3D
var _tween: Tween


## Builds the capsule and the name label (raised by `label_lift` so neighbours'
## labels do not overlap). Call once, before adding to the tree.
func setup(label_text: String, color: Color, label_lift: float = 0.0) -> void:
	display_name = label_text
	name = label_text
	var body := MeshInstance3D.new()
	body.name = "Body"
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = BODY_HEIGHT
	body.mesh = capsule
	body.material_override = _material(color)
	body.position = Vector3(0, BODY_HEIGHT / 2.0, 0)
	add_child(body)
	_hand = MeshInstance3D.new()
	_hand.name = "Hand"
	var hand_mesh := SphereMesh.new()
	hand_mesh.radius = 0.12
	hand_mesh.height = 0.24
	_hand.mesh = hand_mesh
	_hand.material_override = _material(color.lightened(0.45))
	_hand.position = HAND_DOWN
	add_child(_hand)
	var label := Label3D.new()
	label.name = "NameLabel"
	label.text = label_text
	label.font = FONT
	label.font_size = 30
	label.pixel_size = 0.008
	label.outline_size = 8
	label.position = Vector3(0, BODY_HEIGHT + 0.4 + label_lift, 0)
	label.add_to_group("dev_labels")
	add_child(label)


func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	return mat


## Walks in a straight line at `speed` units/s. Resolves when there, or when cancelled.
func walk_to(x: float, z: float, speed: float = 3.0) -> void:
	_stop()
	var target := Vector3(x, position.y, z)
	var time := maxf(position.distance_to(target) / speed, 0.01)
	moving = true
	_tween = create_tween()
	_tween.tween_property(self, "position", target, time)
	_tween.finished.connect(_finish_move)
	await arrived


func raise_hand() -> void:
	hand_raised = true
	create_tween().tween_property(_hand, "position", HAND_UP, 0.25)


func lower_hand() -> void:
	hand_raised = false
	create_tween().tween_property(_hand, "position", HAND_DOWN, 0.25)


## A small hop, used for giggling and laughing.
func bob() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", 0.18, 0.1)
	tween.tween_property(self, "position:y", 0.0, 0.1)
	tween.tween_property(self, "position:y", 0.12, 0.08)
	tween.tween_property(self, "position:y", 0.0, 0.08)


func leave() -> void:
	_stop()
	visible = false


## Stops any walk here and now; a waiting walk_to resolves.
func cancel() -> void:
	_stop()


func _stop() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	_finish_move()


func _finish_move() -> void:
	if moving:
		moving = false
		arrived.emit()
