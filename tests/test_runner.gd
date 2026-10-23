# Headless tests. Run from the project folder:
#   godot --headless --import            (first time only)
#   godot --headless -s res://tests/test_runner.gd
#
# Walks scene_00_opening.dialogue down every branch of the first choice
# and checks that each choice does exactly one thing (spec §2.5).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends SceneTree

var failures := 0
var checks := 0


class StageStub extends RefCounted:
	## Stands in for the opening scene's stage-direction methods.
	var calls: Array[String] = []
	func stage(name: String) -> void: calls.append("stage:" + name)
	func bang() -> void: calls.append("bang")
	func title_smear() -> void: calls.append("title_smear")
	func boram_enters() -> void: calls.append("boram_enters")
	func board_add(n: String) -> void: calls.append("board_add:" + n)
	func board_check(n: String) -> void: calls.append("board_check:" + n)
	func board_wipe() -> void: calls.append("board_wipe")
	func tutorial(t: String) -> void: calls.append("tutorial")
	func teacher_enters() -> void: calls.append("teacher_enters")
	func eunju_stares() -> void: calls.append("eunju_stares")


func _initialize() -> void:
	# Autoloads are ready one frame after start.
	await process_frame
	await _run()
	print("\n%d checks, %d failed" % [checks, failures])
	quit(1 if failures > 0 else 0)


func check(cond: bool, label: String) -> void:
	checks += 1
	if cond:
		print("  ok   ", label)
	else:
		failures += 1
		print("  FAIL ", label)


func _run() -> void:
	var gs = root.get_node("GameState")
	var dm = root.get_node("DialogueManager")
	dm.get_current_scene = func() -> Node: return null

	print("GameState")
	check(gs.card_order.size() == 7, "Act 1 hand has 7 cards")
	check(gs.secrets_held.has("pride"), "starts holding 자존심")
	gs.add_nunchi(9)
	check(gs.nunchi == gs.MAX_NUNCHI, "눈치 caps at %d" % gs.MAX_NUNCHI)
	gs.reset_act()
	gs.start_fight("eunju")
	gs.lose_heart(); gs.lose_heart()
	check(gs.hearts == 1, "hearts go down")
	gs.retry_fight()
	check(gs.hearts == 3, "retry restores 3 hearts")
	gs.reset_act()

	var res = load("res://data/dialogue/scene_00_opening.dialogue")
	check(res != null, "scene_00_opening.dialogue compiles and loads")
	if res == null:
		return

	# Expected effect of each first-choice option (spec §2.5).
	var expectations := [
		{"label": "A 미안해…", "nunchi": 0, "lost": ["pride"]},
		{"label": "B 나 아무 말도 안 했는데?", "nunchi": 0, "lost": []},
		{"label": "C 어? 선생님 오신다!", "nunchi": 1, "lost": []},
	]

	for i in expectations.size():
		var exp: Dictionary = expectations[i]
		print("\nBranch ", exp["label"])
		var stub := StageStub.new()
		var line = await dm.get_next_dialogue_line(res, "start", [stub])
		var spoken: Array[String] = []
		var guard := 0
		while line != null and guard < 200:
			guard += 1
			if line.responses.size() > 0:
				check(line.responses.size() == 3, "first choice offers 3 answers")
				line = await dm.get_next_dialogue_line(res, line.responses[i].next_id, [stub])
				continue
			spoken.append("%s: %s" % [line.character, line.text])
			line = await dm.get_next_dialogue_line(res, line.next_id, [stub])

		check(gs.nunchi == exp["nunchi"], "눈치 = %d" % exp["nunchi"])
		var lost: Array = []
		for c in gs.card_order:
			if not gs.secrets_held.has(c):
				lost.append(c)
		check(lost == exp["lost"], "cards lost = %s" % str(exp["lost"]))
		if exp["lost"].size() > 0:
			check(gs.secrets_known_by.get("pride", []).has("banjang"), "반장 now knows 자존심")
		check(stub.calls.has("bang") and stub.calls.has("title_smear"), "opening cutscene cues fired")
		check(stub.calls.back() == "eunju_stares", "ends on hand-off to 은주")
		check(spoken.has("은주: 네!"), "reaches the attendance hand-off")
		if i == 0:
			print("  -- script as played --")
			for s in spoken:
				print("     ", s)
