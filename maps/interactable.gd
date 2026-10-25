# A gray-box thing the player can press Enter at. It never reveals what is
# inside; the prompt is shown by the player. For now it only emits `interacted`.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Area3D

signal interacted(source: Area3D)

const FONT := preload("res://art/fonts/NotoSansKR/NotoSansKR-VF.ttf")
## Interactables sit on physics layer 2; the player's reach area masks it.
const LAYER_BIT := 2
## Deep enough to cover every lane no matter where the node stands.
const REACH_DEPTH := 14.0

@export var label_text := ""
@export var size := Vector3(1.0, 1.5, 0.4)
@export var color := Color(0.5, 0.45, 0.35)
@export_multiline var placeholder_line := "(placeholder text)"


func _ready() -> void:
	collision_layer = LAYER_BIT
	collision_mask = 0
	monitoring = false
	monitorable = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x + 1.0, size.y, REACH_DEPTH)
	shape.shape = box
	shape.position = Vector3(0, size.y / 2.0, 0)
	add_child(shape)

	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = mat
	visual.position = Vector3(0, size.y / 2.0, 0)
	add_child(visual)

	if label_text != "":
		var label := Label3D.new()
		label.text = label_text
		label.font = FONT
		label.font_size = 40
		label.pixel_size = 0.008
		label.outline_size = 10
		label.position = Vector3(0, size.y + 0.35, size.z / 2.0 + 0.05)
		add_child(label)


func interact() -> void:
	interacted.emit(self)
