# Headless test runner. Exits non-zero on any failure.
#   godot --headless --import            (first time only)
#   godot --headless --path . -s res://tests/run_tests.gd
#
# Expected log noise (these tests deliberately trigger them): one push_error for
# an unknown card id, one for end_fight with a bad outcome, one for retry_fight
# outside a fight, and push_warnings for damage/heal/add_nunchi/spend_nunchi with
# values <= 0.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends SceneTree

const GameStateScript := preload("res://scripts/game_state.gd")
const SAVE_DIR := "user://test_saves"

var failures := 0
var checks := 0


func _initialize() -> void:
	await process_frame
	_test_hearts()
	_test_nunchi()
	_test_secrets()
	_test_fights()
	_test_resets()
	_test_saves()
	_test_helpers()
	_test_project()
	await _test_stage()
	_test_movement_pure()
	await _test_player()
	_test_map_graph()
	await _test_map_walk()
	print("\n%d checks, %d failed" % [checks, failures])
	quit(1 if failures > 0 else 0)


func check(cond: bool, label: String) -> void:
	checks += 1
	if cond:
		print("  ok   ", label)
	else:
		failures += 1
		print("  FAIL ", label)


func make_gs() -> Node:
	var gs: Node = GameStateScript.new()
	gs.load_data()
	gs.new_game()
	return gs


func same(a: Variant, b: Variant) -> bool:
	return JSON.stringify(a) == JSON.stringify(b)


## Counts signal emissions by name.
func watch(gs: Node, names: Array) -> Dictionary:
	var counts := {}
	for n in names:
		counts[n] = 0
		var sig: Signal = gs.get(n)
		sig.connect(func(_a = null, _b = null): counts[n] += 1)
	return counts


# ── Hearts ─────────────────────────────────────────────────────────────

func _test_hearts() -> void:
	print("Hearts")
	var gs := make_gs()
	check(gs.hearts_halves == 10 and gs.hearts_max_halves == 10, "starts at 10 halves (tuning)")
	var c := watch(gs, ["player_died", "fight_lost", "hearts_changed"])
	gs.damage(1)
	check(gs.hearts_halves == 9, "damage counts halves")
	gs.heal(5)
	check(gs.hearts_halves == 10, "heal clamps to max")
	gs.damage(0)
	gs.damage(-3)
	gs.heal(0)
	check(gs.hearts_halves == 10, "damage/heal <= 0 ignored")
	gs.damage(4)
	gs.damage(100)
	check(gs.hearts_halves == 0, "damage clamps at 0")
	check(c["player_died"] == 1 and c["fight_lost"] == 0, "player_died fires once on transition to 0")
	gs.damage(2)
	check(c["player_died"] == 1, "no second player_died when damage lands at 0")
	gs.heal(3)
	gs.damage(3)
	check(c["player_died"] == 2, "fires again after healing and dying again")
	gs.new_game()
	var c2 := watch(gs, ["player_died", "fight_lost"])
	gs.begin_fight("eunju")
	gs.damage(10)
	check(c2["fight_lost"] == 1 and c2["player_died"] == 0, "fight_lost instead of player_died in a fight")
	gs.damage(1)
	check(c2["fight_lost"] == 1, "fight_lost not repeated at 0")
	check(gs.hearts_halves == 0 and gs.in_fight, "GameState never resets itself on death")
	gs.free()


# ── Nunchi ─────────────────────────────────────────────────────────────

func _test_nunchi() -> void:
	print("Nunchi")
	var gs := make_gs()
	check(gs.add_nunchi(3) == 0 and gs.nunchi == 3, "adds below cap, no overflow")
	var over: int = gs.add_nunchi(6)
	check(gs.nunchi == 7 and over == 2, "caps at 7, returns overflow 2")
	check(gs.ddeok == 2, "overflow becomes DDEOK at 1 per point")
	gs.nunchi_overflow_ddeok_per_point = 3
	gs.add_nunchi(2)
	check(gs.ddeok == 8, "overflow uses the tuned rate")
	check(gs.add_nunchi(0) == 0 and gs.nunchi == 7, "add_nunchi(0) ignored")
	check(gs.spend_nunchi(3) and gs.nunchi == 4, "spend_nunchi succeeds when enough")
	check(not gs.spend_nunchi(5) and gs.nunchi == 4, "spend_nunchi fails when short, spends nothing")
	check(not gs.spend_nunchi(0), "spend_nunchi(0) is false")
	gs.add_ddeok(5)
	check(gs.ddeok == 13, "add_ddeok")
	gs.free()


