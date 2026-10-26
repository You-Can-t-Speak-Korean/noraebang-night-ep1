# Runs the story beats in Map 01: Scene 01 and Saturday's roam, Scene 02 and the
# walk home, and the optional conversations. The .dialogue files call the stage
# methods below; who stands where, timings and the dialogue paths are in
# data/scenes/*.json.
#
# Progress steps (GameState.progress) and the phase that plays them:
#   scene_01    a, a2, a3   01-A to 01-E (docs/scripts/scene-01-eunju-scene-1-v0.2.md)
#   sat_roam    f           01-F, with the optional conversations
#   scene_02    s2          02-A to 02-D (docs/scripts/scene-02-eunju-scene-2-v0.2.md)
#   mon_walk    walk        02-E: 현정 follows; three triggers, in order, once each
#   mon_roam    mon_roam    02-F: the 문방구 door is open; the 집 door ends Monday
#   sat2_pending            end of build 3b (the world shows the end card)
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

signal phase_changed(phase: String)

const DATA_PATH := "res://data/scenes/scene_01.json"
const SCENE2_PATH := "res://data/scenes/scene_02.json"
const OC_PATH := "res://data/scenes/optional_sat.json"
const ActorScript := preload("res://characters/actor.gd")
const InteractableScene := preload("res://maps/interactable.tscn")
const WALK_TRIGGERS: Array[String] = ["entrance", "gate", "tv"]
const TRIGGER_CUES := {"entrance": "e_entrance", "gate": "e_gate", "tv": "e_tv"}

## "none" | "a" | "a2" | "a3" | "f" | "s2" | "walk" | "mon_roam"
var phase := "none"
## What started 01-A3: "proximity" or "timeout".
var a3_trigger := ""
var scene_locked := false
var a2_elapsed := 0.0
var config: Dictionary = {}
var config2: Dictionary = {}
var oc_config: Dictionary = {}
var actors: Dictionary = {}
## 현정 while she follows 보람 (02-E); null otherwise.
var hyunjeong: Node3D = null
## The 02-E triggers that have fired ("entrance", "gate", "tv").
var fired: Dictionary = {}
## Divides every wait and multiplies walking speed; tests turn it up.
var time_scale := 1.0

var world: Node3D
var resource: DialogueResource
var resource2: DialogueResource
var oc_resource: DialogueResource
var _generation := 0
var _caption: Label
var _form_layer: CanvasLayer

signal _a2_done


static func load_json(path: String) -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("SceneDirector: could not read %s" % path)
		return {}
	return data


static func load_config(path: String = DATA_PATH) -> Dictionary:
	return load_json(path)


func _ready() -> void:
	config = load_config()
	config2 = load_json(SCENE2_PATH)
	oc_config = load_json(OC_PATH)
	if not config.is_empty():
		resource = load(config["dialogue"])
	if not config2.is_empty():
		resource2 = load(config2["dialogue"])
	if not oc_config.is_empty():
		oc_resource = load(oc_config["dialogue"])
	var layer := CanvasLayer.new()
	layer.layer = 8
	add_child(layer)
	_caption = Label.new()
	_caption.visible = false
	_caption.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_caption.offset_top = 180
	_caption.offset_left = -400
	_caption.offset_right = 400
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override("font_outline_color", Color.BLACK)
	_caption.add_theme_constant_override("outline_size", 8)
	layer.add_child(_caption)


func _process(delta: float) -> void:
	_a2_tick(delta)
	_follow_tick(delta)
	_walk_trigger_tick()


## True while the doors stay shut because a scene is still running.
func blocks_exits() -> bool:
	return phase in ["a", "a2", "a3", "s2"]


# ── Scene 01 ───────────────────────────────────────────────────────────

## Starts Scene 01 at 01-A. Autosaves first, so a relaunch resumes right here.
func start_scene() -> void:
	cancel()
	var mine := _generation
	GameState.set_progress("scene_01")
	_spawn_actors(config["actors"])
	world.autosave()
	_set_phase("a", true)
	world.cut_to_black()
	await world.fade_to(0.0)
	await _wait(float(config.get("fade_in_hold", 0.0)))
	if mine != _generation:
		return
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
	hide_form()
	if hyunjeong != null and is_instance_valid(hyunjeong):
		hyunjeong.cancel()
		hyunjeong.queue_free()
	hyunjeong = null
	fired.clear()
	a3_trigger = ""
	phase = "none"
	scene_locked = false
	_caption.visible = false
	_a2_done.emit()
	if world != null:
		world.update_lock()


