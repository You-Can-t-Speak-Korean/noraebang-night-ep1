# Visual-only gray-box block. `position` is the middle of its base on the floor.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends MeshInstance3D

const FONT := preload("res://art/fonts/NotoSansKR/NotoSansKR-VF.ttf")

@export var size := Vector3(1, 1, 1)
@export var color := Color(0.55, 0.55, 0.57)
@export var elevation := 0.0
@export var label_text := ""


func _ready() -> void:
	var box := BoxMesh.new()
	box.size = size
	mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	material_override = mat
	# Lift the node so its origin ends up at the middle of the base.
	position.y += elevation + size.y / 2.0
	if label_text != "":
		var label := Label3D.new()
		label.text = label_text
		label.font = FONT
		label.font_size = 36
		label.pixel_size = 0.008
		label.outline_size = 8
		label.position = Vector3(0, size.y / 2.0 + 0.3, size.z / 2.0 + 0.05)
		label.add_to_group("dev_labels")
		add_child(label)
