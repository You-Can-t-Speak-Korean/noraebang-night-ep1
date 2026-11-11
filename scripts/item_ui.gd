# The item screens: a choice popup (pickups, the inventory's action lists, "read" a note), the
# inventory (Tab), and a short toast. All keyboard (W/S + Enter) or mouse (click); while any of
# them is open `is_open` is true and the owner keeps movement locked.
#
# Korean text is only what the design gives: the messages below, the choice labels and the item
# names. English text in brackets is placeholder.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name ItemUI
extends CanvasLayer

signal opened
signal closed
## An item or note was put down from the inventory; the owner places it in the world.
signal dropped(kind: String, id: String)

const TXT_NO_ROOM := "넣을 데가 없다."
const TXT_NO_NOTEBOOK := "공책이 없다."
const TXT_NOTEBOOK_FULL := "공책이 꽉 찼다."
const TXT_NOT_HURT := "아픈 데가 없다."
const CHOICE_USE_NOW := "지금 쓴다"
const CHOICE_DROP := "버린다"
const CHOICE_THROW_AWAY := "던져버린다"
const CHOICE_KEEP_NOTE := "공책에 넣는다"
const CHOICE_USE := "쓴다"
const CHOICE_READ := "읽는다"
const ACTIONS_HEAL: Array[String] = [CHOICE_USE, CHOICE_DROP]
const ACTIONS_NOTE: Array[String] = [CHOICE_READ, CHOICE_DROP, CHOICE_THROW_AWAY]
const HINT_POPUP := "[placeholder] W/S + Enter, or click"
const HINT_INVENTORY := "[placeholder] Tab / Esc: close   W/S + Enter, or click"
const EMPTY_ROW := "—"
const TOAST_TIME := 1.6
const TOAST_FADE := 0.4
const COLOR_SELECTED := Color(1.0, 0.85, 0.4)
const COLOR_NORMAL := Color(0.92, 0.92, 0.92)
const COLOR_DIM := Color(0.55, 0.55, 0.6)

## The last toast shown and how many there have been (tests read these).
static var last_toast := ""
static var toast_count := 0

## note id -> text, for reading a note (the owner fills it from the spot data).
var note_texts: Dictionary = {}
var is_open := false
var popup_open := false
var inventory_open := false
var popup_title := ""
var popup_body := ""
var popup_choices: Array[String] = []
var popup_selected := 0
var inventory_selected := 0
## The selectable inventory entries, top to bottom: {"type": "heal", "key", "id"} or {"type": "note", "id"}.
var entries: Array[Dictionary] = []

var _popup_callback := Callable()
var _shade: ColorRect
var _popup_panel: PanelContainer
var _popup_title_label: Label
var _popup_body_label: Label
var _popup_buttons_box: VBoxContainer
var _popup_buttons: Array[Button] = []
var _inv_panel: PanelContainer
var _inv_box: VBoxContainer
var _entry_buttons: Array[Button] = []


func _init() -> void:
	layer = 14


## The GameState autoload, looked up at run time (this class is compiled before the autoloads exist
## when a `-s` script such as the test runner names it).
static func _gs() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node("GameState")


func _ready() -> void:
	_shade = ColorRect.new()
	_shade.color = Color(0, 0, 0, 0.55)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.visible = false
	add_child(_shade)
	_inv_panel = _make_panel(Vector2(760, 0))
	_inv_panel.visible = false
	add_child(_inv_panel)
	_inv_box = _inv_panel.get_child(0)
	_popup_panel = _make_panel(Vector2(820, 0))
	_popup_panel.visible = false
	add_child(_popup_panel)
	var box: VBoxContainer = _popup_panel.get_child(0)
	_popup_title_label = Label.new()
	_popup_title_label.add_theme_font_size_override("font_size", 40)
	_popup_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_popup_title_label)
	_popup_body_label = Label.new()
	_popup_body_label.add_theme_font_size_override("font_size", 28)
	_popup_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_popup_body_label)
	_popup_buttons_box = VBoxContainer.new()
	_popup_buttons_box.add_theme_constant_override("separation", 6)
	box.add_child(_popup_buttons_box)
	var hint := Label.new()
	hint.text = HINT_POPUP
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", COLOR_DIM)
	box.add_child(hint)
	_gs().inventory_changed.connect(_on_inventory_changed)


