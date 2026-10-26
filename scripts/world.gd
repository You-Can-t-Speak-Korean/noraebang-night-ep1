# Runs a map: loads rooms, moves the player through doors with a fade, deals
# the day's finds into the search spots, and shows placeholder text.
#   Capture one PNG per room (needs a real window, not --headless):
#     godot --path . -- --capture-map
#   Capture the HUD (hearts 3.5, 눈치 3, DDEOK 12):
#     godot --path . -- --capture-hud
#   Capture the dialogue box at Choice 1 (second option highlighted):
#     godot --path . -- --capture-dialogue
#   Launch options: --new-game ignores any save; --seed N forces the spot layout.
#   Capture the 골목길 with 현정, the TV and the news line:
#     godot --path . -- --capture-alley
#   Dev only: --hearts N sets the hearts after launch (0.5-5, half steps);
#   --skip-to scene_01|sat_roam|scene_02|mon_walk|mon_roam (mon = scene_02) jumps to
#   that progress step; --no-labels starts with the name labels off (F9 toggles).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

signal room_changed(room_id: String)

const MAP_DATA := "res://data/maps/map_01.json"
const MAP_ID := "map_01"
const PlayerScene := preload("res://characters/player.tscn")
const HudScene := preload("res://scenes/hud.tscn")
const DialogueBoxScene := preload("res://scenes/ui/dialogue_box.tscn")
const DirectorScript := preload("res://scripts/scene_director.gd")
const SpawnDealerScript := preload("res://scripts/spawn_dealer.gd")
const SKIP_TARGETS: Array[String] = ["scene_01", "sat_roam", "scene_02", "mon_walk", "mon_roam", "mon"]
const MONDAY_CARD := "1979년 10월 29일 월요일"
const SATURDAY_CARD := "1979년 11월 3일 토요일"
const END_CARD := "[placeholder] END OF BUILD 3b"
const MONDAY_STEPS: Array[String] = ["scene_02", "mon_walk", "mon_roam"]
const HOME_LINE := "(아직 집에 갈 수 없다.) [placeholder: home]"
const SCENE_EXIT_LINE := "(지금은 나갈 수 없다.) [placeholder: scene]"
## Seconds the date card stays up before Monday starts.
const TITLE_HOLD := 2.5
const LOCKED_LINE := "(잠겨 있다.) [placeholder: locked]"
const GAME_OVER_LINE := "GAME OVER [placeholder]"
const GAME_OVER_HINT := "Press Enter [placeholder]"
const FLASH_ALPHA := 0.55
const FLASH_TIME := 0.4

var fade_time := 0.18
## Speed-up for the scene director (tests set it before adding the world).
var director_time_scale := 1.0
var title_hold := TITLE_HOLD
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
var dialogue_box: CanvasLayer
var director: Node
## Off: no Scene 01 and no progress handling; the world starts in the start room.
## Tests that only need the map set it before adding the world to the tree.
var begin_progress := true
var autosave_enabled := true
## A --capture-* launch: never touches the player's save.
var capture_mode := false
## From map_01.json: the door that ends Saturday, and doors that open on a day.
var saturday_exit: Dictionary = {}
var day_unlocked: Dictionary = {}
var progress_unlocked: Dictionary = {}
var home_exit: Dictionary = {}
## F9 / --no-labels: the door, prop and actor name labels (dev aids).
var labels_visible := true
var end_card_shown := false
## How many times the trap flash has fired (the flash itself is a placeholder).
var flashes := 0

var _forced_seed := -1
var _title_label: Label
var _end_label: Label
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
	saturday_exit = data.get("saturday_exit", {})
	day_unlocked = data.get("day_unlocked", {})
	progress_unlocked = data.get("progress_unlocked", {})
	home_exit = data.get("home_exit", {})
	spawn_config = SpawnDealerScript.load_config()
	var args := parse_launch_args(OS.get_cmdline_user_args())
	_forced_seed = args["seed"]
	var capturing: bool = args["capture_map"] or args["capture_hud"] or args["capture_dialogue"] or args["capture_alley"]
	labels_visible = not args["no_labels"]
	capture_mode = capturing
	if capturing:
		begin_progress = false
	_start_game(args["new_game"] or capturing)
	if args["skip_to"] != "":
		_apply_skip_to(args["skip_to"])
	if args["hearts_halves"] != -1:
		set_hearts_dev(args["hearts_halves"])
	hud = HudScene.instantiate()
	add_child(hud)
	dialogue_box = DialogueBoxScene.instantiate()
	add_child(dialogue_box)
	dialogue_box.opened.connect(update_lock)
	dialogue_box.closed.connect(update_lock)
	player = PlayerScene.instantiate()
	add_child(player)
	director = DirectorScript.new()
	director.world = self
	director.time_scale = director_time_scale
	add_child(director)
	GameState.player_died.connect(_on_player_died)
	if capturing and not (args["capture_dialogue"] or args["capture_alley"]):
		_load_room(start_room, start_spawn)
	elif begin_progress or args["capture_dialogue"] or args["capture_alley"]:
		_load_room(death_room, death_spawn)
	else:
		_load_room(start_room, start_spawn)
	if args["capture_map"]:
		_run_capture()
	elif args["capture_hud"]:
		_run_capture_hud()
	elif args["capture_dialogue"]:
		_run_capture_dialogue()
	elif args["capture_alley"]:
		_run_capture_alley()
	elif begin_progress:
		begin()


