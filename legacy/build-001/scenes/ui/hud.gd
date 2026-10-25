# Dialogue HUD (spec §8): 👀 눈치 tokens and 🔒 비밀 cards.
# Listens to GameState, so any scene can drop it in.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Hud
extends Control

const GOLD := Color(1, 0.85, 0.3)
const CARD_BG := Color(0.18, 0.14, 0.3)
const LOST_BG := Color(0.45, 0.05, 0.05)

var _nunchi_label: Label
var _pips: Array[ColorRect] = []
var _cards: Dictionary = {}   # card_id -> PanelContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 👀 눈치 — top right
	_nunchi_label = _label("눈치", 12, GOLD)
	_nunchi_label.position = Vector2(520, 6)
	add_child(_nunchi_label)
	for i in GameState.MAX_NUNCHI:
		var pip := ColorRect.new()
		pip.size = Vector2(10, 10)
		pip.position = Vector2(552 + i * 14, 10)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pip)
		_pips.append(pip)

	# 🔒 비밀 — a row of cards along the top left
	var row := HBoxContainer.new()
	row.position = Vector2(6, 6)
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for card_id in GameState.card_order:
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_theme_stylebox_override("panel", _card_style(CARD_BG))
		var l := _label(GameState.card_defs[card_id]["name"], 12, Color.WHITE)
		card.add_child(l)
		row.add_child(card)
		_cards[card_id] = card

	GameState.nunchi_changed.connect(_on_nunchi_changed)
	GameState.secret_lost.connect(_on_secret_lost)
	refresh()


func refresh() -> void:
	for i in _pips.size():
		_pips[i].color = GOLD if i < GameState.nunchi else Color(0.25, 0.25, 0.25)
	for card_id in _cards:
		var lost: bool = not GameState.has_secret(card_id)
		var card: PanelContainer = _cards[card_id]
		card.add_theme_stylebox_override("panel", _card_style(LOST_BG if lost else CARD_BG))
		card.modulate.a = 0.55 if lost else 1.0


func _on_nunchi_changed(_value: int, delta: int) -> void:
	refresh()
	if delta > 0:
		_float_text("+%d 눈치" % delta, Vector2(540, 26), GOLD)


func _on_secret_lost(card_id: String, _known_by: String) -> void:
	var card: PanelContainer = _cards[card_id]
	# The card cracks: shake, flash red, then dim.
	var start := card.position
	var t := create_tween()
	for i in 6:
		t.tween_property(card, "position", start + Vector2(randf_range(-3, 3), randf_range(-2, 2)), 0.04)
	t.tween_property(card, "position", start, 0.04)
	t.tween_callback(refresh)
	_float_text("−1 비밀: %s" % GameState.card_defs[card_id]["name"], Vector2(10, 26), Color(1, 0.4, 0.4))


func _float_text(text: String, at: Vector2, color: Color) -> void:
	var l := _label(text, 12, color)
	l.position = at
	add_child(l)
	var t := create_tween().set_parallel()
	t.tween_property(l, "position:y", at.y + 14, 1.2)
	t.tween_property(l, "modulate:a", 0.0, 1.2).set_delay(0.6)
	t.chain().tween_callback(l.queue_free)


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	return l


func _card_style(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = Color(0.9, 0.9, 0.9, 0.6)
	sb.set_border_width_all(1)
	sb.content_margin_left = 3
	sb.content_margin_right = 3
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	return sb
