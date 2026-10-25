# 보람: A/D walk, W/S step between lanes (depth layers along z). No physics.
# The interaction check is an Area3D that overlaps Interactables.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

const TuningScript := preload("res://scripts/tuning.gd")

@export var walk_speed := 4.5
@export var lane_speed := 8.0

## Dialogue (later) sets this; it blocks walking, lane steps and interaction prompts.
var movement_locked := false
var walk_min_x := -INF
var walk_max_x := INF
var lane := 0
var lane_count := TuningScript.DEFAULT_LANE_COUNT
var lane_spacing := TuningScript.DEFAULT_LANE_SPACING
var lane_origin_z := -3.0
var current_interactable: Node3D = null

var _near: Array[Node3D] = []

@onready var _prompt: Label3D = $Prompt
@onready var _area: Area3D = $InteractArea


## Pure: keeps a lane index inside 0..lane_count-1.
static func clamp_lane(lane_index: int, count: int) -> int:
	return clampi(lane_index, 0, maxi(count - 1, 0))


## Pure: the lane after stepping `step` lanes (+1 = deeper, away from the camera).
static func stepped_lane(lane_index: int, step: int, count: int) -> int:
	return clamp_lane(lane_index + step, count)


func _ready() -> void:
	var config := TuningScript.lane_config()
	lane_count = config["lane_count"]
	lane_spacing = config["lane_spacing"]
	_area.area_entered.connect(func(a: Area3D): _near.append(a))
	_area.area_exited.connect(func(a: Area3D): _near.erase(a))


func lane_z(lane_index: int) -> float:
	return lane_origin_z - clamp_lane(lane_index, lane_count) * lane_spacing


func configure_room(room: Node3D) -> void:
	walk_min_x = room.bounds_left
	walk_max_x = room.bounds_right
	lane_origin_z = room.lane_origin_z


func place(x: float, lane_index: int) -> void:
	lane = clamp_lane(lane_index, lane_count)
	position = Vector3(clampf(x, walk_min_x, walk_max_x), 0.0, lane_z(lane))
	current_interactable = null


func walk(axis: float, delta: float) -> void:
	if movement_locked:
		return
	position.x = clampf(position.x + axis * walk_speed * delta, walk_min_x, walk_max_x)


func step_lane(step: int) -> void:
	if movement_locked:
		return
	lane = stepped_lane(lane, step, lane_count)


func _process(delta: float) -> void:
	if not movement_locked:
		walk(Input.get_axis("move_left", "move_right"), delta)
		if Input.is_action_just_pressed("move_up"):
			step_lane(1)
		if Input.is_action_just_pressed("move_down"):
			step_lane(-1)
	position.z = move_toward(position.z, lane_z(lane), lane_speed * delta)
	_update_interactable()


func _update_interactable() -> void:
	current_interactable = null
	var best := INF
	_near = _near.filter(func(a): return is_instance_valid(a) and a.is_inside_tree())
	for it in _near:
		var d := absf(it.global_position.x - global_position.x)
		if d < best:
			best = d
			current_interactable = it
	_prompt.visible = current_interactable != null and not movement_locked
