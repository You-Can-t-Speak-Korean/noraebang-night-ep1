# Headless test runner. Exits non-zero on any failure.
#   godot --headless --import            (first time only)
#   godot --headless --path . -s res://tests/run_tests.gd
#
# Expected log noise (these tests deliberately trigger them): one push_error for
# an unknown card id, one for end_fight with a bad outcome, one for retry_fight
# outside a fight, and push_warnings for damage/heal/add_nunchi/spend_nunchi with
# values <= 0.
# The world test with a save from a newer version adds one more push_error
# ("World: could not load the save ...").
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
	_test_map_day()
	_test_dealer_data()
	_test_dealer()
	_test_reload_sim()
	_test_hud_pure()
	_test_launch_args()
	_test_project()
	await _test_stage()
	_test_movement_pure()
	await _test_player()
	_test_map_graph()
	await _test_map_walk()
	await _test_world_launch()
	await _test_hud_icons()
	await _test_world_search()
	await _test_world_full_run()
	_clean_world_saves()
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
	check(defaults.size() == 18, "default state has all 18 saved fields")
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
	var world: Node = await _start_world()
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
	world.layout = {}
	await _press("confirm")
	check(world._text_open and world._text_label.text == world.spawn_config["lines"]["empty"] and world.player.movement_locked, "stove (a search spot) shows its search result")
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


# ── Step 2b: finding things ────────────────────────────────────────────

const DealerScript := preload("res://scripts/spawn_dealer.gd")
const HeartsScript := preload("res://scripts/hearts_display.gd")
const EyesScript := preload("res://scripts/nunchi_display.gd")
const DdeokIconScript := preload("res://scripts/ddeok_icon.gd")
const WORLD_SAVE_DIR := "user://test_world_saves"
const MAP_KEY := "map_01:sat"


func _gs() -> Node:
	return root.get_node("GameState")


func _clean_world_saves() -> void:
	var dir := DirAccess.open(WORLD_SAVE_DIR)
	if dir:
		for f in dir.get_files():
			dir.remove(f)
		DirAccess.remove_absolute(WORLD_SAVE_DIR)


## A fresh map world on the autoload GameState, saving into the test folder only.
func _start_world(keep_save := false) -> Node:
	if not keep_save:
		_clean_world_saves()
	_gs().save_path = WORLD_SAVE_DIR + "/save.json"
	var world: Node = load("res://scenes/map_01.tscn").instantiate()
	root.add_child(world)
	world.fade_time = 0.0
	await _frames(3)
	return world


func _stop_world(world: Node) -> void:
	world.queue_free()
	await _frames(2)


func _kind_counts(layout: Dictionary) -> Dictionary:
	var c := {"ddeok": 0, "note": 0, "health": 0, "trap": 0}
	for id in layout:
		c[layout[id]["kind"]] += 1
	return c


func _spot_node(room: Node, spot_id: String) -> Node3D:
	for it in room.find_children("*", "Area3D", true, false):
		if it.get("spot_id") == spot_id:
			return it
	return null


## Walks the player to a spot (loading its room directly) and presses Enter.
func _search_spot(world: Node, config: Dictionary, spot_id: String) -> bool:
	var room_id: String = config["spots"][spot_id]["room"]
	if world.room_id != room_id:
		world._load_room(room_id, "")
	var node := _spot_node(world.room, spot_id)
	world.player.place(node.position.x, 0)
	await _frames(3)
	var reachable: bool = world.player.current_interactable == node
	await _press("confirm")
	return reachable


func _close_text(world: Node) -> void:
	if world._text_open:
		await _press("confirm")


func _test_map_day() -> void:
	print("map_day")
	var gs := make_gs()
	check(gs.map_day == "sat", "map_day defaults to sat")
	gs.map_day = "mon"
	gs.death_reset()
	check(gs.map_day == "sat", "death_reset puts the day back to sat")
	gs.map_day = "mon"
	_clean_saves()
	gs.save_path = SAVE_DIR + "/day.json"
	gs.save_game()
	var other := make_gs()
	other.save_path = gs.save_path
	other.load_game()
	check(other.map_day == "mon", "map_day survives a save round trip")
	check(gs._normalize({"map_day": 7}).map_day == "sat" and gs._normalize({"map_day": ""}).map_day == "sat", "bad map_day falls back to sat")
	check(gs._normalize({}).map_day == "sat", "missing map_day (older save) loads as sat")
	_clean_saves()
	gs.free()
	other.free()