## {"new_game": bool, "seed": int (-1 = none), "capture_map": bool, "capture_hud": bool,
## "capture_dialogue": bool, "capture_alley": bool, "no_labels": bool,
## "hearts_halves": int (-1 = none), "skip_to": String ("" = none)}
static func parse_launch_args(args: PackedStringArray) -> Dictionary:
	var parsed := {"new_game": "--new-game" in args, "seed": -1,
			"capture_map": "--capture-map" in args, "capture_hud": "--capture-hud" in args,
			"capture_dialogue": "--capture-dialogue" in args, "capture_alley": "--capture-alley" in args,
			"no_labels": "--no-labels" in args, "hearts_halves": -1, "skip_to": ""}
	var at := args.find("--seed")
	if at != -1:
		if at + 1 < args.size() and args[at + 1].is_valid_int() and int(args[at + 1]) >= 0:
			parsed["seed"] = int(args[at + 1])
		else:
			push_warning("World: --seed needs a whole number >= 0; ignoring it")
	at = args.find("--hearts")
	if at != -1:
		parsed["hearts_halves"] = hearts_arg_to_halves(args[at + 1]) if at + 1 < args.size() else -1
		if parsed["hearts_halves"] == -1:
			push_warning("World: --hearts needs a number of hearts (e.g. 2.5); ignoring it")
	at = args.find("--skip-to")
	if at != -1:
		if at + 1 < args.size() and SKIP_TARGETS.has(args[at + 1]):
			parsed["skip_to"] = args[at + 1]
		else:
			push_warning("World: --skip-to needs one of %s; ignoring it" % str(SKIP_TARGETS))
	return parsed


## Dev arg --hearts N: hearts in whole or half steps, clamped to 0.5-5. Returns
## halves (1-10), or -1 when `text` is not a number.
static func hearts_arg_to_halves(text: String) -> int:
	if not text.is_valid_float():
		return -1
	var hearts := text.to_float()
	if not is_finite(hearts):
		return -1
	return clampi(roundi(hearts * 2.0), 1, 10)


## Loads the save (unless told not to), then rolls a spot layout for this launch.
func _start_game(ignore_save: bool) -> void:
	autosave_enabled = not capture_mode
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


## Dev only (--hearts): sets the hearts directly, bypassing damage and healing.
func set_hearts_dev(halves: int) -> void:
	GameState.hearts_halves = clampi(halves, 0, GameState.hearts_max_halves)
	GameState.hearts_changed.emit(GameState.hearts_halves)


## Dev only (--skip-to): sets the progress step (and the day and its deal).
## "mon" is an alias of scene_02.
func _apply_skip_to(target: String) -> void:
	GameState.set_progress("scene_02" if target == "mon" else target)
	_ensure_day("mon" if MONDAY_STEPS.has(GameState.progress) else "sat")


## Makes map_day match the progress step, re-dealing if it changed.
func _ensure_day(day: String) -> void:
	if GameState.map_day != day:
		GameState.map_day = day
		deal_layout()


## Starts from the saved progress step (at the start of that step).
func begin() -> void:
	if GameState.progress == "mon":
		GameState.set_progress("scene_02")  # an older name for the start of Scene 02
	if MONDAY_STEPS.has(GameState.progress):
		_ensure_day("mon")
	elif GameState.progress == "sat_roam":
		_ensure_day("sat")
	match GameState.progress:
		"sat_roam":
			director.enter_roam()
		"scene_02":
			director.start_scene_02()
		"mon_walk":
			director.enter_walk()
		"mon_roam":
			director.enter_mon_roam()
		"sat2_pending":
			cut_to_black()
			_show_end_card()
		_:
			director.start_scene()