## Saturday free roam without the scene (resume, --skip-to).
func enter_roam() -> void:
	cancel()
	GameState.set_progress("sat_roam")
	_set_phase("f", false)
	place_optional_conversations()


func _begin_roam(mine: int) -> void:
	await world.fade_to(1.0)
	if mine != _generation:
		return
	clear_actors()
	GameState.set_progress("sat_roam")
	world.autosave()
	_set_phase("f", false)
	place_optional_conversations()
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


# ── Scene 02 and the walk home ─────────────────────────────────────────

## Starts Scene 02 at 02-A (movement locked to the end of 02-D). The screen is
## already black from the date card; it fades in here.
func start_scene_02() -> void:
	cancel()
	var mine := _generation
	GameState.set_progress("scene_02")
	_spawn_actors(config2["actors"])
	hyunjeong = actors["hyunjeong"]
	actors.erase("hyunjeong")
	var start: Dictionary = config2["player"]
	world.player.place(float(start["x"]), int(start["lane"]))
	world.autosave()
	_set_phase("s2", true)
	world.cut_to_black()
	await world.fade_to(0.0)
	if mine != _generation:
		return
	await world.dialogue_box.play(resource2, "a", [self])
	if mine != _generation:
		return
	await world.fade_to(1.0)
	if mine != _generation:
		return
	hide_form()
	clear_actors()
	_start_walk(true)
	await world.fade_to(0.0)


## 02-E without the scene (resume, --skip-to): 현정 waits at the classroom door.
func enter_walk() -> void:
	cancel()
	_start_walk(false)


func _start_walk(save: bool) -> void:
	fired.clear()
	GameState.set_progress("mon_walk")
	if hyunjeong != null and is_instance_valid(hyunjeong):
		hyunjeong.queue_free()
	hyunjeong = null
	if world.room_id == config2["room"]:
		var at: Dictionary = config2["walk_start"]["hyunjeong"]
		hyunjeong = _make_actor(config2["actors"]["hyunjeong"], world.room, Vector3(at["x"], 0, at["z"]))
		world.apply_labels()
	if save:
		world.autosave()
	_set_phase("walk", false)


func enter_mon_roam() -> void:
	cancel()
	GameState.set_progress("mon_roam")
	_set_phase("mon_roam", false)


## Called by the world after every room load.
func room_loaded(_id: String) -> void:
	if GameState.progress == "sat_roam":
		place_optional_conversations()
	if phase == "walk":
		_place_hyunjeong_beside_player()
	world.apply_labels()


func _place_hyunjeong_beside_player() -> void:
	hyunjeong = null  # the old one went with the old room
	var p: Vector3 = world.player.position
	var center: float = (world.room.bounds_left + world.room.bounds_right) / 2.0
	var side := 1.0 if p.x < center else -1.0
	var x := clampf(p.x + side * float(config2["follow_distance"]), world.room.bounds_left, world.room.bounds_right)
	hyunjeong = _make_actor(config2["actors"]["hyunjeong"], world.room, Vector3(x, 0, world.player.lane_z(world.player.lane)))


## 현정 stays about follow_distance behind 보람, in any room.
func _follow_tick(delta: float) -> void:
	if phase != "walk" or hyunjeong == null or not is_instance_valid(hyunjeong) or world.player == null:
		return
	var dist := float(config2["follow_distance"])
	var dx: float = hyunjeong.position.x - world.player.position.x
	if absf(dx) > dist:
		var goal: float = world.player.position.x + signf(dx) * dist
		hyunjeong.position.x = move_toward(hyunjeong.position.x, goal, float(config2["follow_speed"]) * delta)
	hyunjeong.position.z = move_toward(hyunjeong.position.z, world.player.lane_z(world.player.lane), 4.0 * delta)


## The 02-E triggers, in order, each once: the 현관, the 교문, the 전파사 door.
func next_trigger() -> String:
	for t in WALK_TRIGGERS:
		if not fired.has(t):
			return t
	return ""


func _trigger_ready(trigger: String) -> bool:
	match trigger:
		"entrance":
			return world.room_id == "entrance"
		"gate":
			return world.room_id == "gate"
		"tv":
			if world.room_id != "alley":
				return false
			var door: Node3D = world.room.get_node_or_null("To_radio_shop")
			return door != null and absf(world.player.position.x - door.position.x) <= float(config2["tv_trigger_range"])
	return false