func _test_dealer_data() -> void:
	print("Spawn data")
	var cfg: Dictionary = DealerScript.load_config()
	check(not cfg.is_empty(), "spawn config loads")
	var spots: Dictionary = cfg["spots"]
	check(spots.size() == 12, "12 spots")
	check(cfg["budgets"].keys().size() == 2 and cfg["budgets"].has("sat") and cfg["budgets"].has("mon"), "budgets for sat and mon")
	for day in ["sat", "mon"]:
		var b: Dictionary = cfg["budgets"][day]
		check(b["ddeok"] == 2 and b["ddeok_amount"] == 1 and b["extras"] == 1 and b["traps"] == 2, "%s budget: 2 DDEOK (1 each), 1 extra, 2 traps" % day)
		check(b["ddeok"] + b["extras"] == 3 and b["traps"] == 2, "%s: 3 rewards to 2 traps (6:4)" % day)
	check(cfg["extras"]["note"]["weight"] == 2 and cfg["extras"]["band_aid"]["weight"] == 2 and cfg["extras"]["red_medicine"]["weight"] == 1, "extra weights 2 / 2 / 1")
	check(cfg["extras"]["band_aid"]["heal"] == 1 and cfg["extras"]["red_medicine"]["heal"] == 2, "반창고 heals 1 half, 빨간약 heals 2")
	check(cfg["notes"].size() == 3, "3 notes")
	var all_placeholder := true
	for id in cfg["notes"]:
		all_placeholder = all_placeholder and cfg["notes"][id].contains("[placeholder]")
	for k in cfg["lines"]:
		all_placeholder = all_placeholder and cfg["lines"][k].contains("[placeholder]")
	check(all_placeholder, "every note and narration line is marked [placeholder]")
	var half_spots := []
	var every_trap := true
	for id in spots:
		var spot: Dictionary = spots[id]
		every_trap = every_trap and spot.has("trap") and int(spot["trap"]["damage"]) in [1, 2] and int(spot["trap"]["weight"]) >= 1
		if spot["trap"]["damage"] == 1:
			half_spots.append(id)
	check(every_trap, "every spot has a trap with damage 1 or 2 halves and a weight")
	half_spots.sort()
	check(half_spots == ["back_chair", "cabinet", "lectern", "shoe_rack"], "½-heart traps: 교탁, chair, 청소도구함, 신발장 (%s)" % str(half_spots))
	check(spots["landing_2f"]["days"] == ["mon"], "2층 landing is Monday only")
	var sat_spots := spots.keys().filter(func(id): return spots[id]["days"].has("sat"))
	check(sat_spots.size() == 11, "11 spots are eligible on Saturday")
	# Every spot has exactly one gray prop in the named room, and no other room claims it.
	var found := {}
	var rooms: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MAP_DATA))["rooms"]
	for room_id in rooms:
		var room: Node = load(rooms[room_id]).instantiate()
		for it in room.find_children("*", "Area3D", true, false):
			var sid = it.get("spot_id")
			if typeof(sid) == TYPE_STRING and sid != "":
				found[sid] = found.get(sid, 0) + 1
				check(spots.has(sid) and spots[sid]["room"] == room_id, "spot '%s' sits in its room (%s)" % [sid, room_id])
		room.free()
	var once := true
	for id in spots:
		once = once and found.get(id, 0) == 1
	check(once and found.size() == 12, "each of the 12 spots has exactly one prop")