# ── Secrets ────────────────────────────────────────────────────────────

func _test_secrets() -> void:
	print("Secrets")
	var gs := make_gs()
	check(gs.hand.size() == 7 and gs.secrets_held == gs.hand, "starts holding the 7-card Act 1 hand")
	check(gs.has_secret("pride"), "has_secret")
	var lost := watch(gs, ["secret_lost"])
	var got_args := []
	gs.secret_lost.connect(func(card, by): got_args.append([card, by]))
	check(gs.lose_secret("pride", "banjang"), "held card: returns true")
	check(not gs.has_secret("pride") and lost["secret_lost"] == 1, "held card removed, signal emitted")
	check(got_args == [["pride", "banjang"]], "signal carries card and knower")
	check(gs.knows("banjang", "pride"), "explicit knower learns it")

	check(not gs.lose_secret("pride", "banjang") and lost["secret_lost"] == 1, "already-lost: false, no signal")
	check(not gs.lose_secret("pride", "banjang") and gs.secrets_known_by["pride"].size() == 1, "no duplicate knowers")
	gs.lose_secret("pride", "eunju")
	check(gs.knows("eunju", "pride") and lost["secret_lost"] == 1, "already-lost card still taught to a new person, no signal")

	gs.set_boss("teacher")
	gs.lose_secret("our_home")
	check(gs.knows("teacher", "our_home"), "empty 'by' uses current_boss")
	gs.current_boss = ""
	gs.lose_secret("mom_job")
	check(not gs.has_secret("mom_job") and not gs.secrets_known_by.has("mom_job"), "no by, no boss: lost but nobody learns it")
	check(got_args.back() == ["mom_job", ""], "signal still fires with empty knower")

	gs.lose_secret("dad_story", "hyunjeong")
	check(gs.knows("hyunjeong", "dad_story") and gs.knows("hyunjeong_mom", "dad_story"), "one-hop leak: hyunjeong -> hyunjeong_mom")
	gs.leaks["hyunjeong_mom"] = ["hyunjeong_dad"]
	gs.lose_secret("dad_country", "hyunjeong")
	check(not gs.knows("hyunjeong_dad", "dad_country"), "leak is not transitive")
	gs.leaks.erase("hyunjeong_mom")

	check(not gs.lose_secret("not_a_card", "x"), "unknown card id: false")
	check(not gs.secrets_known_by.has("not_a_card"), "unknown card id changes nothing")

	gs.lose_secret("mom_salary", "banjang")
	check(same(gs.cards_known_by("banjang"), ["mom_salary", "pride"]), "cards_known_by in hand order (mom_salary before pride)")
	check(gs.cards_known_by("nobody").is_empty(), "cards_known_by unknown person is empty")
	gs.free()


# ── Fights ─────────────────────────────────────────────────────────────

func _test_fights() -> void:
	print("Fights")
	var gs := make_gs()
	gs.add_nunchi(4)
	gs.damage(3)
	gs.begin_fight("eunju")
	check(gs.in_fight and gs.current_boss == "eunju", "begin_fight sets boss and flag")
	gs.damage(4)
	gs.spend_nunchi(3)
	check(gs.retry_fight(), "retry_fight succeeds in a fight")
	check(gs.hearts_halves == 7 and gs.nunchi == 4, "retry restores hearts and 눈치")
	check(gs.in_fight, "still in fight after retry")
	gs.damage(2)
	gs.end_fight("eunju", "survival", 50)
	check(not gs.in_fight and gs.fight_snapshot.is_empty(), "end_fight clears flag and snapshot")
	check(gs.hearts_halves == 5, "survival restores nothing")
	check(gs.scores["eunju"] == 50 and gs.outcomes["eunju"] == "survival", "records score and outcome")
	gs.end_fight("eunju", "survival", 30)
	check(gs.scores["eunju"] == 50, "scores keeps the best")
	gs.end_fight("eunju", "survival", 80)
	check(gs.scores["eunju"] == 80, "higher score replaces")
	gs.end_fight("eunju", "revenge", 10)
	check(gs.outcomes["eunju"] == "revenge" and gs.scores["eunju"] == 80, "revenge beats survival, score stays best")
	check(gs.hearts_halves == 10, "revenge heals to full")
	gs.end_fight("eunju", "survival", 90)
	check(gs.outcomes["eunju"] == "revenge", "survival never overwrites revenge")
	check(not gs.end_fight("eunju", "draw", 1), "invalid outcome rejected")
	check(gs.scores["eunju"] == 90, "rejected call changed nothing")
	var fresh := make_gs()
	check(not fresh.retry_fight(), "retry_fight outside a fight is rejected")
	fresh.free()
	gs.free()