func _walk_trigger_tick() -> void:
	if phase != "walk" or world.player == null or world.transitioning:
		return
	if world.dialogue_box.is_open or world.text_is_open():
		return
	var t := next_trigger()
	if t != "" and _trigger_ready(t):
		_fire(t)


func _fire(trigger: String) -> void:
	fired[trigger] = true
	var mine := _generation
	await world.dialogue_box.play(resource2, TRIGGER_CUES[trigger], [self])
	if mine != _generation:
		return
	if trigger == "tv":
		GameState.set_progress("mon_roam")
		world.autosave()
		_set_phase("mon_roam", false)


# ── Optional conversations (Saturday roam) ─────────────────────────────

## Puts this room's talkers and their talk spots in, if any. Only in sat_roam.
func place_optional_conversations() -> void:
	if GameState.progress != "sat_roam" or world.room == null:
		return
	for id in oc_config.get("conversations", {}):
		var cfg: Dictionary = oc_config["conversations"][id]
		if cfg["room"] != world.room_id:
			continue
		for spec in cfg["actors"]:
			var c: Array = spec["color"]
			var actor: Node3D = _make_actor({"name": spec["name"], "color": c, "lift": spec.get("lift", 0.0)},
					world.room, Vector3(float(cfg["x"]) + float(spec["dx"]), 0, float(spec["z"])))
			actor.set_meta("oc", id)
		var spot: Area3D = InteractableScene.instantiate()
		spot.show_body = false
		var s: Array = cfg["size"]
		spot.size = Vector3(s[0], s[1], s[2])
		spot.position = Vector3(cfg["x"], 0, cfg["z"])
		spot.set_meta("talk_id", id)
		spot.placeholder_line = "(placeholder)"
		world.room.add_child(spot)
		spot.interacted.connect(world._on_interacted)
	world.apply_labels()


## The first talk plays the conversation (and pays out its stakes); every later
## one is a single repeat line with no effect.
func talk(id: String) -> void:
	if GameState.progress != "sat_roam":
		return
	var talked_id: String = oc_config["conversations"][id]["talked_id"]
	if GameState.has_talked(talked_id):
		world.show_text(oc_config["repeat_line"])
		return
	GameState.mark_talked(talked_id)
	await world.dialogue_box.play(oc_resource, id, [self])


# ── Actors ─────────────────────────────────────────────────────────────

func _make_actor(spec: Dictionary, parent: Node3D, at: Vector3) -> Node3D:
	var actor: Node3D = ActorScript.new()
	var c: Array = spec["color"]
	actor.setup(spec["name"], Color(c[0], c[1], c[2]), float(spec.get("lift", 0.0)))
	actor.position = at
	parent.add_child(actor)
	return actor


func _spawn_actors(specs: Dictionary) -> void:
	clear_actors()
	var i := 0
	for id in specs:
		var spec: Dictionary = specs[id].duplicate()
		if not spec.has("lift"):
			spec["lift"] = 0.35 * (i % 3)  # neighbours' name labels at different heights
		actors[id] = _make_actor(spec, world.room, Vector3(spec["x"], 0, spec["z"]))
		i += 1
	world.apply_labels()


func clear_actors() -> void:
	for actor in actors.values():
		if is_instance_valid(actor):
			actor.queue_free()
	actors.clear()


func _spot(id: String) -> Vector3:
	var spec: Dictionary = config["actors"][id]
	return Vector3(spec["x"], 0, spec["z"])


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds / time_scale).timeout


func _speed() -> float:
	return float(config["walk_speed"]) * time_scale


func _has(id: String) -> bool:
	return actors.has(id) and is_instance_valid(actors[id])


func _say_placeholder(text: String) -> void:
	_caption.text = text
	_caption.visible = true
	await _wait(float(config2.get("caption_seconds", 1.0)))
	_caption.visible = false


func _bob_all(ids: Array) -> void:
	for id in ids:
		if _has(id):
			actors[id].bob()


# ── Stage directions: Scene 01 ────────────────────────────────────────

