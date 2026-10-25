# Dialogue box: plays any .dialogue file line by line.
# Tap/click to finish typing, tap again to advance. Choices are big buttons.
# Stage directions ($> ...) are sent to the nodes passed in `stage_nodes`.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name DialogueBox
extends Control

signal advanced
signal chose(index: int)
signal choice_made(text: String)

const CHARS_PER_SECOND := 28.0

var _panel: Panel
var _name_label: Label
var _text: RichTextLabel
var _choices: VBoxContainer
var _arrow: Label
var _typing := false
var _waiting_tap := false
var _type_tween: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel = Panel.new()
	_panel.position = Vector2(16, 268)
	_panel.size = Vector2(608, 80)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.05, 0.08, 0.92)
	sb.border_color = Color(0.95, 0.9, 0.75)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(2)
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	_name_label = Label.new()
	_name_label.position = Vector2(10, -16)
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_name_label.add_theme_constant_override("outline_size", 4)
	_panel.add_child(_name_label)

	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.scroll_active = false
	_text.position = Vector2(12, 10)
	_text.size = Vector2(584, 62)
	_text.add_theme_font_size_override("normal_font_size", 12)
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_text)

	_arrow = Label.new()
	_arrow.text = "▼"
	_arrow.position = Vector2(590, 60)
	_arrow.add_theme_font_size_override("font_size", 12)
	_arrow.visible = false
	_panel.add_child(_arrow)

	_choices = VBoxContainer.new()
	_choices.position = Vector2(120, 120)
	_choices.size = Vector2(400, 0)
	_choices.add_theme_constant_override("separation", 8)
	add_child(_choices)

	visible = false


## Plays a dialogue resource from `cue` to the end.
func run(resource: Resource, cue: String, stage_nodes: Array) -> void:
	var line = await DialogueManager.get_next_dialogue_line(resource, cue, stage_nodes)
	while line != null:
		if line.responses.size() > 0:
			await _show_line(line, false)
			var index: int = await _ask(line.responses)
			line = await DialogueManager.get_next_dialogue_line(resource, line.responses[index].next_id, stage_nodes)
		else:
			await _show_line(line, true)
			line = await DialogueManager.get_next_dialogue_line(resource, line.next_id, stage_nodes)
	visible = false


func _show_line(line, wait_for_tap: bool) -> void:
	visible = true
	_panel.visible = true
	_name_label.text = line.character
	_name_label.visible = line.character != ""
	_text.text = line.text
	_text.visible_characters = 0
	_arrow.visible = false

	var total := _text.get_total_character_count()
	var speed := 1.0
	if line.speeds.size() > 0:
		speed = float(line.speeds.values()[0])
	_typing = true
	_type_tween = create_tween()
	_type_tween.tween_property(_text, "visible_characters", total, total / (CHARS_PER_SECOND * speed))
	_type_tween.finished.connect(func(): _typing = false)
	while _typing:
		await get_tree().process_frame

	if not wait_for_tap:
		return

	# [next=N] / [next=auto] auto-advances; otherwise wait for a tap.
	if line.time != "":
		var secs := total * 0.06 + 0.6 if line.time == "auto" else float(line.time)
		await get_tree().create_timer(secs).timeout
		return
	_arrow.visible = true
	_waiting_tap = true
	await advanced
	_waiting_tap = false
	_arrow.visible = false


func _ask(responses: Array) -> int:
	for child in _choices.get_children():
		child.queue_free()
	var i := 0
	for r in responses:
		var b := Button.new()
		b.text = r.text
		b.custom_minimum_size = Vector2(400, 32)  # big enough for thumbs
		b.add_theme_font_size_override("font_size", 12)
		b.disabled = not r.is_allowed
		var idx := i
		b.pressed.connect(func(): chose.emit(idx))
		_choices.add_child(b)
		i += 1
	_choices.position.y = 256 - 40 * responses.size()
	var picked: int = await chose
	choice_made.emit(responses[picked].text)
	for child in _choices.get_children():
		child.queue_free()
	return picked


func _unhandled_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or event.is_action_pressed("ui_accept")
	if not tapped or not visible:
		return
	if _typing:
		_type_tween.kill()
		_text.visible_characters = -1
		_typing = false
		get_viewport().set_input_as_handled()
	elif _waiting_tap:
		get_viewport().set_input_as_handled()
		advanced.emit()