func _test_dealer() -> void:
	print("Dealer")
	var cfg: Dictionary = DealerScript.load_config()
	var spots: Dictionary = cfg["spots"]
	var counts_ok := {"sat": true, "mon": true}
	var eligible_ok := true
	var no_landing_sat := true
	var deterministic := true
	var layouts := {}
	var half := 0
	var traps := 0
	var seeds := 2000
	for day in ["sat", "mon"]:
		var day_budget: Dictionary = cfg["budgets"][day]
		for s in seeds:
			var l: Dictionary = DealerScript.deal(spots, day_budget, cfg["extras"], s, [], [], day)
			var c := _kind_counts(l)
			counts_ok[day] = counts_ok[day] and c["ddeok"] == 2 and c["note"] + c["health"] == 1 and c["trap"] == 2 and l.size() == 5
			for id in l:
				eligible_ok = eligible_ok and spots.has(id) and spots[id]["days"].has(day)
				if l[id]["kind"] == "trap":
					traps += 1
					half += 1 if l[id]["damage"] == 1 else 0
					# The trap dealt is the spot's own.
					eligible_ok = eligible_ok and l[id]["name"] == spots[id]["trap"]["name"]
				if l[id]["kind"] == "ddeok":
					eligible_ok = eligible_ok and l[id]["amount"] == 1
			if day == "sat":
				no_landing_sat = no_landing_sat and not l.has("landing_2f")
			if s < 200:
				deterministic = deterministic and same(l, DealerScript.deal(spots, day_budget, cfg["extras"], s, [], [], day))
				if day == "sat":
					layouts[JSON.stringify(l)] = true
	check(counts_ok["sat"] and counts_ok["mon"], "budget counts are exact over %d seeds per day (2 DDEOK, 1 extra, 2 traps, 5 spots)" % seeds)
	check(eligible_ok, "only eligible spots are dealt, with their own trap")
	check(no_landing_sat, "the 2층 landing is never dealt on Saturday")
	check(deterministic, "the same seed gives the same layout")
	check(layouts.size() >= 190, "different seeds give different layouts (%d distinct of 200)" % layouts.size())
	var share := float(half) / float(traps)
	check(share > 0.76 and share < 0.84, "about 80%% of dealt traps are ½-heart (%.3f of %d)" % [share, traps])

	# Owned notes are never dealt; with none left a health item takes the slot.
	var b: Dictionary = cfg["budgets"]["sat"]
	var leaked := false
	var notes_dealt := 0
	var all_owned_ok := true
	for s in 1500:
		var l: Dictionary = DealerScript.deal(spots, b, cfg["extras"], s, [], ["note_1", "note_2"], "sat")
		for id in l:
			if l[id]["kind"] == "note":
				notes_dealt += 1
				leaked = leaked or l[id]["note_id"] != "note_3"
		var all_l: Dictionary = DealerScript.deal(spots, b, cfg["extras"], s, [], ["note_1", "note_2", "note_3"], "sat")
		var c := _kind_counts(all_l)
		all_owned_ok = all_owned_ok and c["note"] == 0 and c["health"] == 1 and c["ddeok"] == 2 and c["trap"] == 2
	check(notes_dealt > 100 and not leaked, "owned notes are never dealt; only note_3 appears (%d dealt)" % notes_dealt)
	check(all_owned_ok, "with every note owned, the extra becomes a health item")

	# Entries in `collected` shrink the pool and the budget (empties only shrink the pool).
	var prior := ["stove:ddeok", "lectern:trap", "office:empty"]
	var ok := true
	for s in 500:
		var l: Dictionary = DealerScript.deal(spots, b, cfg["extras"], s, prior, [], "sat")
		var c := _kind_counts(l)
		ok = ok and c["ddeok"] == 1 and c["trap"] == 1 and c["note"] + c["health"] == 1
		ok = ok and not l.has("stove") and not l.has("lectern") and not l.has("office")
	check(ok, "remaining budget = budget - taken; searched spots (even empty ones) are not dealt again")
	var spent := ["stove:ddeok", "office:ddeok", "lectern:trap", "cabinet:trap", "shoe_rack:note"]
	check(DealerScript.deal(spots, b, cfg["extras"], 1, spent, [], "sat").is_empty(), "a spent budget deals nothing")