## The player stands still while any of these is true.
func update_lock() -> void:
	if player == null:
		return
	var scene_locked: bool = director != null and director.scene_locked
	var dialogue_open: bool = dialogue_box != null and dialogue_box.is_open
	player.movement_locked = _text_open or transitioning or _game_over or scene_locked or dialogue_open or end_card_shown


func close_text() -> void:
	if _text_open:
		_close_text()


func text_is_open() -> bool:
	return _text_open


## Black at once (the director fades in from here).
func cut_to_black() -> void:
	_fade_rect.color.a = 1.0


## F9: show or hide the door, prop and actor name labels.
func toggle_labels() -> void:
	labels_visible = not labels_visible
	apply_labels()


func apply_labels() -> void:
	get_tree().call_group("dev_labels", "set_visible", labels_visible)


## Public fade for the scene director; 1.0 is black.
func fade_to(alpha: float) -> void:
	await _fade(alpha)


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
	_title_label = Label.new()
	_title_label.visible = false
	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_title_label)
	_end_label = Label.new()
	_end_label.visible = false
	_end_label.text = END_CARD
	_end_label.add_theme_font_size_override("font_size", 48)
	_end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_end_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_end_label)
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
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		toggle_labels()
		return
	var clicked: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not (event.is_action_pressed("confirm") or clicked) or event.is_echo():
		return
	if transitioning or end_card_shown or player == null or (dialogue_box != null and dialogue_box.is_open):
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
	update_lock()


func _close_text() -> void:
	_textbox.visible = false
	_text_open = false
	update_lock()


func _on_interacted(source: Area3D) -> void:
	if source.has_meta("talk_id"):
		director.talk(source.get_meta("talk_id"))
	elif source.has_method("is_door"):
		if director != null and director.blocks_exits():
			show_text(SCENE_EXIT_LINE)
		elif is_home_exit(source) and GameState.progress != "mon_roam":
			show_text(HOME_LINE)
		elif door_locked(source):
			show_text(LOCKED_LINE)
		elif is_home_exit(source):
			end_monday()
		else:
			travel(source.target_room, source.target_spawn)
	elif _is_spot_today(source.spot_id):
		_search(source.spot_id)
	else:
		show_text(source.placeholder_line)


## A scene door is locked unless the current day or progress step opens it
## (map_01.json day_unlocked, progress_unlocked).
func door_locked(door: Node3D) -> bool:
	if not door.locked:
		return false
	var key := "%s/%s" % [room_id, door.name]
	var by_day: Array = day_unlocked.get(GameState.map_day, [])
	var by_progress: Array = progress_unlocked.get(GameState.progress, [])
	return not (by_day.has(key) or by_progress.has(key))


## The 집 door at the far end of the 골목길.
func is_home_exit(door: Node3D) -> bool:
	return room_id == home_exit.get("room") and door.name == home_exit.get("door")


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
	update_lock()
	_game_over_layer.visible = true


## Enter on the game-over screen: everything resets to the start of Scene 01.
func restart_after_death() -> void:
	if director != null:
		director.cancel()
	GameState.death_reset()
	GameState.spawn_seed = _roll_seed()
	deal_layout()
	autosave()
	_game_over = false
	_game_over_layer.visible = false
	_close_text()
	_load_room(death_room, death_spawn)
	update_lock()
	room_changed.emit(death_room)
	if begin_progress:
		director.start_scene()


func travel(target_room: String, target_spawn: String) -> void:
	if GameState.progress == "sat_roam" and room_id == saturday_exit.get("room") and target_room == saturday_exit.get("target_room"):
		await end_saturday()
		return
	transitioning = true
	update_lock()
	await _fade(1.0)
	_load_room(target_room, target_spawn)
	autosave()
	await _fade(0.0)
	transitioning = false
	update_lock()
	room_changed.emit(target_room)


## Walking out the 교문 ends Saturday: black, the date card, then Monday in
## 1학년 3반 with a fresh deal. Placeholder until Scene 02 exists.
func end_saturday() -> void:
	transitioning = true
	update_lock()
	await _fade(1.0)
	_title_label.text = MONDAY_CARD
	_title_label.visible = true
	if fade_time > 0.0:
		await get_tree().create_timer(title_hold).timeout
	GameState.map_day = "mon"
	GameState.spawn_seed = _roll_seed()
	deal_layout()
	_load_room(death_room, death_spawn)
	_title_label.visible = false
	transitioning = false
	update_lock()
	room_changed.emit(death_room)
	# Scene 02 saves, starts movement-locked and fades in from the black.
	director.start_scene_02()