func _make_panel(min_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.09, 0.12, 0.96)
	sb.border_color = Color(0.7, 0.62, 0.4)
	sb.set_border_width_all(3)
	sb.set_content_margin_all(26)
	panel.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	return panel


# ── Open / close ───────────────────────────────────────────────────────

func _sync_open() -> void:
	var now := popup_open or inventory_open
	_shade.visible = now
	_inv_panel.visible = inventory_open
	_popup_panel.visible = popup_open
	if now == is_open:
		return
	is_open = now
	if is_open:
		opened.emit()
	else:
		closed.emit()


## A choice popup: `title` (and an optional `body`), then `choices` to pick with W/S + Enter or a
## click. `callback.call(index)` runs after the popup has closed. With no choices it is a message
## that Enter closes (the callback gets -1).
func show_popup(title: String, body: String, choices: Array, callback: Callable = Callable()) -> void:
	popup_title = title
	popup_body = body
	popup_choices = []
	for c in choices:
		popup_choices.append(str(c))
	popup_selected = 0
	_popup_callback = callback
	_popup_title_label.text = title
	_popup_title_label.visible = title != ""
	_popup_body_label.text = body
	_popup_body_label.visible = body != ""
	for b in _popup_buttons:
		_popup_buttons_box.remove_child(b)
		b.queue_free()
	_popup_buttons = []
	for i in popup_choices.size():
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 34)
		b.mouse_entered.connect(func(): _popup_select(i))
		b.pressed.connect(func(): _popup_choose(i))
		_popup_buttons_box.add_child(b)
		_popup_buttons.append(b)
	popup_open = true
	_paint_popup()
	_sync_open()


func _paint_popup() -> void:
	for i in _popup_buttons.size():
		var on := i == popup_selected
		_popup_buttons[i].text = ("▶ " if on else "   ") + popup_choices[i]
		_popup_buttons[i].add_theme_color_override("font_color", COLOR_SELECTED if on else COLOR_NORMAL)
		_popup_buttons[i].add_theme_color_override("font_hover_color", COLOR_SELECTED if on else COLOR_NORMAL)


func _popup_select(i: int) -> void:
	if popup_open and not popup_choices.is_empty():
		popup_selected = posmod(i, popup_choices.size())
		_paint_popup()


## Picks choice `i` (what Enter and a click call): the popup closes, then the callback runs.
func _popup_choose(i: int) -> void:
	if not popup_open:
		return
	var cb := _popup_callback
	popup_open = false
	_popup_callback = Callable()
	_sync_open()
	if cb.is_valid():
		cb.call(i if i < popup_choices.size() else -1)
	if inventory_open:
		_rebuild_inventory()


## Opens the inventory. False when there is nothing to show (no bag, no notebook).
func open_inventory() -> bool:
	if inventory_open or (not _gs().has_bag() and not _gs().has_notebook()):
		return false
	inventory_open = true
	inventory_selected = 0
	_rebuild_inventory()
	_sync_open()
	return true


func close_inventory() -> void:
	if not inventory_open:
		return
	inventory_open = false
	_sync_open()


## Closes everything without running any callback (a death, a new game).
func reset() -> void:
	popup_open = false
	inventory_open = false
	_popup_callback = Callable()
	_sync_open()


func _on_inventory_changed() -> void:
	if inventory_open:
		_rebuild_inventory()


# ── The inventory screen ───────────────────────────────────────────────