func _test_reload_sim() -> void:
	print("Reload simulation")
	var cfg: Dictionary = DealerScript.load_config()
	var spots: Dictionary = cfg["spots"]
	var b: Dictionary = cfg["budgets"]["sat"]
	var eligible: Array = spots.keys().filter(func(id): return spots[id]["days"].has("sat"))
	eligible.sort()
	_clean_saves()
	var stays := true
	var adds_up := true
	var changed := 0
	var trials := 60
	for t in trials:
		var gs := make_gs()
		gs.save_path = SAVE_DIR + "/reload.json"
		gs.spawn_seed = 100 + t
		var first: Dictionary = DealerScript.deal(spots, b, cfg["extras"], gs.spawn_seed, [], gs.notes, "sat")
		var taken_ids: Array = eligible.slice(0, 3 + t % 6)
		for id in taken_ids:
			var entry: Dictionary = first.get(id, {"kind": "empty"})
			gs.mark_collected(MAP_KEY, "%s:%s" % [id, entry["kind"]])
			if entry["kind"] == "note":
				gs.add_note(entry["note_id"])
		gs.save_game()
		var loaded := make_gs()
		loaded.save_path = gs.save_path
		loaded.load_game()
		loaded.spawn_seed = 9000 + t
		var second: Dictionary = DealerScript.deal(spots, b, cfg["extras"], loaded.spawn_seed, loaded.collected.get(MAP_KEY, []), loaded.notes, "sat")
		for id in taken_ids:
			stays = stays and not second.has(id)
		# taken + remaining = budget, per kind
		var taken_counts := {"ddeok": 0, "extra": 0, "trap": 0}
		for entry in loaded.collected.get(MAP_KEY, []):
			match str(entry).split(":")[1]:
				"ddeok":
					taken_counts["ddeok"] += 1
				"note", "health":
					taken_counts["extra"] += 1
				"trap":
					taken_counts["trap"] += 1
		var left := _kind_counts(second)
		adds_up = adds_up and taken_counts["ddeok"] + left["ddeok"] == b["ddeok"] \
				and taken_counts["extra"] + left["note"] + left["health"] == b["extras"] \
				and taken_counts["trap"] + left["trap"] == b["traps"]
		var first_rest := first.duplicate()
		for id in taken_ids:
			first_rest.erase(id)
		if not same(first_rest, second):
			changed += 1
		gs.free()
		loaded.free()
	_clean_saves()
	check(stays, "collected spots are never dealt again after a reload")
	check(adds_up, "taken + remaining equals the budget after a reload")
	check(changed >= trials * 0.8, "uncollected positions change with the new seed (%d of %d)" % [changed, trials])


func _test_hud_pure() -> void:
	print("Hearts shapes (pure)")
	var WorldScript = load("res://scripts/world.gd")  # runtime load: needs the GameState autoload
	check(HeartsScript.heart_count(10) == 5 and HeartsScript.heart_count(9) == 5, "10 halves draw 5 hearts")
	var states := []
	for i in 5:
		states.append(HeartsScript.heart_state(i, 7))
	check(states == [2, 2, 2, 1, 0], "7 halves = 3 full, 1 half, 1 empty (%s)" % str(states))
	var full := []
	var none := []
	for i in 5:
		full.append(HeartsScript.heart_state(i, 10))
		none.append(HeartsScript.heart_state(i, 0))
	check(full == [2, 2, 2, 2, 2] and none == [0, 0, 0, 0, 0], "10 halves all full, 0 halves all empty")
	check(HeartsScript.heart_state(0, 1) == 1 and HeartsScript.heart_state(1, 1) == 0, "1 half = half of the first heart")
	var poly: PackedVector2Array = HeartsScript.heart_polygon(52.0)
	var lo := poly[0]
	var hi := poly[0]
	for p in poly:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	check(poly.size() >= 24 and lo.is_equal_approx(Vector2.ZERO) and hi.is_equal_approx(Vector2(52, 52)), "heart polygon fills its 52 px box")
	check(WorldScript.hearts_text(1) == "½" and WorldScript.hearts_text(2) == "1" and WorldScript.hearts_text(3) == "1½", "heart amounts read ½ / 1 / 1½")

	var eye: PackedVector2Array = EyesScript.eye_polygon(38.0, 22.0)
	var eye_lo := eye[0]
	var eye_hi := eye[0]
	for p in eye:
		eye_lo = Vector2(minf(eye_lo.x, p.x), minf(eye_lo.y, p.y))
		eye_hi = Vector2(maxf(eye_hi.x, p.x), maxf(eye_hi.y, p.y))
	check(eye_lo.is_equal_approx(Vector2.ZERO) and eye_hi.is_equal_approx(Vector2(38, 22)), "eye polygon fills its 38 x 22 box")
	var held_eyes := []
	for i in 7:
		held_eyes.append(EyesScript.eye_held(i, 3))
	check(held_eyes == [true, true, true, false, false, false, false], "3 held = the first 3 eyes filled")
	var cake: PackedVector2Array = DdeokIconScript.songpyeon_polygon(46.0, 26.0)
	var cake_lo := cake[0]
	var cake_hi := cake[0]
	for p in cake:
		cake_lo = Vector2(minf(cake_lo.x, p.x), minf(cake_lo.y, p.y))
		cake_hi = Vector2(maxf(cake_hi.x, p.x), maxf(cake_hi.y, p.y))
	check(cake_lo.is_equal_approx(Vector2.ZERO) and cake_hi.is_equal_approx(Vector2(46, 26)), "송편 polygon fills its 46 x 26 box")


