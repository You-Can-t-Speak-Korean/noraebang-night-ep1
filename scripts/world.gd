# Runs a map: loads rooms, moves the player through doors with a fade, deals
# the day's finds into the search spots, and shows placeholder text.
#   Capture one PNG per room (needs a real window, not --headless):
#     godot --path . -- --capture-map
#   Capture the HUD (hearts at 7 halves, 눈치 3, DDEOK 2):
#     godot --path . -- --capture-hud
#   Launch options: --new-game ignores any save; --seed N forces the spot layout.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

signal room_changed(room_id: String)

const MAP_DATA := "res://data/maps/map_01.json"
const MAP_ID := "map_01"
const PlayerScene := preload("res://characters/player.tscn")
const HudScene := preload("res://scenes/hud.tscn")
const SpawnDealerScript := preload("res://scripts/spawn_dealer.gd")
const CAPTURE_DIR := "user://captures/map"
const CAPTURE_HUD_PATH := "user://captures/hud.png"
const LOCKED_LINE := "(잠겨 있다.) [placeholder: locked]"
const GAME_OVER_LINE := "GAME OVER [placeholder]"
const GAME_OVER_HINT := "Press Enter [placeholder]"
const FLASH_ALPHA := 0.55
const FLASH_TIME := 0.4

var fade_time := 0.18
var transitioning := false
var room: Node3D = null
var room_id := ""
var player: Node3D
var rooms: Dictionary = {}
var start_room := ""
var start_spawn := ""
var death_room := ""
var death_spawn := ""
## Search-spot data and today's deal: spot_id -> what is hidden there. Lives here,
## not in the room scenes, so it survives room changes.
var spawn_config: Dictionary = {}
var layout: Dictionary = {}
var hud: CanvasLayer
var autosave_enabled := true
## How many times the trap flash has fired (the flash itself is a placeholder).
var flashes := 0

var _forced_seed := -1
var _game_over := false
var _fade_rect: ColorRect
var _flash_rect: ColorRect
var _game_over_layer: CanvasLayer
var _textbox: PanelContainer
var _text_label: Label
var _text_open := false


func _ready() -> void:
	_build_ui()
	var data = JSON.parse_string(FileAccess.get_file_as_string(MAP_DATA))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("World: could not read %s" % MAP_DATA)
		return
	rooms = data["rooms"]
	start_room = data["start_room"]
	start_spawn = data["start_spawn"]
	death_room = data["death_room"]
	death_spawn = data["death_spawn"]
	spawn_config = SpawnDealerScript.load_config()
	var args := parse_launch_args(OS.get_cmdline_user_args())
	_forced_seed = args["seed"]
	_start_game(args["new_game"] or args["capture_hud"])
	hud = HudScene.instantiate()
	add_child(hud)
	player = PlayerScene.instantiate()
	add_child(player)
	_load_room(start_room, start_spawn)
	GameState.player_died.connect(_on_player_died)
	if args["capture_map"]:
		_run_capture()
	elif args["capture_hud"]:
		_run_capture_hud()


## {"new_game": bool, "seed": int (-1 = none), "capture_map": bool, "capture_hud": bool}
static func parse_launch_args(args: PackedStringArray) -> Dictionary:
	var parsed := {"new_game": "--new-game" in args, "seed": -1,
			"capture_map": "--capture-map" in args, "capture_hud": "--capture-hud" in args}
	var at := args.find("--seed")
	if at != -1:
		if at + 1 < args.size() and args[at + 1].is_valid_int() and int(args[at + 1]) >= 0:
			parsed["seed"] = int(args[at + 1])
		else:
			push_warning("World: --seed needs a whole number >= 0; ignoring it")
	return parsed


## Loads the save (unless told not to), then rolls a spot layout for this launch.
func _start_game(ignore_save: bool) -> void:
	autosave_enabled = true
	var loaded := false
	if not ignore_save and GameState.has_save():
		var err: Error = GameState.load_game()
		if err == OK:
			loaded = true
		else:
			push_error("World: could not load the save (error %d); starting a new game" % err)
			if err == ERR_UNAVAILABLE:
				# Written by a newer version: don't overwrite it with autosaves.
				autosave_enabled = false
	if not loaded:
		GameState.new_game()
	GameState.spawn_seed = _roll_seed()
	deal_layout()