func _label(text: String, size: int, color := COLOR_NORMAL) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _rebuild_inventory() -> void:
	for c in _inv_box.get_children():
		_inv_box.remove_child(c)
		c.queue_free()
	entries = []
	_entry_buttons = []
	_inv_box.add_child(_label("Inventory", 36))
	var inv: Dictionary = _gs().inventory
	for g in Inventory.groups(inv):
		var nested: bool = g["key"] == "case"
		_inv_box.add_child(_label("%s%s   %d/%d" % ["    " if nested else "", Items.item_name(g["id"]), g["used"], g["capacity"]], 28, COLOR_SELECTED))
		var shown := 0
		for stack in _stacks(g["items"]):
			_add_entry({"type": "heal", "key": g["key"], "id": stack["id"]}, "%s%s" % ["    " if nested else "", _stack_text(stack)])
			shown += 1
		if g["key"] == "bag" and Inventory.nested_size(inv) > 0:
			# The nested bag is its own group below; here it only takes up room.
			_inv_box.add_child(_label("%s [%d slots]" % [Items.item_name(inv["case"]), Inventory.nested_size(inv)], 26, COLOR_DIM))
			shown += Inventory.nested_size(inv)
		var free := maxi(int(g["capacity"]) - shown, 0)
		if free > 0:
			_inv_box.add_child(_label("%s%s%s" % ["    " if nested else "", EMPTY_ROW, " ×%d" % free if free > 1 else ""], 26, COLOR_DIM))
	if _gs().has_notebook():
		var pages := Inventory.notebook_pages(inv)
		_inv_box.add_child(_label("%s   %d/%d" % [Items.item_name(inv["notebook"]), _gs().notes.size(), pages], 28, COLOR_SELECTED))
		for p in pages:
			if p < _gs().notes.size():
				var id: String = _gs().notes[p]
				_add_entry({"type": "note", "id": id}, "%d. %s" % [p + 1, _excerpt(id)])
			else:
				_inv_box.add_child(_label("%d. %s" % [p + 1, EMPTY_ROW], 26, COLOR_DIM))
	var hint := _label(HINT_INVENTORY, 20, COLOR_DIM)
	_inv_box.add_child(hint)
	inventory_selected = clampi(inventory_selected, 0, maxi(entries.size() - 1, 0))
	_paint_entries()


func _add_entry(entry: Dictionary, text: String) -> void:
	var i := entries.size()
	entries.append(entry)
	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.flat = true
	b.add_theme_font_size_override("font_size", 28)
	b.set_meta("text", text)
	b.mouse_entered.connect(func(): _entry_select(i))
	b.pressed.connect(func(): _entry_activate(i))
	_inv_box.add_child(b)
	_entry_buttons.append(b)


func _paint_entries() -> void:
	for i in _entry_buttons.size():
		var on := i == inventory_selected
		_entry_buttons[i].text = ("▶ " if on else "   ") + str(_entry_buttons[i].get_meta("text"))
		_entry_buttons[i].add_theme_color_override("font_color", COLOR_SELECTED if on else COLOR_NORMAL)
		_entry_buttons[i].add_theme_color_override("font_hover_color", COLOR_SELECTED if on else COLOR_NORMAL)


## One row per slot: [{"id", "count"}].
func _stacks(items: Array) -> Array:
	var counts := {}
	var order: Array = []
	for id in items:
		if not counts.has(id):
			order.append(id)
		counts[id] = int(counts.get(id, 0)) + 1
	var out: Array = []
	for id in order:
		var left: int = counts[id]
		while left > 0:
			var n := mini(left, Items.stack_max(str(id)))
			out.append({"id": id, "count": n})
			left -= n
	return out


func _stack_text(stack: Dictionary) -> String:
	var text := Items.item_name(stack["id"])
	return text if int(stack["count"]) <= 1 else "%s ×%d" % [text, stack["count"]]


func _excerpt(note_id: String) -> String:
	var text := str(note_texts.get(note_id, note_id)).replace("\n", " ")
	return text if text.length() <= 44 else text.substr(0, 43) + "…"


func _entry_select(i: int) -> void:
	if inventory_open and not popup_open and not entries.is_empty():
		inventory_selected = posmod(i, entries.size())
		_paint_entries()


