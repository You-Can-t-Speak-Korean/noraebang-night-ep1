# Runs Scene 01 in Map 01's 1학년 3반 and Saturday's free roam after it. The
# .dialogue file calls the stage methods below (teacher_exits, eunju_arrives, ...);
# everything else (who stands where, timings, the dialogue path) is in
# data/scenes/scene_01.json.
#
# Beats (docs/scripts/scene-01-eunju-scene-1-v0.2.md):
#   a    01-A  movement locked: the teacher leaves, the boys talk
#   a2   01-A2 movement free until 보람 nears 은주's desk or the time runs out
#   a3   01-A3 to 01-E, locked: 은주 walks to 보람, three choices, the bell
#   f    01-F  fade, the classroom empties, Saturday roam (progress sat_roam)
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

signal phase_changed(phase: String)

const DATA_PATH := "res://data/scenes/scene_01.json"
const ActorScript := preload("res://characters/actor.gd")

## "none" | "a" | "a2" | "a3" | "f"
var phase := "none"
## What started 01-A3: "proximity" or "timeout".
var a3_trigger := ""
var scene_locked := false
var a2_elapsed := 0.0
var config: Dictionary = {}
var actors: Dictionary = {}
## Divides every wait and multiplies walking speed; tests turn it up.
var time_scale := 1.0

var world: Node3D
var resource: DialogueResource
var _generation := 0
var _caption: Label
var _caption_layer: CanvasLayer

signal _a2_done


static func load_config(path: String = DATA_PATH) -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("SceneDirector: could not read %s" % path)
		return {}
	return data


func _ready() -> void:
	config = load_config()
	if not config.is_empty():
		resource = load(config["dialogue"])
	_caption_layer = CanvasLayer.new()
	_caption_layer.layer = 8
	add_child(_caption_layer)
	_caption = Label.new()
	_caption.visible = false
	_caption.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_caption.offset_top = 180
	_caption.offset_left = -400
	_caption.offset_right = 400
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override("font_outline_color", Color.BLACK)
	_caption.add_theme_constant_override("outline_size", 8)
	_caption_layer.add_child(_caption)


func _process(delta: float) -> void:
	_a2_tick(delta)


## True while the doors stay shut because the scene is still running.
func blocks_exits() -> bool:
	return phase in ["a", "a2", "a3"]


# ── Flow ───────────────────────────────────────────────────────────────

## Starts Scene 01 at 01-A. Autosaves first, so a relaunch resumes right here.
func start_scene() -> void:
	cancel()
	var mine := _generation
	GameState.set_progress("scene_01")
	_spawn_actors()
	world.autosave()
	_set_phase("a", true)
	await world.dialogue_box.play(resource, "a", [self])
	if mine != _generation:
		return
	a2_elapsed = 0.0
	a3_trigger = ""
	_set_phase("a2", false)
	await _a2_done
	if mine != _generation:
		return
	_set_phase("a3", true)
	world.close_text()
	await world.dialogue_box.play(resource, "a3", [self])
	if mine != _generation:
		return
	await _begin_roam(mine)


## Mid-scene stop (death, restart): no more steps, no stage directions.
func cancel() -> void:
	_generation += 1
	if world != null and world.dialogue_box != null:
		world.dialogue_box.cancel()
	for actor in actors.values():
		if is_instance_valid(actor):
			actor.cancel()
	clear_actors()
	a3_trigger = ""
	phase = "none"
	scene_locked = false
	_a2_done.emit()
	if world != null:
		world.update_lock()


## Saturday free roam without the scene (resume, --skip-to).
func enter_roam() -> void:
	cancel()
	GameState.set_progress("sat_roam")
	_set_phase("f", false)


func _begin_roam(mine: int) -> void:
	await world.fade_to(1.0)
	if mine != _generation:
		return
	clear_actors()
	GameState.set_progress("sat_roam")
	world.autosave()
	_set_phase("f", false)
	await world.fade_to(0.0)


func _set_phase(new_phase: String, locked: bool) -> void:
	phase = new_phase
	scene_locked = locked
	phase_changed.emit(new_phase)
	world.update_lock()