func _roll_seed() -> int:
	return _forced_seed if _forced_seed >= 0 else randi()


func collected_key() -> String:
	return "%s:%s" % [MAP_ID, GameState.map_day]


## Deals today's finds into the spots that haven't been searched yet.
func deal_layout() -> void:
	var day: String = GameState.map_day
	var budgets: Dictionary = spawn_config.get("budgets", {})
	if not budgets.has(day):
		push_error("World: no spot budget for day '%s'" % day)
		layout = {}
		return
	layout = SpawnDealerScript.deal(spawn_config["spots"], budgets[day], spawn_config["extras"],
			GameState.spawn_seed, GameState.collected.get(collected_key(), []), GameState.notes, day)


func autosave() -> void:
	if not autosave_enabled:
		return
	var err: Error = GameState.save_game()
	if err != OK:
		push_error("World: autosave failed (error %d)" % err)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(0.8, 0.0, 0.0, 0.0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_flash_rect)
	_textbox = PanelContainer.new()
	_textbox.visible = false
	_textbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_textbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_textbox.offset_left = 160
	_textbox.offset_right = -160
	_textbox.offset_top = -220
	_textbox.offset_bottom = -40
	layer.add_child(_textbox)
	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_textbox.add_child(_text_label)
	# Game over sits above the map and below the HUD, so the empty hearts stay visible.
	_game_over_layer = CanvasLayer.new()
	_game_over_layer.layer = 11
	_game_over_layer.visible = false
	add_child(_game_over_layer)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_layer.add_child(black)
	var over := Label.new()
	over.text = "%s\n%s" % [GAME_OVER_LINE, GAME_OVER_HINT]
	over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	over.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_layer.add_child(over)


func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not (event.is_action_pressed("confirm") or clicked) or event.is_echo():
		return
	if transitioning or player == null:
		return
	if _game_over:
		restart_after_death()
		return
	if _text_open:
		_close_text()
	elif player.current_interactable != null and not player.movement_locked:
		player.current_interactable.interact()


func show_text(line: String) -> void:
	_text_label.text = line
	_textbox.visible = true
	_text_open = true
	player.movement_locked = true


func _close_text() -> void:
	_textbox.visible = false
	_text_open = false
	player.movement_locked = false


func _on_interacted(source: Area3D) -> void:
	if source.has_method("is_door"):
		if source.locked:
			show_text(LOCKED_LINE)
		else:
			travel(source.target_room, source.target_spawn)
	elif _is_spot_today(source.spot_id):
		_search(source.spot_id)
	else:
		show_text(source.placeholder_line)


func _is_spot_today(spot_id: String) -> bool:
	var spots: Dictionary = spawn_config.get("spots", {})
	return spot_id != "" and spots.has(spot_id) and spots[spot_id].get("days", []).has(GameState.map_day)


func _spot_searched(spot_id: String) -> bool:
	for entry in GameState.collected.get(collected_key(), []):
		if str(entry).split(":")[0] == spot_id:
			return true
	return false


## Half a heart is "½", then "1", "1½", ...
static func hearts_text(halves: int) -> String:
	var whole := floori(halves / 2.0)
	if whole == 0:
		return "½"
	return "%d%s" % [whole, "½" if halves % 2 == 1 else ""]


## Every spot can be searched once. Whatever is found is applied to GameState at once.
func _search(spot_id: String) -> void:
	var lines: Dictionary = spawn_config.get("lines", {})
	if _spot_searched(spot_id):
		show_text(lines.get("searched", "(already searched)"))
		return
	var entry: Dictionary = layout.get(spot_id, {"kind": "empty"})
	var kind: String = entry["kind"]
	GameState.mark_collected(collected_key(), "%s:%s" % [spot_id, kind])
	var text: String = lines.get(kind, kind)
	match kind:
		"ddeok":
			GameState.add_ddeok(entry["amount"])
			text = text.format({"amount": entry["amount"]})
		"note":
			GameState.add_note(entry["note_id"])
			text = text.format({"text": spawn_config["notes"].get(entry["note_id"], "")})
		"health":
			GameState.heal(entry["heal"])
			text = text.format({"name": entry["name"], "heal": hearts_text(entry["heal"])})
		"trap":
			text = text.format({"name": entry["name"], "damage": hearts_text(entry["damage"])})
	show_text(text)
	if kind == "trap":
		_flash()
		# May emit player_died; the game-over screen goes over the text.
		GameState.damage(entry["damage"])