## Counts the filled eyes the way _draw does.
func _eyes_shown(display: Control) -> int:
	var n := 0
	for i in display.cap:
		if EyesScript.eye_held(i, display.held):
			n += 1
	return n


func _test_hud_icons() -> void:
	print("HUD icons follow GameState")
	var gs := _gs()
	var world: Node = await _start_world()
	var hud: Node = world.hud
	var eyes: Control = hud.nunchi
	for n in [0, 3, 7]:
		gs.nunchi = 0
		if n > 0:
			gs.add_nunchi(n)
		await _frames(1)
		check(gs.nunchi == n and _eyes_shown(eyes) == n and eyes.cap == 7, "%d held eyes of 7 when 눈치 is %d" % [n, n])
	gs.nunchi = 0
	gs.nunchi_changed.emit(0)
	check(_eyes_shown(eyes) == 0, "eyes empty again at 눈치 0")
	check(eyes.get_child_count() == 0 and not hud.ddeok_label.text.contains("DDEOK"), "no number on the eyes, no DDEOK word on the count")
	for n in [0, 5, 12]:
		gs.ddeok = n
		gs.ddeok_changed.emit(n)
		check(hud.ddeok_label.text == str(n), "DDEOK count reads %d" % n)
	for h in [10, 7, 1, 0]:
		gs.hearts_halves = h
		gs.hearts_changed.emit(h)
		check(hud.hearts.halves == h, "hearts match %d halves" % h)
	# The dev arg's setter updates the HUD through the same signal.
	world.set_hearts_dev(5)
	check(gs.hearts_halves == 5 and hud.hearts.halves == 5, "--hearts 2.5 sets 5 halves and the HUD follows")
	world.set_hearts_dev(99)
	check(gs.hearts_halves == gs.hearts_max_halves, "the dev setter never exceeds the maximum")
	# Layout: every group sits inside the box, one under the other, no overlap.
	await _frames(2)
	var rects := []
	for c in [hud.hearts, eyes, hud.get_node("Box/Stats")]:
		rects.append(Rect2(c.global_position, c.size))
	var clear := true
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			if rects[i].intersects(rects[j]):
				clear = false
	check(clear, "hearts, eyes and the DDEOK/비밀 row do not overlap")
	var ddeok_row: Control = hud.get_node("Box/Stats/Ddeok")
	check(not Rect2(ddeok_row.global_position, ddeok_row.size).intersects(Rect2(hud.secrets_label.global_position, hud.secrets_label.size)), "DDEOK group and 비밀 do not overlap")
	check(Rect2(0, 0, 1920, 1080).encloses(Rect2(hud.get_node("Box").global_position, hud.get_node("Box").size)), "HUD fits inside 1920x1080")
	await _stop_world(world)