## 01-A2: 은주 gets up when 보람 is within reach of her desk, or after the free time.
func _a2_tick(delta: float) -> void:
	if phase != "a2":
		return
	a2_elapsed += delta
	var near := false
	if world.player != null and world.room_id == config["room"] and actors.has("eunju"):
		near = absf(world.player.position.x - float(config["actors"]["eunju"]["x"])) <= float(config["reach"])
	if near:
		a3_trigger = "proximity"
	elif a2_elapsed >= float(config["free_seconds"]):
		a3_trigger = "timeout"
	else:
		return
	phase = "a3"  # no second trigger while the dialogue starts
	_a2_done.emit()


# ── Actors ─────────────────────────────────────────────────────────────

func _spawn_actors() -> void:
	clear_actors()
	var specs: Dictionary = config["actors"]
	for id in specs:
		var spec: Dictionary = specs[id]
		var actor: Node3D = ActorScript.new()
		var c: Array = spec["color"]
		actor.setup(spec["name"], Color(c[0], c[1], c[2]))
		actor.position = Vector3(spec["x"], 0, spec["z"])
		world.room.add_child(actor)
		actors[id] = actor


func clear_actors() -> void:
	for actor in actors.values():
		if is_instance_valid(actor):
			actor.queue_free()
	actors.clear()


func _spot(id: String) -> Vector3:
	var spec: Dictionary = config["actors"][id]
	return Vector3(spec["x"], 0, spec["z"])


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds / time_scale).timeout


func _speed() -> float:
	return float(config["walk_speed"]) * time_scale


func _has(id: String) -> bool:
	return actors.has(id) and is_instance_valid(actors[id])


# ── Stage directions (called from scene_01.dialogue) ──────────────────

func teacher_exits() -> void:
	if not _has("teacher"):
		return
	var exit: Dictionary = config["teacher_exit"]
	var teacher: Node3D = actors["teacher"]
	await teacher.walk_to(exit["x"], exit["z"], _speed())
	if is_instance_valid(teacher):
		teacher.leave()


## 은주 and her friends walk to 보람, wherever she stands.
func eunju_arrives() -> void:
	if not _has("eunju"):
		return
	var p: Vector3 = world.player.position
	p.z = world.player.lane_z(world.player.lane)
	var eunju: Node3D = actors["eunju"]
	var side := -1.0 if eunju.position.x < p.x else 1.0
	var gap := float(config["approach_gap"])
	if _has("misuk"):
		actors["misuk"].walk_to(p.x + side * (gap + 0.9), p.z + 0.2, _speed())
	if _has("migyeong"):
		actors["migyeong"].walk_to(p.x + side * (gap + 1.8), p.z + 0.2, _speed())
	await eunju.walk_to(p.x + side * gap, p.z, _speed())


func giggle() -> void:
	for id in ["misuk", "migyeong"]:
		if _has(id):
			actors[id].bob()
	await _wait(0.5)


func grab_nameplate() -> void:
	if _has("eunju"):
		actors["eunju"].raise_hand()
	await _wait(0.4)


func class_laughs() -> void:
	for id in ["cheolsu", "dongjin", "misuk", "migyeong", "choi_eunju", "han_eunju"]:
		if _has(id):
			actors[id].bob()
	await _wait(0.5)


func raise_hands() -> void:
	for id in ["choi_eunju", "han_eunju"]:
		if _has(id):
			actors[id].raise_hand()
	await _wait(0.6)


func drop_nameplate() -> void:
	if _has("eunju"):
		actors["eunju"].lower_hand()
	await _wait(0.3)


func bell() -> void:
	for id in ["choi_eunju", "han_eunju"]:
		if _has(id):
			actors[id].lower_hand()
	_caption.text = config["bell_caption"]
	_caption.visible = true
	await _wait(float(config["caption_seconds"]))
	_caption.visible = false


func eunju_returns() -> void:
	for id in ["misuk", "migyeong"]:
		if _has(id):
			var s := _spot(id)
			actors[id].walk_to(s.x, s.z, _speed())
	if _has("eunju"):
		var s := _spot("eunju")
		await actors["eunju"].walk_to(s.x, s.z, _speed())


func eunju_looks_back() -> void:
	if _has("eunju"):
		actors["eunju"].bob()
	await _wait(0.4)