func _flash() -> void:
	flashes += 1
	_flash_rect.color.a = FLASH_ALPHA
	create_tween().tween_property(_flash_rect, "color:a", 0.0, FLASH_TIME)


func _on_player_died() -> void:
	_game_over = true
	player.movement_locked = true
	_game_over_layer.visible = true


## Enter on the game-over screen: everything resets to the start of Scene 01.
func restart_after_death() -> void:
	GameState.death_reset()
	GameState.spawn_seed = _roll_seed()
	deal_layout()
	autosave()
	_game_over = false
	_game_over_layer.visible = false
	_close_text()
	_load_room(death_room, death_spawn)
	room_changed.emit(death_room)


func travel(target_room: String, target_spawn: String) -> void:
	transitioning = true
	player.movement_locked = true
	await _fade(1.0)
	_load_room(target_room, target_spawn)
	autosave()
	await _fade(0.0)
	player.movement_locked = false
	transitioning = false
	room_changed.emit(target_room)


func _fade(alpha: float) -> void:
	if fade_time <= 0.0:
		_fade_rect.color.a = alpha
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", alpha, fade_time)
	await tween.finished


func _load_room(id: String, spawn_name: String) -> void:
	if not rooms.has(id):
		push_error("World: unknown room '%s'" % id)
		return
	if room != null:
		remove_child(room)
		room.queue_free()
	room = load(rooms[id]).instantiate()
	room_id = id
	add_child(room)
	player.configure_room(room)
	var spawn: Node3D = room.get_spawn(spawn_name) if spawn_name != "" else null
	if spawn == null:
		if spawn_name != "":
			push_error("World: room '%s' has no spawn '%s'" % [id, spawn_name])
		player.place((room.bounds_left + room.bounds_right) / 2.0, 0)
	else:
		player.place(spawn.position.x, spawn.lane)
	player.position.z = player.lane_z(player.lane)
	room.follow_target = player
	room.update_camera()
	for it in room.find_children("*", "Area3D", true, false):
		if it.has_method("interact"):
			it.interacted.connect(_on_interacted)


# ── Capture mode ───────────────────────────────────────────────────────

func _run_capture() -> void:
	DirAccess.make_dir_recursive_absolute(CAPTURE_DIR)
	fade_time = 0.0
	var ok := true
	for id in rooms:
		_load_room(id, "")
		# Stand in the middle so the camera frames the room's centre.
		player.place((room.bounds_left + room.bounds_right) / 2.0, 0)
		room.update_camera()
		for i in 8:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := "%s/%s.png" % [CAPTURE_DIR, id]
		img.save_png(path)
		img.convert(Image.FORMAT_RGB8)
		img.resize(480, 270)
		var lum := _mean_luminance(img)
		print("%s  %s  luminance %.4f" % [id, ProjectSettings.globalize_path(path), lum])
		if lum < 0.01:
			print("FAIL: %s is (nearly) black" % id)
			ok = false
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if ok else 1)


func _run_capture_hud() -> void:
	DirAccess.make_dir_recursive_absolute(CAPTURE_HUD_PATH.get_base_dir())
	fade_time = 0.0
	GameState.damage(3)
	GameState.add_nunchi(3)
	GameState.add_ddeok(2)
	hud.refresh()
	for i in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(CAPTURE_HUD_PATH)
	img.convert(Image.FORMAT_RGB8)
	img.resize(480, 270)
	var lum := _mean_luminance(img)
	print("hud  %s  luminance %.4f" % [ProjectSettings.globalize_path(CAPTURE_HUD_PATH), lum])
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if lum >= 0.01 else 1)


func _mean_luminance(img: Image) -> float:
	var d := img.get_data()
	var total := 0.0
	for i in range(0, d.size(), 3):
		total += 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]
	return total / float(d.size() / 3) / 255.0
