# The shop screen (Build 5b) and the shopkeeper's short speech line. The shop panel lists one row
# per stock entry of data/shop/<shop_id>.json (name, 송편 icon + price, quantity left); W/S + Enter
# or a click buys through Store.buy, Esc closes. While it is open `is_open` is true and the owner
# keeps movement locked. Every line the shopkeeper says comes from the shop's data file.
#
# Korean text is only what the design gives: the lines in the shop file, 문방구, the speaker label
# and the item names. English in brackets is placeholder.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name ShopUI
extends CanvasLayer

signal opened
signal closed
## A purchase went through (the owner saves).
signal purchased(shop_id: String, item_id: String)

const DdeokIconScript := preload("res://scripts/ddeok_icon.gd")
const HINT := "[placeholder] W/S + Enter or click: buy   Esc: close"
const SAY_TIME := 2.4
const SAY_FADE := 0.4
const COLOR_SELECTED := Color(1.0, 0.85, 0.4)
const COLOR_NORMAL := Color(0.92, 0.92, 0.92)
const COLOR_DIM := Color(0.5, 0.5, 0.55)

## The last line shown (panel or speech) and who said it; tests read these.
static var last_line := ""
static var last_speaker := ""
## How many times a shopkeeper has greeted 보람 at the door (once per visit to the room).
static var greet_count := 0

var is_open := false
var shop_id := ""
var selected := 0
## The line the panel shows now (the greeting, then the answer to the last purchase attempt).
var panel_line := ""
## The last result of Store.buy for a row pressed in the panel.
var last_result: Dictionary = {}
## Rows, top to bottom: the stock entries ({"item", "price", "quantity"}) in file order.
var rows: Array = []

var _shade: ColorRect
var _panel: PanelContainer
var _title: Label
var _line_label: Label
var _rows_box: VBoxContainer
var _row_buttons: Array[Button] = []
var _row_labels: Array[Dictionary] = []
var _balance: Label
var _say_panel: PanelContainer
var _say_speaker: Label
var _say_label: Label
var _say_tween: Tween


func _init() -> void:
	layer = 15


static func _gs() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node("GameState")


func _ready() -> void:
	_shade = ColorRect.new()
	_shade.color = Color(0, 0, 0, 0.55)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.visible = false
	add_child(_shade)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(760, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.09, 0.12, 0.96)
	sb.border_color = Color(0.7, 0.62, 0.4)
	sb.set_border_width_all(3)
	sb.set_content_margin_all(26)
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.visible = false
	add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	_panel.add_child(box)
	_title = _make_label("", 40, COLOR_NORMAL)
	box.add_child(_title)
	_line_label = _make_label("", 30, COLOR_SELECTED)
	_line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_line_label)
	_rows_box = VBoxContainer.new()
	_rows_box.add_theme_constant_override("separation", 4)
	box.add_child(_rows_box)
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	var icon := Control.new()
	icon.set_script(DdeokIconScript)
	icon.set("icon_width", 34.0)
	icon.set("icon_height", 20.0)
	foot.add_child(icon)
	_balance = _make_label("", 28, COLOR_NORMAL)
	foot.add_child(_balance)
	box.add_child(foot)
	box.add_child(_make_label(HINT, 20, COLOR_DIM))
	# The shopkeeper's speech line: a strip at the bottom that never blocks anything.
	_say_panel = PanelContainer.new()
	_say_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_say_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_say_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_say_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_say_panel.offset_top = -300
	_say_panel.offset_bottom = -300
	_say_panel.visible = false
	var sb2 := StyleBoxFlat.new()
	sb2.bg_color = Color(0.09, 0.09, 0.12, 0.85)
	sb2.border_color = Color(0.7, 0.62, 0.4)
	sb2.set_border_width_all(2)
	sb2.set_content_margin_all(14)
	_say_panel.add_theme_stylebox_override("panel", sb2)
	add_child(_say_panel)
	var sbox := VBoxContainer.new()
	sbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_say_panel.add_child(sbox)
	_say_speaker = _make_label("", 22, COLOR_SELECTED)
	_say_speaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sbox.add_child(_say_speaker)
	_say_label = _make_label("", 34, COLOR_NORMAL)
	_say_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sbox.add_child(_say_label)
	_gs().ddeok_changed.connect(func(_v): _refresh_balance())


func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


# ── The speech line ────────────────────────────────────────────────────

## A short, non-blocking line from the shopkeeper with the speaker label. Fades by itself.
func say(speaker_label: String, text: String) -> void:
	last_line = text
	last_speaker = speaker_label
	_say_speaker.text = speaker_label
	_say_label.text = text
	_say_panel.visible = true
	_say_panel.modulate.a = 1.0
	if _say_tween != null and _say_tween.is_valid():
		_say_tween.kill()
	_say_tween = create_tween()
	_say_tween.tween_interval(SAY_TIME)
	_say_tween.tween_property(_say_panel, "modulate:a", 0.0, SAY_FADE)
	_say_tween.tween_callback(func(): _say_panel.visible = false)