# ── Resets ─────────────────────────────────────────────────────────────

func _dirty(gs: Node) -> void:
	gs.damage(4)
	gs.add_nunchi(9)
	gs.add_ddeok(3)
	gs.lose_secret("pride", "hyunjeong")
	gs.spawn_seed = 12345
	gs.mark_collected("map1-day2", "coin")
	gs.add_note("n")
	gs.mark_talked("t")
	gs.add_item("i")
	gs.end_fight("eunju", "revenge", 5)
	gs.set_progress("scene_09")
	gs.unlock_codex("c")
	gs.begin_fight("banjang")


func _test_resets() -> void:
	print("Resets")
	var gs := make_gs()
	var defaults: Dictionary = gs._default_state()
	check(defaults.size() == 17, "default state has all 17 saved fields")
	_dirty(gs)
	var died := watch(gs, ["state_reset"])
	gs.death_reset()
	for key in defaults:
		if key == "progress":
			continue
		check(var_to_str(gs.get(key)) == var_to_str(defaults[key]), "death_reset restores %s" % key)
	check(gs.progress == "scene_01", "death_reset progress = scene_01")
	check(died["state_reset"] == 1, "death_reset emits state_reset")
	check(gs.leaks.has("hyunjeong"), "leaks (data) untouched by reset")
	_dirty(gs)
	gs.new_game()
	for key in defaults:
		if key == "progress":
			continue
		check(var_to_str(gs.get(key)) == var_to_str(defaults[key]), "new_game restores %s" % key)
	check(gs.progress == "scene_00", "new_game progress = scene_00")
	check(GameStateScript.PERSISTS_THROUGH_DEATH.is_empty(), "PERSISTS_THROUGH_DEATH is empty for now")
	_dirty(gs)
	gs._death_reset_keeping(["ddeok", "notes", "scores"] as Array[String])
	check(gs.ddeok == 5 and same(gs.notes, ["n"]) and gs.scores.has("eunju"), "listed fields survive the reset")
	check(gs.nunchi == 0 and gs.hearts_halves == 10 and gs.progress == "scene_01", "unlisted fields still reset")
	gs.free()


# ── Saves ──────────────────────────────────────────────────────────────

func _clean_saves() -> void:
	var dir := DirAccess.open(SAVE_DIR)
	if dir:
		for f in dir.get_files():
			dir.remove(f)
		DirAccess.remove_absolute(SAVE_DIR)


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path)


func _state_str(gs: Node) -> String:
	return JSON.stringify(gs._current_state(), "", true)


