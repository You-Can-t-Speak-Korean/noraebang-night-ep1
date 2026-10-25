# SCENE 00 — OPENING
# Plays data/dialogue/scene_00_opening.dialogue. The dialogue file drives
# everything; the methods below are its stage directions ($> stage("…") etc.).
# All visuals are code-drawn placeholders until the art style test lands.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

const DIALOGUE := preload("res://data/dialogue/scene_00_opening.dialogue")
const TITLE_FONT := preload("res://art/fonts/Galmuri11-Bold.ttf")

const BLOOD := Color(0.62, 0.02, 0.04)
const SKIN_K := Color(0.96, 0.8, 0.65)
const SKIN_BORAM := Color(0.55, 0.36, 0.24)

var world: Node2D
var ui: CanvasLayer
var hud: Hud
var box: DialogueBox

var dinner: Node2D
var classroom: Node2D
var park: Puppet
var singer: Puppet
var boram: Puppet
var eunju: Puppet
var banjang: Puppet
var teacher: Puppet
var board_names: Label
var tv_screen: ColorRect
var tutorial_label: Label
var splatter: Node2D
var _shake := 0.0
var _kids: Array[Puppet] = []


func _ready() -> void:
	world = Node2D.new()
	add_child(world)
	ui = CanvasLayer.new()
	add_child(ui)

	_build_dinner()
	_build_classroom()

	hud = Hud.new()
	hud.visible = false
	ui.add_child(hud)

	box = DialogueBox.new()
	ui.add_child(box)
	box.choice_made.connect(func(_t): _hide_tutorial())

	await get_tree().process_frame
	await box.run(DIALOGUE, "start", [self])
	await _end_card()


func _process(delta: float) -> void:
	if _shake > 0.0:
		_shake = maxf(_shake - delta * 30.0, 0.0)
		world.position = Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))
	# kids fidget with 딱지
	if classroom.visible and randf() < 0.04 and _kids.size() > 0:
		var k: Puppet = _kids.pick_random()
		var y := k.position.y
		var t := create_tween()
		t.tween_property(k, "position:y", y - 3, 0.08)
		t.tween_property(k, "position:y", y, 0.08)
	if tv_screen and classroom.visible:
		tv_screen.color = Color.from_hsv(0, 0, randf_range(0.55, 0.7))


# ══ Stage directions called from the .dialogue file ══════════════════

func stage(set_name: String) -> void:
	dinner.visible = set_name == "dinner"
	classroom.visible = set_name == "classroom"
	hud.visible = set_name == "classroom"
	if set_name == "dinner":
		var fade := _overlay(Color.BLACK)
		var t := create_tween()
		t.tween_property(fade, "modulate:a", 0.0, 1.5)
		t.tween_callback(fade.queue_free)
		await t.finished


func bang() -> void:
	var flash := _overlay(Color.WHITE)
	park.lose_head()
	_shake = 10.0
	# fountain from the neck
	var p := CPUParticles2D.new()
	p.position = park.neck()
	p.amount = 160
	p.lifetime = 1.4
	p.one_shot = true
	p.explosiveness = 0.85
	p.direction = Vector2(0, -1)
	p.spread = 35.0
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 260.0
	p.gravity = Vector2(0, 420)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0
	p.color = BLOOD
	dinner.add_child(p)
	p.emitting = true
	# the wall gets painted
	for i in 40:
		splatter.set_meta("dots", splatter.get_meta("dots", []) + [[
			park.neck() + Vector2(randf_range(-90, 90), randf_range(-120, 10)),
			randf_range(1.5, 6.0)]])
	splatter.queue_redraw()
	var t := create_tween()
	t.tween_property(flash, "modulate:a", 0.0, 0.25)
	t.tween_callback(flash.queue_free)
	await get_tree().create_timer(1.6).timeout