func teacher_exits() -> void:
	if not _has("teacher"):
		return
	var exit: Dictionary = config["teacher_exit"]
	var teacher: Node3D = actors["teacher"]
	var seconds := float(config.get("teacher_walk_seconds", 0.0))
	var speed := _speed()
	if seconds > 0.0:
		speed = teacher.position.distance_to(Vector3(exit["x"], 0, exit["z"])) / seconds * time_scale
	await teacher.walk_to(exit["x"], exit["z"], speed)
	if is_instance_valid(teacher):
		teacher.leave()


## The pause before the boys' first line.
func first_line_pause() -> void:
	await _wait(float(config.get("first_line_delay", 0.0)))


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
	_bob_all(["misuk", "migyeong"])
	await _wait(0.5)


func grab_nameplate() -> void:
	if _has("eunju"):
		actors["eunju"].raise_hand()
	await _wait(0.4)


func class_laughs() -> void:
	_bob_all(["cheolsu", "dongjin", "misuk", "migyeong", "choi_eunju", "han_eunju"])
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


# ── Stage directions: Scene 02 ────────────────────────────────────────

func eunju_hands_out() -> void:
	if _has("misuk"):
		actors["misuk"].walk_to(-0.5, -4.2, _speed())
	if _has("migyeong"):
		actors["migyeong"].walk_to(1.0, -4.2, _speed())
	if _has("eunju"):
		await actors["eunju"].walk_to(0.5, -4.2, _speed())


func hyunjeong_raises_hand() -> void:
	if hyunjeong != null and is_instance_valid(hyunjeong):
		hyunjeong.raise_hand()
	await _wait(0.5)


func eunju_passes_boram() -> void:
	if hyunjeong != null and is_instance_valid(hyunjeong):
		hyunjeong.lower_hand()
	if _has("eunju"):
		await actors["eunju"].walk_to(4.0, -4.6, _speed())


func hyunjeong_leans() -> void:
	if hyunjeong != null and is_instance_valid(hyunjeong):
		hyunjeong.bob()
	await _wait(0.4)


func eunju_to_front() -> void:
	if _has("eunju"):
		await actors["eunju"].walk_to(-2.0, -6.0, _speed())


func class_turns() -> void:
	_bob_all(["cheolsu", "dongjin", "misuk", "migyeong", "choi_eunju", "han_eunju"])
	await _wait(0.4)


## 02-D: the form as a simple drawn panel with the doc's printed lines.
func show_form() -> void:
	hide_form()
	_form_layer = CanvasLayer.new()
	_form_layer.layer = 8
	add_child(_form_layer)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -300
	panel.offset_right = 300
	panel.offset_top = 150
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.94, 0.86)
	style.border_color = Color(0.25, 0.2, 0.15)
	style.set_border_width_all(4)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(26)
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	var lines: Array = config2["form_lines"]
	for i in lines.size():
		var label := Label.new()
		label.text = lines[i]
		label.add_theme_color_override("font_color", Color(0.12, 0.1, 0.08))
		label.add_theme_font_size_override("font_size", 34 if i == 0 else 28)
		if i == 0:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(label)
	panel.add_child(box)
	_form_layer.add_child(panel)


func hide_form() -> void:
	if _form_layer != null and is_instance_valid(_form_layer):
		_form_layer.queue_free()
	_form_layer = null


func has_form() -> bool:
	return _form_layer != null and is_instance_valid(_form_layer)


func eunju_reads() -> void:
	_bob_all(["eunju", "misuk", "migyeong"])
	await _wait(0.4)


func cheolsu_reads() -> void:
	_bob_all(["cheolsu"])
	await _wait(0.4)


## 현정 waves and goes home; the 문방구 door opens when the TV scene ends.
func hyunjeong_leaves() -> void:
	var h := hyunjeong
	if h == null or not is_instance_valid(h):
		return
	h.raise_hand()
	await _wait(0.5)
	if not is_instance_valid(h):
		return
	h.lower_hand()
	var exit_x: float = world.room.bounds_left + 1.0
	await h.walk_to(exit_x, h.position.z, float(config2["walk_speed"]) * time_scale * 1.5)
	if is_instance_valid(h):
		h.leave()
		h.queue_free()
	if hyunjeong == h:
		hyunjeong = null


# ── Stage directions: optional conversations ──────────────────────────

func notebook_closes() -> void:
	await _say_placeholder("[placeholder: notebook closes]")


func fly_splat() -> void:
	await _say_placeholder("[placeholder: splat]")


func wipe_stick() -> void:
	await _say_placeholder("[placeholder: wipes the stick]")
