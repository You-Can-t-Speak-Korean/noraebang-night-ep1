# Always-on HUD: hearts, 눈치 eyes, DDEOK 송편 and count, and secret cards.
# Reads GameState and redraws on its signals. After a dialogue choice it also
# floats a short cue: "+1" by the 눈치 eyes, or a lock and the lost card's name
# by the 비밀 count (Systems Spec v0.4 §4.1).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends CanvasLayer

const CARDS_PATH := "res://data/secrets/act1_cards.json"
const LockIconScript := preload("res://scripts/lock_icon.gd")
const CUE_TIME := 1.8
const CUE_RISE := 26.0
const CUE_COLOR := Color(1.0, 0.85, 0.4)

## The text of the last cue shown, and how many are on screen now.
var last_cue := ""
var cue_count := 0

var _card_names: Dictionary = {}
var _shown_nunchi := 0

@onready var hearts: Control = $Box/Hearts
@onready var nunchi: Control = $Box/Nunchi
@onready var ddeok_label: Label = $Box/Stats/Ddeok/Count
@onready var secrets_label: Label = $Box/Stats/Secrets


func _ready() -> void:
	_card_names = load_card_names()
	GameState.hearts_changed.connect(_on_changed)
	GameState.nunchi_changed.connect(_on_nunchi_changed)
	GameState.ddeok_changed.connect(_on_changed)
	GameState.secret_lost.connect(_on_secret_lost)
	GameState.state_reset.connect(refresh)
	refresh()


## card id -> display name, from the same card list the hand is made of.
static func load_card_names(path: String = CARDS_PATH) -> Dictionary:
	var names := {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if typeof(data) == TYPE_DICTIONARY:
		for card in data.get("cards", []):
			if typeof(card) == TYPE_DICTIONARY and card.has("id") and card.has("name"):
				names[card["id"]] = card["name"]
	return names


func card_name(card: String) -> String:
	return _card_names.get(card, card)


func refresh() -> void:
	hearts.set_hearts(GameState.hearts_halves, GameState.hearts_max_halves)
	nunchi.set_nunchi(GameState.nunchi, GameState.nunchi_cap)
	ddeok_label.text = str(GameState.ddeok)
	secrets_label.text = "비밀 %d/%d" % [GameState.secrets_held.size(), GameState.hand.size()]
	_shown_nunchi = GameState.nunchi


func _on_changed(_value: int) -> void:
	refresh()


func _on_nunchi_changed(value: int) -> void:
	var gained := value - _shown_nunchi
	refresh()
	if gained > 0:
		_float_cue(_cue_label("+%d" % gained), nunchi.global_position + Vector2(nunchi.custom_minimum_size.x + 16, -8))


func _on_secret_lost(card: String, _by: String) -> void:
	refresh()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon := Control.new()
	icon.set_script(LockIconScript)
	row.add_child(icon)
	row.add_child(_cue_label(card_name(card)))
	last_cue = card_name(card)
	_float_cue(row, secrets_label.global_position + Vector2(secrets_label.size.x + 20, 0), false)


func _cue_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", CUE_COLOR)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	return label


func _float_cue(cue: Control, at: Vector2, is_text := true) -> void:
	if is_text:
		last_cue = (cue as Label).text
	cue.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cue.position = at
	add_child(cue)
	cue_count += 1
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(cue, "position:y", at.y - CUE_RISE, CUE_TIME)
	tween.tween_property(cue, "modulate:a", 0.0, CUE_TIME).set_delay(CUE_TIME * 0.5)
	tween.chain().tween_callback(func():
		cue_count -= 1
		cue.queue_free())
