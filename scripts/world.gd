# Runs a map: loads rooms, moves the player through doors with a fade, and
# shows placeholder text for interactables.
#   Capture one PNG per room (needs a real window, not --headless):
#     godot --path . -- --capture-map
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

signal room_changed(room_id: String)

const MAP_DATA := "res://data/maps/map_01.json"
const PlayerScene := preload("res://characters/player.tscn")
const CAPTURE_DIR := "user://captures/map"
const LOCKED_LINE := "(잠겨 있다.) [placeholder: locked]"

var fade_time := 0.18
var transitioning := false
var room: Node3D = null
var room_id := ""
var player: Node3D
var rooms: Dictionary = {}
var start_room := ""
var start_spawn := ""

var _fade_rect: ColorRect
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
	player = PlayerScene.instantiate()
	add_child(player)
	_load_room(start_room, start_spawn)
	if "--capture-map" in OS.get_cmdline_user_args():
		_run_capture()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)
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


func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not (event.is_action_pressed("confirm") or clicked) or event.is_echo():
		return
	if transitioning or player == null:
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
	else:
		show_text(source.placeholder_line)


func travel(target_room: String, target_spawn: String) -> void:
	transitioning = true
	player.movement_locked = true
	await _fade(1.0)
	_load_room(target_room, target_spawn)
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


func _mean_luminance(img: Image) -> float:
	var d := img.get_data()
	var total := 0.0
	for i in range(0, d.size(), 3):
		total += 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]
	return total / float(d.size() / 3) / 255.0