func title_smear() -> void:
	# A bloody hand-wipe sweeps across, revealing the title.
	var smear := Control.new()
	smear.size = Vector2(640, 360)
	ui.add_child(smear)
	var red := ColorRect.new()
	red.color = BLOOD
	red.size = Vector2(0, 360)
	smear.add_child(red)
	var drips: Array[ColorRect] = []
	for i in 22:
		var d := ColorRect.new()
		d.color = BLOOD.darkened(randf_range(0.0, 0.3))
		d.size = Vector2(randf_range(6, 16), randf_range(10, 60))
		d.position = Vector2(randf_range(0, 640), randf_range(-20, 200))
		d.modulate.a = 0.0
		smear.add_child(d)
		drips.append(d)

	var title := Label.new()
	title.text = "노래방 나이트"
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(640, 60)
	title.position = Vector2(0, 120)
	title.modulate.a = 0.0
	smear.add_child(title)
	var sub: Label = title.duplicate()
	sub.text = "국민학교 시대"
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_constant_override("outline_size", 6)
	sub.position = Vector2(0, 186)
	smear.add_child(sub)

	var t := create_tween()
	t.tween_property(red, "size:x", 640.0, 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_callback(func():
		dinner.visible = false
		for d in drips: d.modulate.a = 1.0)
	t.tween_property(title, "modulate:a", 1.0, 0.4)
	t.parallel().tween_property(sub, "modulate:a", 1.0, 0.4).set_delay(0.3)
	t.tween_interval(2.2)
	await t.finished
	# the blood slides off the screen
	var t2 := create_tween().set_parallel()
	t2.tween_property(red, "position:y", 380.0, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	for d in drips:
		t2.tween_property(d, "position:y", 380.0 + randf_range(0, 60), 1.1)
	t2.tween_property(title, "modulate:a", 0.0, 0.5).set_delay(0.5)
	t2.tween_property(sub, "modulate:a", 0.0, 0.5).set_delay(0.5)
	await t2.finished
	smear.queue_free()


func boram_enters() -> void:
	boram.visible = true
	boram.position = Vector2(610, 205)
	var t := create_tween()
	t.tween_property(boram, "position:x", 560.0, 0.8)
	await t.finished
	# the 반장 looks, turns, writes
	banjang.face(1)
	await get_tree().create_timer(0.5).timeout
	banjang.face(-1)


func board_add(student: String) -> void:
	await _chalk(func(): board_names.text += "\n" + student)


func board_check(student: String) -> void:
	await _chalk(func(): board_names.text = board_names.text.replace(student, student + " V V"))


func board_wipe() -> void:
	# He panics, wipes the board with his sleeve, runs to his seat.
	var t := create_tween()
	t.tween_property(board_names, "modulate:a", 0.0, 0.5)
	t.parallel().tween_property(banjang, "position:x", banjang.position.x + 10, 0.08).set_trans(Tween.TRANS_SINE)
	t.tween_property(banjang, "position", Vector2(268, 232), 0.4)
	await t.finished


func tutorial(text: String) -> void:
	tutorial_label.text = text
	tutorial_label.visible = true
	var t := create_tween()
	t.tween_property(tutorial_label, "modulate:a", 1.0, 0.3)
	await t.finished


func teacher_enters() -> void:
	teacher.visible = true
	teacher.position = Vector2(620, 207)
	var t := create_tween()
	t.tween_property(teacher, "position:x", 470.0, 0.9)
	t.parallel().tween_property(boram, "position", Vector2(400, 232), 0.6)
	if banjang.position.x < 240:
		t.parallel().tween_property(banjang, "position", Vector2(268, 232), 0.5)
	await t.finished


func eunju_stares() -> void:
	eunju.face(1)
	var mark := Label.new()
	mark.text = "!"
	mark.add_theme_font_size_override("font_size", 24)
	mark.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	mark.add_theme_color_override("font_outline_color", Color.BLACK)
	mark.add_theme_constant_override("outline_size", 4)
	mark.position = eunju.head_top() + Vector2(-4, -28)
	classroom.add_child(mark)
	_shake = 3.0
	await get_tree().create_timer(1.4).timeout


# ══ Helpers ═══════════════════════════════════════════════════════════

func _chalk(change: Callable) -> void:
	banjang.face(-1)
	var x := banjang.position.x
	var t := create_tween()
	for i in 3:
		t.tween_property(banjang, "position:x", x - 3, 0.07)
		t.tween_property(banjang, "position:x", x, 0.07)
	t.tween_callback(change)
	await t.finished


func _hide_tutorial() -> void:
	if tutorial_label.visible:
		var t := create_tween()
		t.tween_property(tutorial_label, "modulate:a", 0.0, 0.4)
		t.tween_callback(func(): tutorial_label.visible = false)


func _overlay(color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.size = Vector2(640, 360)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(r)
	ui.move_child(r, 0)
	return r


func _rect(parent: Node, pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size = size
	r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


func _text(parent: Node, pos: Vector2, text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l


func _puppet(parent: Node, pos: Vector2, props: Dictionary) -> Puppet:
	var p := Puppet.new()
	p.position = pos
	for k in props:
		p.set(k, props[k])
	parent.add_child(p)
	return p


func _build_dinner() -> void:
	dinner = Node2D.new()
	world.add_child(dinner)
	_rect(dinner, Vector2.ZERO, Vector2(640, 360), Color(0.12, 0.07, 0.05))         # wall
	_rect(dinner, Vector2(0, 250), Vector2(640, 110), Color(0.2, 0.12, 0.07))       # floor
	for x in [80, 520]:                                                             # folding screens
		_rect(dinner, Vector2(x, 60), Vector2(50, 180), Color(0.35, 0.25, 0.12))
		_rect(dinner, Vector2(x + 6, 70), Vector2(38, 160), Color(0.75, 0.66, 0.45))
	var lamp := Node2D.new()
	lamp.position = Vector2(320, 40)
	lamp.draw.connect(func(): lamp.draw_circle(Vector2.ZERO, 120, Color(1, 0.8, 0.4, 0.12)))
	dinner.add_child(lamp)
	splatter = Node2D.new()
	splatter.draw.connect(func():
		for d in splatter.get_meta("dots", []):
			splatter.draw_circle(d[0], d[1], BLOOD))
	dinner.add_child(splatter)
	# men in suits in the back
	for x in [190, 240, 400, 450]:
		_puppet(dinner, Vector2(x, 225), {"clothes": Color(0.1, 0.1, 0.12), "height": 40.0})
	park = _puppet(dinner, Vector2(300, 240), {"clothes": Color(0.15, 0.15, 0.18), "height": 44.0, "sunglasses": true})
	singer = _puppet(dinner, Vector2(350, 240), {"clothes": Color(0.6, 0.1, 0.25), "height": 40.0, "hair": Color(0.05, 0.03, 0.02)})
	singer.face(-1)
	_rect(dinner, Vector2(340, 205), Vector2(26, 10), Color(0.55, 0.35, 0.15))       # guitar
	_rect(dinner, Vector2(160, 240), Vector2(320, 26), Color(0.32, 0.18, 0.08))      # table
	for x in [200, 230, 410, 440]:                                                  # 양주 bottles
		_rect(dinner, Vector2(x, 222), Vector2(8, 18), Color(0.45, 0.25, 0.05))
	dinner.visible = false


func _build_classroom() -> void:
	# Layout keeps everyone above y = 266, where the dialogue box starts.
	classroom = Node2D.new()
	world.add_child(classroom)
	_rect(classroom, Vector2.ZERO, Vector2(640, 360), Color(0.86, 0.82, 0.68))      # wall
	_rect(classroom, Vector2(0, 196), Vector2(640, 164), Color(0.55, 0.38, 0.22))   # wooden floor
	_rect(classroom, Vector2(110, 36), Vector2(300, 148), Color(0.36, 0.3, 0.2))    # board frame
	_rect(classroom, Vector2(116, 42), Vector2(288, 136), Color(0.13, 0.3, 0.2))    # blackboard
	var chalk := Color(0.95, 0.95, 0.9)
	_text(classroom, Vector2(126, 44), "떠든 사람", 12, chalk)
	board_names = _text(classroom, Vector2(126, 60), "박철수\n이영희\n최민수\n김영수\n정미경\n오동진", 12, chalk)
	board_names.size = Vector2(160, 118)
	_text(classroom, Vector2(330, 44), "10월 27일\n토요일", 12, chalk)
	# 태극기 on the wall between board and TV
	_rect(classroom, Vector2(420, 40), Vector2(24, 16), Color.WHITE)
	_rect(classroom, Vector2(428, 44), Vector2(8, 8), Color(0.8, 0.1, 0.15))
	# black-and-white TV on a shelf
	_rect(classroom, Vector2(456, 48), Vector2(80, 62), Color(0.3, 0.2, 0.12))
	_rect(classroom, Vector2(450, 110), Vector2(92, 7), Color(0.4, 0.28, 0.16))
	tv_screen = _rect(classroom, Vector2(463, 55), Vector2(58, 44), Color(0.6, 0.6, 0.6))
	_rect(classroom, Vector2(481, 74), Vector2(22, 25), Color(0.2, 0.2, 0.2))        # anchor
	_rect(classroom, Vector2(486, 64), Vector2(12, 11), Color(0.35, 0.35, 0.35))
	# door
	_rect(classroom, Vector2(572, 70), Vector2(58, 136), Color(0.45, 0.32, 0.18))
	_rect(classroom, Vector2(580, 80), Vector2(42, 46), Color(0.75, 0.85, 0.9))
	# 조개탄 stove and its pipe
	_rect(classroom, Vector2(24, 160), Vector2(34, 44), Color(0.15, 0.15, 0.15))
	_rect(classroom, Vector2(35, 40), Vector2(10, 120), Color(0.25, 0.25, 0.25))
	# 반장 at the board
	banjang = _puppet(classroom, Vector2(380, 205), {"skin": SKIN_K, "clothes": Color(0.2, 0.3, 0.6), "height": 30.0})
	banjang.face(-1)
	# two rows of kids at their desks
	for row in 2:
		for i in 7:
			var x := 90 + i * 66 + row * 22
			var y := 236 + row * 28
			if row == 0 and i == 2:
				continue  # 은주's seat
			var k := _puppet(classroom, Vector2(x, y), {"skin": SKIN_K,
				"clothes": Color.from_hsv(randf(), 0.35, randf_range(0.4, 0.7)), "height": 22.0})
			_kids.append(k)
			_rect(classroom, Vector2(x - 18, y - 9), Vector2(36, 7), Color(0.62, 0.45, 0.25))  # desk
	eunju = _puppet(classroom, Vector2(222, 236), {"skin": SKIN_K, "clothes": Color(0.95, 0.5, 0.65),
		"height": 22.0, "pigtails": true})
	eunju.face(-1)
	_rect(classroom, Vector2(204, 227), Vector2(36, 7), Color(0.62, 0.45, 0.25))
	boram = _puppet(classroom, Vector2(610, 205), {"skin": SKIN_BORAM, "clothes": Color(0.85, 0.75, 0.3),
		"height": 26.0, "curly": true})
	boram.face(-1)
	boram.visible = false
	teacher = _puppet(classroom, Vector2(620, 207), {"skin": SKIN_K, "clothes": Color(0.35, 0.3, 0.25), "height": 40.0})
	teacher.face(-1)
	teacher.visible = false

	tutorial_label = Label.new()
	tutorial_label.add_theme_font_size_override("font_size", 12)
	tutorial_label.add_theme_color_override("font_color", Color(1, 0.95, 0.6))
	tutorial_label.add_theme_color_override("font_outline_color", Color.BLACK)
	tutorial_label.add_theme_constant_override("outline_size", 4)
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.size = Vector2(640, 20)
	tutorial_label.position = Vector2(0, 24)
	tutorial_label.modulate.a = 0.0
	tutorial_label.visible = false
	ui.add_child(tutorial_label)
	classroom.visible = false


func _end_card() -> void:
	var card := _overlay(Color.BLACK)
	ui.move_child(card, -1)
	card.modulate.a = 0.0
	var l := _text(card, Vector2(0, 130), "다음: SCENE 01 — 김은주\n\"너 어디서 왔어?\"", 22, Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(640, 60)
	var again := Button.new()
	again.text = "처음부터 다시"
	again.position = Vector2(260, 230)
	again.custom_minimum_size = Vector2(120, 32)
	again.pressed.connect(func(): get_tree().reload_current_scene())
	card.add_child(again)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(card, "modulate:a", 1.0, 1.0)
	await t.finished