func _test_launch_args() -> void:
	print("Launch args")
	var WorldScript = load("res://scripts/world.gd")
	var none: Dictionary = WorldScript.parse_launch_args(PackedStringArray([]))
	check(not none["new_game"] and none["seed"] == -1 and not none["capture_map"] and not none["capture_hud"], "no args: load the save, random seed")
	var a: Dictionary = WorldScript.parse_launch_args(PackedStringArray(["--new-game", "--seed", "42"]))
	check(a["new_game"] and a["seed"] == 42, "--new-game and --seed N")
	var bad: Dictionary = WorldScript.parse_launch_args(PackedStringArray(["--seed", "abc"]))
	check(bad["seed"] == -1, "a bad --seed is ignored")
	var last: Dictionary = WorldScript.parse_launch_args(PackedStringArray(["--seed"]))
	check(last["seed"] == -1, "--seed with no value is ignored")
	check(WorldScript.parse_launch_args(PackedStringArray(["--capture-hud"]))["capture_hud"], "--capture-hud recognised")
	check(none["hearts_halves"] == -1, "no --hearts: hearts untouched")
	var hearts_cases := {"1": 2, "2.5": 5, "0.5": 1, "5": 10, "3.0": 6, "0": 1, "0.1": 1, "-3": 1, "9": 10, "100": 10, "2.4": 5, "2.2": 4}
	for text in hearts_cases:
		var got: int = WorldScript.parse_launch_args(PackedStringArray(["--hearts", text]))["hearts_halves"]
		check(got == hearts_cases[text], "--hearts %s -> %d halves (got %d)" % [text, hearts_cases[text], got])
	for junk in ["abc", "", "1.2.3", "nan", "inf", "2 hearts", "--seed"]:
		check(WorldScript.parse_launch_args(PackedStringArray(["--hearts", junk]))["hearts_halves"] == -1, "--hearts '%s' is ignored" % junk)
	check(WorldScript.parse_launch_args(PackedStringArray(["--hearts"]))["hearts_halves"] == -1, "--hearts with no value is ignored")
	var mixed: Dictionary = WorldScript.parse_launch_args(PackedStringArray(["--new-game", "--hearts", "1.5", "--seed", "9"]))
	check(mixed["hearts_halves"] == 3 and mixed["seed"] == 9 and mixed["new_game"], "--hearts combines with other args")


func _test_world_launch() -> void:
	print("World launch and saves")
	var gs := _gs()
	var world: Node = await _start_world()
	check(world.room_id == "hallway_1f" and gs.progress == "scene_00", "no save: new game in the start room")
	check(world.layout.size() == 5, "a layout of 5 finds was dealt on launch")
	check(world.hud != null and world.hud.get_parent() == world, "HUD is part of the world")

	# Forced seed: same seed, same layout.
	world._forced_seed = 777
	world._start_game(true)
	var l1: Dictionary = world.layout.duplicate(true)
	world._start_game(true)
	check(gs.spawn_seed == 777 and same(l1, world.layout), "--seed forces the spawn seed and so the layout")
	world._forced_seed = -1

	# Autosave on a room change; the save holds the state, and a relaunch starts in the start room.
	gs.add_ddeok(3)
	gs.mark_collected(MAP_KEY, "stove:ddeok")
	check(not FileAccess.file_exists(gs.save_path), "nothing is saved before the first room change")
	await _confirm_at(world, world.room.get_node("To_classroom_1_3"))
	check(world.room_id == "classroom_1_3" and FileAccess.file_exists(gs.save_path), "a room change autosaves")
	var other := make_gs()
	other.save_path = gs.save_path
	check(other.load_game() == OK and other.ddeok == 3 and other.is_collected(MAP_KEY, "stove:ddeok"), "save round trip across a room change")
	other.free()
	await _stop_world(world)

	var again: Node = await _start_world(true)
	check(again.room_id == "hallway_1f" and gs.ddeok == 3, "relaunch: state restored, but in the start room")
	check(not again.layout.has("stove"), "relaunch: the collected spot is not dealt again")
	var left := _kind_counts(again.layout)
	check(left["ddeok"] == 1 and left["trap"] == 2 and left["note"] + left["health"] == 1, "relaunch: taken + remaining = budget")
	# --new-game ignores the save.
	again._start_game(true)
	check(gs.ddeok == 0 and gs.collected.is_empty(), "--new-game ignores the save")
	await _stop_world(again)

	# A save from a newer version is never overwritten.
	_clean_world_saves()
	DirAccess.make_dir_recursive_absolute(WORLD_SAVE_DIR)
	var future := JSON.stringify({"game": "noraebang-night", "save_version": 99, "state_version": "9.9", "state": {"ddeok": 5}})
	_write(WORLD_SAVE_DIR + "/save.json", future)
	var w3: Node = await _start_world(true)
	check(not w3.autosave_enabled and gs.ddeok == 0, "newer save: new game in memory, autosave off")
	await _confirm_at(w3, w3.room.get_node("To_classroom_1_3"))
	check(_read(WORLD_SAVE_DIR + "/save.json") == future, "newer save is left untouched by a room change")
	await _stop_world(w3)