## Walking through the 집 door ends Monday: black, the date card, then the end
## card for this build. Placeholder until the party map exists.
func end_monday() -> void:
	transitioning = true
	update_lock()
	await _fade(1.0)
	_title_label.text = SATURDAY_CARD
	_title_label.visible = true
	if fade_time > 0.0:
		await get_tree().create_timer(title_hold).timeout
	GameState.set_progress("sat2_pending")
	autosave()
	_title_label.visible = false
	transitioning = false
	_show_end_card()
	room_changed.emit(room_id)


func _show_end_card() -> void:
	end_card_shown = true
	_end_label.visible = true
	update_lock()


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
	if director != null:
		director.room_loaded(id)
	apply_labels()


# ── Capture mode ───────────────────────────────────────────────────────

func _run_capture() -> void:
	var shots_dir := Shots.dir("map")
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
		var path := "%s/%s.png" % [shots_dir, id]
		img.save_png(path)
		img.convert(Image.FORMAT_RGB8)
		img.resize(480, 270)
		var lum := _mean_luminance(img)
		print("%s  %s  luminance %.4f" % [id, path, lum])
		if lum < 0.01:
			print("FAIL: %s is (nearly) black" % id)
			ok = false
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if ok else 1)


func _run_capture_dialogue() -> void:
	var path := Shots.dir().path_join("dialogue.png")
	fade_time = 0.0
	director.time_scale = 6.0
	director.start_scene()
	# Real flow: click through 01-A, let the free time run out, let 은주 walk over.
	var frames := 0
	while not dialogue_box.choosing and frames < 1800:
		if dialogue_box.waiting:
			dialogue_box.advance()
		if director.phase == "a2":
			director.a2_elapsed = 1e9
		await get_tree().process_frame
		frames += 1
	if not dialogue_box.choosing:
		print("FAIL: Choice 1 never appeared")
		get_tree().quit(1)
		return
	dialogue_box.move_highlight(1)
	for i in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	img.convert(Image.FORMAT_RGB8)
	img.resize(480, 270)
	var lum := _mean_luminance(img)
	print("dialogue  %s  luminance %.4f  highlighted %d" % [path, lum, dialogue_box.highlighted])
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if lum >= 0.01 and dialogue_box.highlighted == 1 else 1)


func _run_capture_alley() -> void:
	var path := Shots.dir().path_join("alley.png")
	fade_time = 0.0
	director.time_scale = 6.0
	GameState.map_day = "mon"
	deal_layout()
	director.enter_walk()
	director.fired = {"entrance": true, "gate": true}
	_load_room("alley", "from_gate")
	player.place(-4.0, 0)
	await get_tree().process_frame
	# Walk into the TV's range; the real trigger plays the news line.
	player.place(-2.0, 0)
	var frames := 0
	while not (dialogue_box.is_open and dialogue_box.waiting) and frames < 600:
		await get_tree().process_frame
		frames += 1
	if not dialogue_box.waiting:
		print("FAIL: the news line never appeared")
		get_tree().quit(1)
		return
	for i in 10:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	img.convert(Image.FORMAT_RGB8)
	img.resize(480, 270)
	var lum := _mean_luminance(img)
	var ok: bool = director.hyunjeong != null and lum >= 0.01
	print("alley  %s  luminance %.4f  hyunjeong %s" % [path, lum, str(director.hyunjeong != null)])
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if ok else 1)


func _run_capture_hud() -> void:
	var path := Shots.dir().path_join("hud.png")
	fade_time = 0.0
	GameState.damage(3)
	GameState.add_nunchi(3)
	GameState.add_ddeok(12)
	hud.refresh()
	for i in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	img.convert(Image.FORMAT_RGB8)
	img.resize(480, 270)
	var lum := _mean_luminance(img)
	print("hud  %s  luminance %.4f" % [path, lum])
	print("adapter: ", RenderingServer.get_video_adapter_name())
	get_tree().quit(0 if lum >= 0.01 else 1)


func _mean_luminance(img: Image) -> float:
	var d := img.get_data()
	var total := 0.0
	for i in range(0, d.size(), 3):
		total += 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]
	return total / float(d.size() / 3) / 255.0