## Enter or a click on entry `i`: its action list.
func _entry_activate(i: int) -> void:
	if not inventory_open or popup_open or i < 0 or i >= entries.size():
		return
	inventory_selected = i
	var entry := entries[i]
	if entry["type"] == "heal":
		show_popup(Items.item_name(entry["id"]), "", ACTIONS_HEAL, func(c): _heal_action(entry, c))
	else:
		show_popup(_excerpt(entry["id"]), "", ACTIONS_NOTE, func(c): _note_action(entry, c))


func _heal_action(entry: Dictionary, choice: int) -> void:
	match choice:
		0:
			if not _gs().apply_heal_item(entry["id"]):
				toast(TXT_NOT_HURT)
			else:
				_gs().take_out_item(entry["key"], entry["id"])
		1:
			if _gs().take_out_item(entry["key"], entry["id"]):
				dropped.emit("item", entry["id"])


func _note_action(entry: Dictionary, choice: int) -> void:
	var id: String = entry["id"]
	match choice:
		0:
			show_popup(Items.item_name(_gs().inventory["notebook"]), str(note_texts.get(id, id)), [])
		1:
			if _gs().remove_note(id):
				dropped.emit("note", id)
		2:
			_gs().destroy_note(id)


# ── Input ──────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if not is_open or event.is_echo():
		return
	if popup_open:
		if event.is_action_pressed("ui_up"):
			_popup_select(popup_selected - 1)
		elif event.is_action_pressed("ui_down"):
			_popup_select(popup_selected + 1)
		elif event.is_action_pressed("confirm"):
			_popup_choose(popup_selected if not popup_choices.is_empty() else -1)
		else:
			return
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_up"):
		_entry_select(inventory_selected - 1)
	elif event.is_action_pressed("ui_down"):
		_entry_select(inventory_selected + 1)
	elif event.is_action_pressed("confirm"):
		_entry_activate(inventory_selected)
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_TAB or event.keycode == KEY_ESCAPE):
		close_inventory()
	else:
		return
	get_viewport().set_input_as_handled()


# ── Quick heal and toast ───────────────────────────────────────────────

## The E key: uses one health item (GameState.quick_heal) and says what happened in a toast.
## Returns GameState.quick_heal's result.
static func do_quick_heal(host: Node) -> Dictionary:
	var r: Dictionary = _gs().quick_heal()
	match r["result"]:
		"healed":
			show_toast(host, "%s [placeholder: used]" % Items.item_name(r["item"]))
		"full":
			show_toast(host, TXT_NOT_HURT)
		_:
			show_toast(host, "Nothing to use [placeholder]")
	return r



func toast(text: String) -> void:
	show_toast(self, text)


## A short line near the bottom of the screen that fades by itself. `host` is any node (a fight,
## the map); it gets one toast layer. `last_toast` / `toast_count` record what was shown.
static func show_toast(host: Node, text: String) -> void:
	last_toast = text
	toast_count += 1
	var layer_node: CanvasLayer = host.get_node_or_null("ToastLayer")
	if layer_node == null:
		layer_node = CanvasLayer.new()
		layer_node.name = "ToastLayer"
		layer_node.layer = 20
		host.add_child(layer_node)
		var l := Label.new()
		l.name = "Toast"
		l.add_theme_font_size_override("font_size", 40)
		l.add_theme_color_override("font_color", COLOR_SELECTED)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 12)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		l.grow_horizontal = Control.GROW_DIRECTION_BOTH
		l.grow_vertical = Control.GROW_DIRECTION_BEGIN
		l.offset_top = -330
		l.offset_bottom = -330
		layer_node.add_child(l)
	var label: Label = layer_node.get_node("Toast")
	label.text = text
	label.modulate.a = 1.0
	if label.has_meta("tween"):
		var old: Tween = label.get_meta("tween")
		if old != null and old.is_valid():
			old.kill()
	var tween := label.create_tween()
	label.set_meta("tween", tween)
	tween.tween_interval(TOAST_TIME)
	tween.tween_property(label, "modulate:a", 0.0, TOAST_FADE)