func _test_saves() -> void:
	print("Saves")
	_clean_saves()
	var gs := make_gs()
	gs.save_path = SAVE_DIR + "/save.json"
	check(not gs.has_save(), "has_save false before saving")
	check(gs.load_game() == ERR_FILE_NOT_FOUND, "load with no file -> ERR_FILE_NOT_FOUND")

	_dirty(gs)
	var before := _state_str(gs)
	check(gs.save_game() == OK and gs.has_save(), "save_game OK")
	check(not FileAccess.file_exists(gs.save_path + ".tmp"), "atomic write leaves no temp file")
	check(not FileAccess.file_exists(gs.save_path + ".bak"), "no .bak on first save")
	var env = JSON.parse_string(_read(gs.save_path))
	check(env["game"] == "noraebang-night" and int(env["save_version"]) == 1 and env["state_version"] == "0.4", "envelope fields")
	check(not env["state"].has("leaks"), "leaks are not saved")

	var other := make_gs()
	other.save_path = gs.save_path
	check(other.load_game() == OK, "load_game OK")
	check(_state_str(other) == before, "round-trip equality")
	check(other.leaks.has("hyunjeong"), "leaks come from data after load")

	gs.add_ddeok(1)
	var second := _state_str(gs)
	gs.save_game()
	check(FileAccess.file_exists(gs.save_path + ".bak"), ".bak created on second save")
	check(not FileAccess.file_exists(gs.save_path + ".tmp"), "still no temp file")
	var bak = JSON.parse_string(_read(gs.save_path + ".bak"))
	check(int(bak["state"]["ddeok"]) == 5, ".bak holds the previous save")

	# Corrupt main -> falls back to .bak.
	_write(gs.save_path, "{ not json")
	var fallback := make_gs()
	fallback.save_path = gs.save_path
	check(fallback.load_game() == OK and fallback.ddeok == 5, "corrupt JSON falls back to .bak")

	# Both corrupt -> error, state untouched.
	_write(gs.save_path + ".bak", "garbage")
	var untouched := make_gs()
	untouched.save_path = gs.save_path
	untouched.add_ddeok(42)
	var snap := _state_str(untouched)
	check(untouched.load_game() == ERR_FILE_CORRUPT, "both corrupt -> ERR_FILE_CORRUPT")
	check(_state_str(untouched) == snap, "state untouched after failed load")

	# Future version rejected, file untouched.
	var future := JSON.stringify({"game": "noraebang-night", "save_version": 99, "state_version": "9.9", "state": {"ddeok": 5}})
	_write(gs.save_path, future)
	check(untouched.load_game() == ERR_UNAVAILABLE, "future save_version -> ERR_UNAVAILABLE")
	check(_read(gs.save_path) == future and _state_str(untouched) == snap, "future file and state left unchanged")

	# Version 0: bare state dictionary.
	_write(gs.save_path, JSON.stringify({"ddeok": 9, "nunchi": 2, "progress": "scene_03", "hearts_halves": 6}))
	var v0 := make_gs()
	v0.save_path = gs.save_path
	check(v0.load_game() == OK, "version-0 bare dict loads")
	check(v0.ddeok == 9 and v0.nunchi == 2 and v0.progress == "scene_03" and v0.hearts_halves == 6, "version-0 values migrated")
	check(v0.secrets_held == v0.hand, "version-0 missing keys take defaults")
	check(v0._migrate_0_to_1({"a": 1}) == {"a": 1}, "_migrate_0_to_1 exists")

	# Normalisation.
	var messy := {
		"game": "noraebang-night", "save_version": 1, "state_version": "0.4",
		"state": {
			"hearts_halves": 99, "nunchi": -4, "ddeok": -1, "spawn_seed": "x",
			"secrets_held": ["pride", "pride", "bogus", 7, "our_home"],
			"secrets_known_by": {"pride": ["a", "a", 3, "b"], "bogus": ["z"], "our_home": "nope"},
			"notes": ["n", "n", 1], "talked": "oops", "scores": {"eunju": 12.0, "x": "bad"},
			"outcomes": {"eunju": "revenge", "x": "other"}, "progress": 5,
			"in_fight": true, "fight_snapshot": {}, "unknown_key": 1, "leaks": {"a": ["b"]},
			"collected": {"m-1": ["c", "c"]},
		},
	}
	_write(gs.save_path, JSON.stringify(messy))
	var norm := make_gs()
	norm.save_path = gs.save_path
	check(norm.load_game() == OK, "messy save loads")
	check(norm.hearts_halves == 10 and norm.nunchi == 0 and norm.ddeok == 0, "out-of-range numbers clamped")
	check(norm.spawn_seed == 0 and norm.progress == "", "wrong types fall back to defaults")
	check(same(norm.secrets_held, ["pride", "our_home"]), "secrets_held deduped, unknown/non-string dropped")
	check(norm.secrets_known_by == {"pride": ["a", "b"]}, "secrets_known_by cleaned")
	check(same(norm.notes, ["n"]) and norm.talked.is_empty(), "string arrays deduped / type-checked")
	check(norm.scores == {"eunju": 12} and norm.outcomes == {"eunju": "revenge"}, "scores and outcomes cleaned")
	check(not norm.in_fight, "in_fight without a snapshot is dropped")
	check(norm.collected == {"m-1": ["c"]}, "collected deduped")
	check(not ("unknown_key" in norm._current_state()) and norm.leaks.has("hyunjeong") and not norm.leaks.has("a"), "unknown keys dropped, saved leaks ignored")

	gs.free(); other.free(); fallback.free(); untouched.free(); v0.free(); norm.free()
	_clean_saves()
	check(not DirAccess.dir_exists_absolute(SAVE_DIR), "test saves cleaned up")