func _test_world_search() -> void:
	print("Searching")
	var gs := _gs()
	var cfg: Dictionary = DealerScript.load_config()
	var world: Node = await _start_world()
	var lines: Dictionary = cfg["lines"]
	world.layout = {
		"stove": {"kind": "ddeok", "amount": 1},
		"lectern": {"kind": "trap", "name": "쥐덫", "damage": 1},
		"cabinet": {"kind": "health", "item": "band_aid", "name": "반창고", "heal": 1},
		"back_chair": {"kind": "note", "note_id": "note_2"},
		"shoe_rack": {"kind": "health", "item": "red_medicine", "name": "빨간약", "heal": 2},
	}
	gs.damage(4)
	check(gs.hearts_halves == 6, "start the search test at 6 halves")

	var ok := await _search_spot(world, cfg, "stove")
	check(ok and world._text_open and world.player.movement_locked, "Enter on a spot opens the textbox and locks movement")
	check(gs.ddeok == 1 and world._text_label.text.contains("1 DDEOK") and world._text_label.text.contains("[placeholder]"), "DDEOK goes to GameState")
	check(gs.is_collected(MAP_KEY, "stove:ddeok"), "the find is recorded as stove:ddeok")
	await _close_text(world)
	await _search_spot(world, cfg, "stove")
	check(world._text_label.text == lines["searched"] and gs.ddeok == 1, "a spot searched twice gives nothing the second time")
	check(gs.collected[MAP_KEY].size() == 1, "the second search records nothing")
	await _close_text(world)

	await _search_spot(world, cfg, "back_chair")
	check(gs.has_note("note_2") and world._text_label.text.contains(cfg["notes"]["note_2"]), "a note goes to GameState and its text is shown")
	await _close_text(world)
	await _search_spot(world, cfg, "cabinet")
	check(gs.hearts_halves == 7 and world._text_label.text.contains("반창고") and world._text_label.text.contains("½"), "반창고 heals 1 half at once")
	await _close_text(world)
	await _search_spot(world, cfg, "shoe_rack")
	check(gs.hearts_halves == 9 and world._text_label.text.contains("빨간약"), "빨간약 heals 2 halves at once")
	await _close_text(world)
	var before_flash: int = world.flashes
	await _search_spot(world, cfg, "lectern")
	check(gs.hearts_halves == 8 and world._text_label.text.contains("쥐덫") and world._text_label.text.contains("½"), "a ½-heart trap costs 1 half")
	check(world.flashes == before_flash + 1 and world._flash_rect.color.a > 0.0, "a trap flashes the screen red")
	await _close_text(world)

	# Nothing dealt: empty, still once only.
	await _search_spot(world, cfg, "restroom")
	check(world._text_label.text == lines["empty"] and gs.is_collected(MAP_KEY, "restroom:empty"), "an undealt spot is empty and recorded")
	await _close_text(world)

	# Hearts clamp at the maximum.
	gs.hearts_halves = gs.hearts_max_halves
	world.layout = {"sandbox": {"kind": "health", "item": "red_medicine", "name": "빨간약", "heal": 2}}
	await _search_spot(world, cfg, "sandbox")
	check(gs.hearts_halves == gs.hearts_max_halves, "healing clamps at full hearts")
	await _close_text(world)

	# A 1-heart trap.
	world.layout = {"iron_bar": {"kind": "trap", "name": "녹슨 철봉", "damage": 2}}
	await _search_spot(world, cfg, "iron_bar")
	check(gs.hearts_halves == gs.hearts_max_halves - 2 and world._text_label.text.contains("1 heart"), "a 1-heart trap costs 2 halves")
	await _close_text(world)

	# The HUD follows GameState.
	await _frames(1)
	check(world.hud.hearts.halves == gs.hearts_halves and world.hud.hearts.max_halves == gs.hearts_max_halves, "HUD hearts match GameState (%d halves)" % gs.hearts_halves)
	check(world.hud.ddeok_label.text == str(gs.ddeok) and world.hud.nunchi.held == gs.nunchi and world.hud.nunchi.cap == 7, "HUD DDEOK count and 눈치 eyes match")
	check(world.hud.secrets_label.text == "비밀 7/7", "HUD shows 비밀 7/7 at the start")
	gs.lose_secret("pride", "eunju")
	gs.add_nunchi(2)
	gs.damage(1)
	check(world.hud.secrets_label.text == "비밀 6/7" and world.hud.nunchi.held == 2 and world.hud.hearts.halves == gs.hearts_halves, "HUD updates on signals")

	# Death: game over, then Enter restarts in 1학년 3반 with a fresh GameState.
	gs.hearts_halves = 1
	world.layout = {"statue": {"kind": "trap", "name": "이순신 동상의 칼", "damage": 2}}
	await _search_spot(world, cfg, "statue")
	check(world._game_over and world._game_over_layer.visible and world.player.movement_locked, "0 hearts: GAME OVER screen, movement locked")
	check(gs.hearts_halves == 0 and world.hud.hearts.halves == 0, "the HUD shows empty hearts on the game-over screen")
	await _press("confirm")
	check(not world._game_over and not world._game_over_layer.visible and not world._text_open, "Enter leaves the game-over screen")
	check(world.room_id == "classroom_1_3" and is_equal_approx(world.player.position.x, 7.0), "death restarts in 1학년 3반 at its door")
	check(gs.hearts_halves == gs.hearts_max_halves and gs.ddeok == 0 and gs.notes.is_empty() and gs.collected.is_empty() and gs.progress == "scene_01" and gs.map_day == "sat", "GameState is fresh after the death reset")
	check(not world.player.movement_locked, "movement is unlocked after the restart")
	check(world.layout.size() == 5 and gs.secrets_held.size() == gs.hand.size(), "a new layout is dealt and the hand is restored")
	var saved := make_gs()
	saved.save_path = gs.save_path
	check(saved.load_game() == OK and saved.hearts_halves == saved.hearts_max_halves and saved.collected.is_empty(), "the death reset is autosaved")
	saved.free()
	check(world.hud.hearts.halves == gs.hearts_max_halves and world.hud.secrets_label.text == "비밀 7/7", "HUD shows the fresh state")
	await _stop_world(world)


