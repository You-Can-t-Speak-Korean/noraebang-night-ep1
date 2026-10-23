# Dev tool: plays the opening by itself and saves screenshots.
#   godot --path . res://tests/capture.tscn -- <out_dir> <choice 0|1|2>
# Needs a display (or xvfb-run). Not part of the game build.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

var out_dir := "user://capture"
var choice := 2
var shot := 0
var elapsed := 0.0
var next_shot := 0.5
var next_tap := 1.0


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0: out_dir = args[0]
	if args.size() > 1: choice = int(args[1])
	DirAccess.make_dir_recursive_absolute(out_dir)
	add_child(load("res://scenes/opening/opening.tscn").instantiate())


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= next_shot:
		next_shot += 0.7
		var img := get_viewport().get_texture().get_image()
		img.save_png("%s/shot_%03d.png" % [out_dir, shot])
		shot += 1
	if elapsed >= next_tap:
		next_tap += 0.9
		var box: DialogueBox = find_child("*", true, false) as DialogueBox
		for n in get_tree().root.find_children("*", "DialogueBox", true, false):
			box = n
		var buttons: Array = []
		if box:
			for b in box.find_children("*", "Button", true, false):
				buttons.append(b)
		if buttons.size() == 3:
			await get_tree().create_timer(0.6).timeout
			if is_instance_valid(buttons[choice]):
				buttons[choice].pressed.emit()
		else:
			var e := InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_LEFT
			e.pressed = true
			e.position = Vector2(320, 200)
			Input.parse_input_event(e)
	if elapsed > 60.0:
		get_tree().quit()