func _test_helpers() -> void:
	print("Helpers")
	var gs := make_gs()
	gs.add_note("a"); gs.add_note("a")
	check(gs.has_note("a") and gs.notes.size() == 1, "notes")
	gs.mark_talked("x")
	check(gs.has_talked("x") and not gs.has_talked("y"), "talked")
	gs.add_item("red_medicine")
	check(gs.owns_item("red_medicine") and not gs.owns_item("bandage"), "items")
	gs.mark_collected("m1-d1", "k"); gs.mark_collected("m1-d1", "k")
	check(gs.is_collected("m1-d1", "k") and not gs.is_collected("m1-d2", "k") and gs.collected["m1-d1"].size() == 1, "collected")
	gs.unlock_codex("c"); gs.unlock_codex("c")
	check(same(gs.codex, ["c"]), "codex")
	gs.set_progress("scene_05")
	check(gs.progress == "scene_05", "set_progress")
	gs.free()


# ── Project ────────────────────────────────────────────────────────────

func _action_keys(action: String) -> Array:
	var keys := []
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			keys.append(e.physical_keycode if e.physical_keycode != KEY_NONE else e.keycode)
	return keys


func _scan(dir: String, needles: Array, hits: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() in ["ttf", "png", "import", "uid", "ogg", "wav", "mp3"] or f == "run_tests.gd":
			continue
		var text := FileAccess.get_file_as_string(dir.path_join(f))
		for n in needles:
			if text.contains(n):
				hits.append("%s contains %s" % [dir.path_join(f), n])
	for d in DirAccess.get_directories_at(dir):
		_scan(dir.path_join(d), needles, hits)


func _test_project() -> void:
	print("Project")
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "forward_plus", "renderer setting is forward_plus")
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 1920 and ProjectSettings.get_setting("display/window/size/viewport_height") == 1080, "viewport 1920x1080")
	check(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items" and ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "stretch canvas_items / keep")
	var features: PackedStringArray = ProjectSettings.get_setting("application/config/features")
	check(features.has("4.7") and features.has("Forward Plus"), "config/features has 4.7 and Forward Plus")
	var v := Engine.get_version_info()
	print("  engine: %s" % Engine.get_version_info()["string"])
	check(v["major"] == 4 and v["minor"] == 7, "Engine is 4.7.x (patch %d)" % v["patch"])

	var expect := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"confirm": [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
	}
	for action in expect:
		check(InputMap.has_action(action) and _action_keys(action) == expect[action], "input action %s = %s" % [action, expect[action]])
	var up := _action_keys("ui_up")
	var down := _action_keys("ui_down")
	check(up.has(KEY_UP) and up.has(KEY_W), "ui_up has Up and W")
	check(down.has(KEY_DOWN) and down.has(KEY_S), "ui_down has Down and S")
	check(InputMap.action_get_events("ui_up").size() >= 4, "ui_up keeps its joypad defaults")
	var accept := _action_keys("ui_accept")
	check(accept.has(KEY_ENTER) and accept.has(KEY_KP_ENTER) and accept.has(KEY_SPACE), "ui_accept still accepts Enter and Space")
	var press := InputEventKey.new()
	press.keycode = KEY_ENTER
	press.pressed = true
	check(InputMap.event_is_action(press, "ui_accept"), "an Enter key event matches ui_accept")

	check(ProjectSettings.get_setting("gui/theme/custom") == "res://themes/main_theme.tres", "project theme is set")
	var theme := ThemeDB.get_project_theme()
	check(theme != null and theme.default_font != null, "project theme has a default font")
	if theme != null and theme.default_font != null:
		print("  default font name: %s" % theme.default_font.get_font_name())
		check(theme.default_font.resource_path.contains("NotoSansKR") and theme.default_font.get_font_name().contains("Noto Sans"), "default font is Noto Sans KR")

	var hits := []
	var needles := ["Gal" + "muri", "res://" + "legacy"]
	for d in ["res://scenes", "res://scripts", "res://tests", "res://data", "res://themes", "res://art"]:
		_scan(d, needles, hits)
	var proj := FileAccess.get_file_as_string("res://project.godot")
	for n in needles:
		if proj.contains(n):
			hits.append("project.godot contains %s" % n)
	check(hits.is_empty(), "no active file references Galmuri or res://legacy " + str(hits))
	check(FileAccess.file_exists("res://legacy/.gdignore"), "legacy/.gdignore exists")
	check(FileAccess.file_exists("res://docs/.gdignore"), "docs/.gdignore exists")
	check(not DirAccess.dir_exists_absolute("res://art/fonts/Galmuri"), "no Galmuri font dir in active art")


func _test_stage() -> void:
	print("Test stage")
	var packed: PackedScene = load("res://scenes/test_stage.tscn")
	check(packed != null, "test_stage.tscn loads")
	if packed == null:
		return
	var stage := packed.instantiate()
	root.add_child(stage)
	await process_frame
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/map_01.tscn", "Map 01 is the main scene")
	check(stage.find_children("*", "Camera3D", true, false).size() == 1, "exactly one Camera3D")
	check(stage.find_children("*", "Light3D", true, false).size() == 1, "exactly one light")
	var envs := stage.find_children("*", "WorldEnvironment", true, false)
	check(envs.size() == 1, "exactly one WorldEnvironment")
	if envs.size() == 1:
		var e: Environment = envs[0].environment
		check(e.fog_enabled and e.volumetric_fog_enabled, "fog and volumetric fog enabled")
	var capsules := stage.find_children("*", "MeshInstance3D", true, false).filter(func(m): return m.mesh is CapsuleMesh)
	check(capsules.size() == 1, "a capsule (보람)")
	var lights := stage.find_children("*", "Light3D", true, false)
	check(lights[0].shadow_enabled and lights[0].light_volumetric_fog_energy > 0.0, "light has shadows and volumetric energy")
	stage.queue_free()


# ── Walking (Step 2a) ──────────────────────────────────────────────────

const PlayerScene := preload("res://characters/player.tscn")
const PlayerScript := preload("res://scripts/player.gd")
const MAP_DATA := "res://data/maps/map_01.json"


func _frames(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame


func _press(action: String) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await _frames(2)
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)
	await _frames(1)


func _test_movement_pure() -> void:
	print("Lanes (pure)")
	check(PlayerScript.clamp_lane(-1, 3) == 0 and PlayerScript.clamp_lane(0, 3) == 0, "clamp_lane floor")
	check(PlayerScript.clamp_lane(3, 3) == 2 and PlayerScript.clamp_lane(2, 3) == 2, "clamp_lane ceiling")
	check(PlayerScript.clamp_lane(5, 1) == 0, "single lane always 0")
	check(PlayerScript.stepped_lane(0, 1, 3) == 1 and PlayerScript.stepped_lane(1, 1, 3) == 2, "step deeper")
	check(PlayerScript.stepped_lane(2, 1, 3) == 2, "stepping deeper at the last lane stays")
	check(PlayerScript.stepped_lane(0, -1, 3) == 0, "stepping nearer at lane 0 stays")
	check(PlayerScript.stepped_lane(2, -1, 3) == 1, "step nearer")
	var cfg: Dictionary = preload("res://scripts/tuning.gd").lane_config()
	check(cfg["lane_count"] == 3 and is_equal_approx(cfg["lane_spacing"], 1.5), "tuning.json: 3 lanes, spacing 1.5")


func _test_player() -> void:
	print("Player")
	var room: Node3D = load("res://maps/map_01/hallway_1f.tscn").instantiate()
	root.add_child(room)
	var p: Node3D = PlayerScene.instantiate()
	root.add_child(p)
	p.configure_room(room)
	p.place(0.0, 0)
	check(is_equal_approx(p.position.z, room.lane_origin_z), "lane 0 at the room's lane origin")
	check(is_equal_approx(p.lane_z(1), room.lane_origin_z - 1.5), "lane 1 is one spacing deeper")
	p.walk(1.0, 1.0)
	check(is_equal_approx(p.position.x, p.walk_speed), "walk moves along x")
	p.walk(1.0, 100.0)
	check(is_equal_approx(p.position.x, room.bounds_right), "walk clamps at the right bound")
	p.walk(-1.0, 100.0)
	check(is_equal_approx(p.position.x, room.bounds_left), "walk clamps at the left bound")

	p.place(0.0, 0)
	p.step_lane(1)
	p.step_lane(1)
	p.step_lane(1)
	check(p.lane == 2, "lane steps clamp at the deepest lane")
	await _frames(40)
	check(is_equal_approx(p.position.z, p.lane_z(2)), "lane change is smooth and arrives")

	p.movement_locked = true
	var x0: float = p.position.x
	var lane0: int = p.lane
	p.walk(1.0, 1.0)
	p.step_lane(-1)
	check(p.position.x == x0 and p.lane == lane0, "movement_locked blocks walk and lane steps")
	Input.action_press("move_right")
	await _frames(4)
	check(p.position.x == x0, "movement_locked blocks real input")
	p.movement_locked = false
	await _frames(4)
	check(p.position.x > x0, "unlocked: held D moves the player")
	Input.action_release("move_right")
	await _press("move_down")
	check(p.lane == 1, "pressing S steps one lane nearer")
	await _press("move_up")
	check(p.lane == 2, "pressing W steps one lane deeper")
	p.queue_free()
	room.queue_free()
	await _frames(1)


func _door_list(room: Node) -> Array:
	return room.get_children().filter(func(c): return c.has_method("is_door"))


func _test_map_graph() -> void:
	print("Map graph")
	var data = JSON.parse_string(FileAccess.get_file_as_string(MAP_DATA))
	var rooms: Dictionary = data["rooms"]
	check(rooms.size() == 12, "12 rooms registered")
	var scenes := {}
	for id in rooms:
		var packed = load(rooms[id])
		check(packed != null, "room scene loads: %s" % id)
		if packed != null:
			scenes[id] = packed.instantiate()
	check(rooms.has(data["start_room"]) and scenes[data["start_room"]].get_spawn(data["start_spawn"]) != null, "start room and spawn exist")
	var locked := []
	for id in scenes:
		var r: Node = scenes[id]
		check(r.room_id == id, "%s: room_id matches registry" % id)
		check(r.bounds_left < r.bounds_right, "%s: bounds are ordered" % id)
		for d in _door_list(r):
			var tag := "%s -> %s" % [id, d.target_room]
			check(scenes.has(d.target_room), "%s: target room exists" % tag)
			if not scenes.has(d.target_room):
				continue
			var target: Node = scenes[d.target_room]
			var spawn: Node3D = target.get_spawn(d.target_spawn)
			check(spawn != null, "%s: spawn '%s' exists" % [tag, d.target_spawn])
			if spawn != null:
				check(spawn.position.x >= target.bounds_left and spawn.position.x <= target.bounds_right, "%s: spawn is inside bounds" % tag)
			if d.locked:
				locked.append(tag)
			else:
				var back := _door_list(target).filter(func(t): return t.target_room == id)
				check(not back.is_empty(), "%s: has a return door" % tag)
	locked.sort()
	check(locked == ["alley -> stationery", "stairs -> hallway_2f"], "locked doors: 2층 복도 and 문방구 (%s)" % str(locked))
	var classroom: Node = scenes["classroom_1_3"]
	var things := classroom.get_children().filter(func(c): return c.has_method("interact") and not c.has_method("is_door"))
	check(things.size() >= 2, "1학년 3반 has %d sample interactables" % things.size())
	for s in scenes.values():
		s.free()


func _wait_transition(world: Node) -> void:
	var guard := 0
	while world.transitioning and guard < 120:
		guard += 1
		await process_frame
	await _frames(2)


func _confirm_at(world: Node, door: Node3D) -> void:
	world.player.place(door.position.x, 0)
	await _frames(3)
	await _press("confirm")
	await _wait_transition(world)


func _explore(world: Node, visited: Dictionary) -> void:
	var here: String = world.room_id
	visited[here] = true
	var descriptors := []
	for d in _door_list(world.room):
		descriptors.append({"name": d.name, "target": d.target_room, "locked": d.locked})
	for desc in descriptors:
		var door: Node3D = world.room.get_node(NodePath(desc["name"]))
		var tag := "%s -> %s" % [here, desc["target"]]
		if desc["locked"]:
			world.player.place(door.position.x, 0)
			await _frames(3)
			check(world.player.current_interactable == door, "%s: prompt target is the locked door" % tag)
			await _press("confirm")
			check(world.room_id == here and world._text_open and world.player.movement_locked, "%s: locked door shows a message and stays" % tag)
			await _press("confirm")
			check(not world._text_open and not world.player.movement_locked, "%s: message closes" % tag)
			continue
		if visited.has(desc["target"]):
			continue
		await _confirm_at(world, door)
		check(world.room_id == desc["target"], "walked %s" % tag)
		if world.room_id != desc["target"]:
			return
		# Arriving puts the player at the return door.
		await _frames(3)
		var arrived = world.player.current_interactable
		check(arrived != null and arrived.has_method("is_door") and arrived.target_room == here, "%s: arrives at the return door" % tag)
		await _explore(world, visited)
		var back: Array = _door_list(world.room).filter(func(t): return t.target_room == here)
		world.player.place(back[0].position.x, 0)
		await _frames(3)
		await _press("confirm")
		await _wait_transition(world)
		check(world.room_id == here, "returned %s <- %s" % [here, desc["target"]])
		if world.room_id != here:
			return


func _test_map_walk() -> void:
	print("Map walk (simulated input)")
	var world: Node = load("res://scenes/map_01.tscn").instantiate()
	root.add_child(world)
	world.fade_time = 0.0
	await _frames(3)
	check(world.room_id == "hallway_1f", "starts in 1층 복도")
	check(world.player.position.x == -3.0, "starts at the 'start' spawn")

	# Camera follows the player but stays inside the room.
	world.player.place(-18.0, 0)
	world.room.update_camera()
	check(is_equal_approx(world.room.camera.position.x, world.room.bounds_left - 1.0 + 9.0), "camera stops at the left edge")
	world.player.place(5.0, 0)
	world.room.update_camera()
	check(is_equal_approx(world.room.camera.position.x, 5.0), "camera follows the player inside the room")
	world.player.place(-3.0, 0)

	# Sample interactable: shows placeholder text, locks movement, then closes.
	await _confirm_at(world, world.room.get_node("To_classroom_1_3"))
	check(world.room_id == "classroom_1_3", "entered 1학년 3반")
	var stove: Node3D = world.room.get_node("Stove")
	world.player.place(stove.position.x, 0)
	await _frames(3)
	check(world.player.current_interactable == stove, "prompt appears at the stove")
	check(world.player.get_node("Prompt").visible and world.player.get_node("Prompt").text == "Enter", "prompt says Enter")
	await _press("confirm")
	check(world._text_open and world._text_label.text == stove.placeholder_line and world.player.movement_locked, "stove shows its placeholder line")
	check(not world.player.get_node("Prompt").visible, "prompt hidden while text is open")
	await _press("confirm")
	check(not world._text_open and not world.player.movement_locked, "text closes, movement unlocked")
	world.player.place(-4.5, 0)
	await _frames(3)
	check(world.player.current_interactable == null and not world.player.get_node("Prompt").visible, "no prompt away from anything")
	await _confirm_at(world, world.room.get_node("To_hallway_1f"))
	check(world.room_id == "hallway_1f", "back to 1층 복도")

	var visited := {}
	await _explore(world, visited)
	var ids := visited.keys()
	ids.sort()
	check(ids.size() == 10, "walked through every unlocked room (%d): %s" % [ids.size(), str(ids)])
	check(not visited.has("hallway_2f") and not visited.has("stationery"), "locked rooms stay out of reach")
	world.queue_free()
	await _frames(2)