## Searches all the day's spots through real key presses and checks the budget.
func _test_world_full_run() -> void:
	print("Full run through the spots")
	var gs := _gs()
	var cfg: Dictionary = DealerScript.load_config()
	var spots: Dictionary = cfg["spots"]
	for day in ["sat", "mon"]:
		var world: Node = await _start_world()
		gs.map_day = day
		gs.spawn_seed = 31337
		world.deal_layout()
		var layout: Dictionary = world.layout.duplicate(true)
		var ids: Array = spots.keys().filter(func(id): return spots[id]["days"].has(day))
		ids.sort()
		var reachable := true
		var expected_hearts: int = gs.hearts_halves
		for id in ids:
			var reached: bool = await _search_spot(world, cfg, id)
			reachable = reachable and reached
			await _close_text(world)
			var entry: Dictionary = layout.get(id, {"kind": "empty"})
			if entry["kind"] == "trap":
				expected_hearts = maxi(expected_hearts - int(entry["damage"]), 1)
			elif entry["kind"] == "health":
				expected_hearts = mini(expected_hearts + int(entry["heal"]), gs.hearts_max_halves)
		check(reachable, "%s: all %d spots can be reached and searched with Enter" % [day, ids.size()])
		var tally := {"ddeok": 0, "note": 0, "health": 0, "trap": 0, "empty": 0}
		for entry in gs.collected["map_01:" + day]:
			tally[str(entry).split(":")[1]] += 1
		check(tally["ddeok"] == 2 and tally["note"] + tally["health"] == 1 and tally["trap"] == 2 and tally["empty"] == ids.size() - 5, "%s: the run found exactly the day's budget %s" % [day, str(tally)])
		check(gs.ddeok == 2, "%s: 2 DDEOK in GameState" % day)
		check(gs.notes.size() == tally["note"], "%s: notes match the finds" % day)
		check(gs.hearts_halves == expected_hearts, "%s: hearts match the traps and health items found (%d halves)" % [day, gs.hearts_halves])
		check(gs.collected["map_01:" + day].size() == ids.size(), "%s: every spot recorded once" % day)
		if day == "mon":
			check(ids.has("landing_2f") and gs.is_collected("map_01:mon", "landing_2f:" + layout.get("landing_2f", {"kind": "empty"})["kind"]), "mon: the 2층 landing was searched")
		await _stop_world(world)
	_clean_world_saves()
