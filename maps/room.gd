# Shared room: builds floor, walls, one light and the fixed camera from
# its exports. Each room is a scene inheriting maps/room.tscn.
#
# Space: x runs along the room, y is up, z is depth (the front edge at z = 0 is
# open toward the camera, the back wall is at z = -depth). Player lanes sit at
# lane_origin_z - lane * spacing.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

const WALL_MARGIN := 1.0
## Camera framing, like the test stage: side-on and slightly high.
const CAMERA_HEIGHT := 3.4
const CAMERA_Z := 8.5
const CAMERA_TARGET := Vector3(0, 1.4, -5.0)
const CAMERA_FOV := 50.0
## Camera x stays this far inside the walls so the frame doesn't show past them.
const CAMERA_EDGE_INSET := 9.0

@export var room_id := ""
@export var room_title := ""
@export var bounds_left := -12.0
@export var bounds_right := 12.0
@export var depth := 8.0
@export var height := 6.5
@export var wall_color := Color(0.5, 0.5, 0.52)

## Lane 0 is nearest the camera; W steps to a higher lane (deeper).
var lane_origin_z := -3.0
var follow_target: Node3D = null
var camera: Camera3D


func _ready() -> void:
	_build_shell()
	_build_light_and_environment()
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.fov = CAMERA_FOV
	add_child(camera)
	camera.look_at_from_position(Vector3(0, CAMERA_HEIGHT, CAMERA_Z), CAMERA_TARGET)
	camera.make_current()
	update_camera()


func _process(_delta: float) -> void:
	update_camera()


func get_spawn(spawn_name: String) -> Node3D:
	for child in get_children():
		if child.has_method("is_spawn_point") and child.name == spawn_name:
			return child
	return null


func spawn_names() -> Array[String]:
	var names: Array[String] = []
	for child in get_children():
		if child.has_method("is_spawn_point"):
			names.append(str(child.name))
	return names


func update_camera() -> void:
	if camera == null:
		return
	var lo := bounds_left - WALL_MARGIN + CAMERA_EDGE_INSET
	var hi := bounds_right + WALL_MARGIN - CAMERA_EDGE_INSET
	var x := (bounds_left + bounds_right) / 2.0
	if lo <= hi:
		x = clampf(follow_target.position.x if follow_target else x, lo, hi)
	camera.position.x = x


func _add_box(node_name: String, pos: Vector3, box_size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = box_size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	var inst := MeshInstance3D.new()
	inst.name = node_name
	inst.mesh = mesh
	inst.material_override = mat
	inst.position = pos
	add_child(inst)


func _build_shell() -> void:
	var left := bounds_left - WALL_MARGIN
	var right := bounds_right + WALL_MARGIN
	var width := right - left
	var cx := (left + right) / 2.0
	var front := 6.0
	_add_box("Floor", Vector3(cx, -0.1, (front - depth) / 2.0), Vector3(width, 0.2, depth + front), wall_color.darkened(0.25))
	_add_box("BackWall", Vector3(cx, height / 2.0, -depth), Vector3(width, height, 0.2), wall_color)
	_add_box("LeftWall", Vector3(left, height / 2.0, -depth / 2.0), Vector3(0.2, height, depth), wall_color.darkened(0.1))
	_add_box("RightWall", Vector3(right, height / 2.0, -depth / 2.0), Vector3(0.2, height, depth), wall_color.darkened(0.1))


func _build_light_and_environment() -> void:
	var light := OmniLight3D.new()
	light.name = "Light"
	light.position = Vector3((bounds_left + bounds_right) / 2.0, height - 0.5, -depth / 2.0)
	light.omni_range = maxf(bounds_right - bounds_left, 20.0)
	light.light_energy = 2.0
	light.shadow_enabled = true
	add_child(light)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.04, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.45, 0.5)
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)