## What the shopkeeper says when 보람 walks in (the shop's "enter" line).
func greet(for_shop: String) -> void:
	greet_count += 1
	say(Store.speaker(for_shop), Store.line(for_shop, "enter"))


# ── Open / close ───────────────────────────────────────────────────────

## Opens the panel for `for_shop`. False for an unknown shop.
func open(for_shop: String) -> bool:
	if is_open or not Store.exists(for_shop):
		return false
	shop_id = for_shop
	selected = 0
	rows = Store.stock_entries(for_shop)
	last_result = {}
	_title.text = str(Store.load_shop(for_shop).get("name", ""))
	_set_line(Store.line(for_shop, "open"))
	_rebuild()
	is_open = true
	_shade.visible = true
	_panel.visible = true
	_say_panel.visible = false
	opened.emit()
	return true


## Closes the panel and the shopkeeper says the closing line.
func close() -> void:
	if not is_open:
		return
	is_open = false
	_shade.visible = false
	_panel.visible = false
	closed.emit()
	say(Store.speaker(shop_id), Store.line(shop_id, "close"))


## Closes everything without a word (a death, a new game).
func reset() -> void:
	if not is_open:
		return
	is_open = false
	_shade.visible = false
	_panel.visible = false
	closed.emit()


func _set_line(text: String) -> void:
	panel_line = text
	last_line = text
	last_speaker = Store.speaker(shop_id)
	_line_label.text = text


# ── The rows ───────────────────────────────────────────────────────────

func _rebuild() -> void:
	for c in _rows_box.get_children():
		_rows_box.remove_child(c)
		c.queue_free()
	_row_buttons = []
	_row_labels = []
	for i in rows.size():
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.flat = true
		b.custom_minimum_size = Vector2(0, 46)
		b.mouse_entered.connect(func(): _select(i))
		b.pressed.connect(func(): buy_row(i))
		var h := HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 12)
		b.add_child(h)
		var name_label := _make_label("", 30, COLOR_NORMAL)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(name_label)
		var icon := Control.new()
		icon.set_script(DdeokIconScript)
		icon.set("icon_width", 34.0)
		icon.set("icon_height", 20.0)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(icon)
		var price_label := _make_label("", 30, COLOR_NORMAL)
		price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_label.custom_minimum_size = Vector2(50, 0)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(price_label)
		var qty_label := _make_label("", 30, COLOR_NORMAL)
		qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		qty_label.custom_minimum_size = Vector2(80, 0)
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(qty_label)
		_rows_box.add_child(b)
		_row_buttons.append(b)
		_row_labels.append({"name": name_label, "icon": icon, "price": price_label, "qty": qty_label})
	_paint()
	_refresh_balance()


## True when row `i` has none left.
func row_sold_out(i: int) -> bool:
	return i >= 0 and i < rows.size() and Store.stock_left(shop_id, rows[i]["item"]) <= 0


func _paint() -> void:
	for i in rows.size():
		var on := i == selected
		var out := row_sold_out(i)
		var color := COLOR_DIM if out else (COLOR_SELECTED if on else COLOR_NORMAL)
		var l: Dictionary = _row_labels[i]
		l["name"].text = ("▶ " if on else "   ") + Items.item_name(rows[i]["item"])
		l["price"].text = str(rows[i]["price"])
		l["qty"].text = "×%d" % Store.stock_left(shop_id, rows[i]["item"])
		for k in ["name", "price", "qty"]:
			l[k].add_theme_color_override("font_color", color)
		l["icon"].modulate = Color(1, 1, 1, 0.35 if out else 1.0)


func _refresh_balance() -> void:
	if _balance != null:
		_balance.text = str(_gs().ddeok)


func _select(i: int) -> void:
	if is_open and not rows.is_empty():
		selected = posmod(i, rows.size())
		_paint()


## Buys row `i` (what Enter and a click call) and shows the shopkeeper's answer. Returns Store.buy's result.
func buy_row(i: int) -> Dictionary:
	if not is_open or i < 0 or i >= rows.size():
		return {}
	selected = i
	var r := Store.buy(shop_id, rows[i]["item"])
	last_result = r
	var key := "bought" if r["ok"] else str(r["reason"])
	_set_line(Store.line(shop_id, key))
	_paint()
	_refresh_balance()
	if r["ok"]:
		purchased.emit(shop_id, rows[i]["item"])
	return r


# ── Input ──────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if not is_open or event.is_echo():
		return
	if event.is_action_pressed("ui_up"):
		_select(selected - 1)
	elif event.is_action_pressed("ui_down"):
		_select(selected + 1)
	elif event.is_action_pressed("confirm"):
		buy_row(selected)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
	else:
		return
	get_viewport().set_input_as_handled()
