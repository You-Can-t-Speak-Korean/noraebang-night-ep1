# Reusable dialogue box: speaker and line along the bottom of the screen, plus a
# choice menu for 2-4 options. Plays a Dialogue Manager resource from a cue.
#   Enter, Space or a click advances. At a choice: W/S (or the arrows) moves the
#   highlight, Enter or a click picks.
# It only shows lines and reports picks; effects are mutations in the .dialogue
# file. While `is_open` the owner keeps movement locked.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends CanvasLayer

signal opened
signal closed
signal line_shown(character: String, text: String)
signal choice_made(index: int, text: String)

const MAX_CHOICES := 4
const CHOICE_FILL := Color(0.08, 0.08, 0.1, 0.9)
const CHOICE_FILL_ON := Color(1.0, 0.85, 0.4, 1.0)
const CHOICE_TEXT := Color(0.92, 0.9, 0.85)
const CHOICE_TEXT_ON := Color(0.06, 0.05, 0.03)

var is_open := false
## True while a line waits for Enter / click.
var waiting := false
## True while the choice menu is up.
var choosing := false
var highlighted := 0

var _generation := 0
var _responses: Array = []
var _rows: Array[PanelContainer] = []

@onready var _panel: PanelContainer = $Root/Panel
@onready var _speaker: Label = $Root/Panel/Box/Speaker
@onready var _line: Label = $Root/Panel/Box/Line
@onready var _choices: VBoxContainer = $Root/Choices

signal _advanced
signal _picked(index: int)


## Runs the conversation from `cue` until it ends or is cancelled. `states` are
## extra Dialogue Manager state objects (the scene director goes here).
func play(resource: DialogueResource, cue: String, states: Array = []) -> void:
	if is_open:
		push_error("DialogueBox: already open")
		return
	_open()
	var mine := _generation
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue, states)
	while line != null and mine == _generation:
		_show(line)
		var next := ""
		var shown: Array = line.responses.filter(func(r): return r.is_allowed)
		if shown.size() >= 2:
			var index: int = await _ask(shown)
			if mine != _generation:
				return
			choice_made.emit(index, shown[index].text)
			next = shown[index].next_id
		else:
			waiting = true
			await _advanced
			waiting = false
			if mine != _generation:
				return
			next = line.next_id
		# Stage directions run between lines; the panel stays out of their way.
		_panel.visible = false
		_clear_choices()
		line = await DialogueManager.get_next_dialogue_line(resource, next, states)
	if mine == _generation:
		_close()


## Stops the conversation now (death, scene restart). Safe when nothing is open.
func cancel() -> void:
	_generation += 1
	if is_open:
		_close()
	_advanced.emit()
	_picked.emit(-1)


func advance() -> void:
	if is_open and waiting:
		_advanced.emit()


## Moves the highlight; clamped, no wrap.
func move_highlight(step: int) -> void:
	if choosing:
		_set_highlight(clampi(highlighted + step, 0, _rows.size() - 1))


func choose(index: int) -> void:
	if choosing and index >= 0 and index < _rows.size():
		_picked.emit(index)


func _input(event: InputEvent) -> void:
	if not is_open or event.is_echo():
		return
	if choosing:
		if event.is_action_pressed("ui_up"):
			move_highlight(-1)
		elif event.is_action_pressed("ui_down"):
			move_highlight(1)
		elif event.is_action_pressed("confirm"):
			choose(highlighted)
		else:
			return
		get_viewport().set_input_as_handled()
	elif waiting:
		var clicked: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
		if event.is_action_pressed("confirm") or clicked:
			advance()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("confirm"):
		# Between lines: swallow Enter so it can't reach the world.
		get_viewport().set_input_as_handled()


func _open() -> void:
	is_open = true
	visible = true
	_panel.visible = false
	opened.emit()


func _close() -> void:
	is_open = false
	waiting = false
	choosing = false
	visible = false
	_clear_choices()
	closed.emit()


func _show(line: DialogueLine) -> void:
	# A response-only line keeps the text that is already on screen.
	if line.text != "" or line.responses.is_empty():
		_speaker.text = line.character
		_speaker.visible = line.character != ""
		_line.text = line.text
	_panel.visible = true
	line_shown.emit(line.character, line.text)


func _ask(shown: Array) -> int:
	_clear_choices()
	_responses = shown.slice(0, MAX_CHOICES)
	for i in _responses.size():
		var row := _make_row(_responses[i].text, i)
		_choices.add_child(row)
		_rows.append(row)
	choosing = true
	_set_highlight(0)
	var index: int = await _picked
	choosing = false
	return index


func _make_row(text: String, index: int) -> PanelContainer:
	var row := PanelContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 32)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	row.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			choose(index))
	row.mouse_entered.connect(func(): _set_highlight(index))
	return row


func _set_highlight(index: int) -> void:
	highlighted = index
	for i in _rows.size():
		var on := i == index
		var style := StyleBoxFlat.new()
		style.bg_color = CHOICE_FILL_ON if on else CHOICE_FILL
		style.border_color = Color(1, 1, 1, 0.9) if on else Color(0.5, 0.5, 0.5, 0.6)
		style.set_border_width_all(3 if on else 1)
		style.set_corner_radius_all(8)
		style.content_margin_left = 24
		style.content_margin_right = 24
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		_rows[i].add_theme_stylebox_override("panel", style)
		var label: Label = _rows[i].get_child(0)
		label.add_theme_color_override("font_color", CHOICE_TEXT_ON if on else CHOICE_TEXT)
		label.text = ("▶ " if on else "   ") + _responses[i].text


func _clear_choices() -> void:
	for row in _rows:
		row.queue_free()
	_rows.clear()
	_responses = []
