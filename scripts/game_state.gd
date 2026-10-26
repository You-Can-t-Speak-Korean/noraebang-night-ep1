# Noraebang Night — global game state (autoload "GameState"), v0.4.
# Content (hand, leaks) and tunables live in data/; this file is rules only.
#
# Writer's rule: every dialogue choice calls at most ONE of
#   GameState.add_nunchi(1)  or  GameState.lose_secret("card_id")
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

signal hearts_changed(halves: int)
signal nunchi_changed(value: int)
signal ddeok_changed(value: int)
signal secret_lost(card: String, by: String)
signal player_died
signal fight_lost
signal state_reset

const STATE_VERSION := "0.4"
const SAVE_VERSION := 1
const GAME_ID := "noraebang-night"
const OUTCOMES: Array[String] = ["revenge", "survival"]

## Fields listed here survive death_reset(). Empty for now.
const PERSISTS_THROUGH_DEATH: Array[String] = []

const TUNING_PATH := "res://data/config/tuning.json"
const HAND_PATH := "res://data/secrets/act1_hand.json"
const LEAKS_PATH := "res://data/secrets/act1_leaks.json"

const DEFAULT_MAP_DAY := "sat"
const DEFAULT_HEARTS_MAX_HALVES := 10
const DEFAULT_NUNCHI_CAP := 7
const DEFAULT_OVERFLOW_RATE := 1
const DEFAULT_HAND: Array[String] = [
	"dad_country", "dad_story", "our_home", "mom_job", "mom_salary", "dad_drinking", "pride",
]

# ── Tunables and content (loaded from data/, never saved) ──────────────
var hearts_max_halves: int = DEFAULT_HEARTS_MAX_HALVES
var nunchi_cap: int = DEFAULT_NUNCHI_CAP
var nunchi_overflow_ddeok_per_point: int = DEFAULT_OVERFLOW_RATE
var hand: Array[String] = DEFAULT_HAND.duplicate()
## person id -> Array[String] of people who learn what that person learns (one hop).
var leaks: Dictionary = {}

# ── State (saved) ──────────────────────────────────────────────────────
var hearts_halves: int = DEFAULT_HEARTS_MAX_HALVES
var nunchi: int = 0
var ddeok: int = 0
var secrets_held: Array[String] = []
var secrets_known_by: Dictionary = {}  # card -> Array[String] of person ids
var spawn_seed: int = 0
var map_day: String = DEFAULT_MAP_DAY  # "sat" | "mon"; picks the day's spot budget
## "<map>:<day>" -> Array[String] of "<spot_id>:<kind>" (kind: ddeok, note, health, trap, empty).
var collected: Dictionary = {}
var notes: Array[String] = []
var talked: Array[String] = []
var owned_items: Array[String] = []
var scores: Dictionary = {}            # boss -> int (best)
var outcomes: Dictionary = {}          # boss -> "revenge" | "survival"
var progress: String = ""
var codex: Array[String] = []
var current_boss: String = ""
var in_fight: bool = false
var fight_snapshot: Dictionary = {}    # {"hearts_halves": int, "nunchi": int}

## Where save_game()/load_game() read and write. Tests override this.
var save_path: String = "user://noraebang_night_save.json"


func _ready() -> void:
	load_data()
	new_game()


# ── Data loading ───────────────────────────────────────────────────────

func load_data(tuning_path: String = TUNING_PATH, hand_path: String = HAND_PATH, leaks_path: String = LEAKS_PATH) -> void:
	hearts_max_halves = DEFAULT_HEARTS_MAX_HALVES
	nunchi_cap = DEFAULT_NUNCHI_CAP
	nunchi_overflow_ddeok_per_point = DEFAULT_OVERFLOW_RATE
	hand = DEFAULT_HAND.duplicate()
	leaks = {}

	var tuning = _read_json(tuning_path)
	if typeof(tuning) != TYPE_DICTIONARY:
		push_error("GameState: could not read tuning from %s, using defaults" % tuning_path)
	else:
		hearts_max_halves = _tuning_int(tuning, "hearts_max_halves", 1, DEFAULT_HEARTS_MAX_HALVES)
		nunchi_cap = _tuning_int(tuning, "nunchi_cap", 1, DEFAULT_NUNCHI_CAP)
		nunchi_overflow_ddeok_per_point = _tuning_int(tuning, "nunchi_overflow_ddeok_per_point", 0, DEFAULT_OVERFLOW_RATE)

	var hand_data = _read_json(hand_path)
	if typeof(hand_data) != TYPE_ARRAY or hand_data.is_empty():
		push_error("GameState: could not read hand from %s, using built-in Act 1 hand" % hand_path)
	else:
		hand = _str_array(hand_data)

	var leaks_data = _read_json(leaks_path)
	if typeof(leaks_data) != TYPE_DICTIONARY:
		push_error("GameState: could not read leaks from %s, using none" % leaks_path)
	else:
		for person in leaks_data:
			if typeof(leaks_data[person]) == TYPE_ARRAY:
				leaks[str(person)] = _str_array(leaks_data[person])


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _tuning_int(data: Dictionary, key: String, min_value: int, fallback: int) -> int:
	var v = data.get(key)
	if (typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT) and float(v) == floorf(float(v)) and int(v) >= min_value:
		return int(v)
	push_error("GameState: tuning key '%s' missing or invalid, using %d" % [key, fallback])
	return fallback


# ── ❤️ Hearts ──────────────────────────────────────────────────────────

func damage(halves: int) -> void:
	if halves <= 0:
		push_warning("GameState.damage: halves must be > 0 (got %d)" % halves)
		return
	var before := hearts_halves
	hearts_halves = clampi(hearts_halves - halves, 0, hearts_max_halves)
	if hearts_halves != before:
		hearts_changed.emit(hearts_halves)
	if before > 0 and hearts_halves == 0:
		if in_fight:
			fight_lost.emit()
		else:
			player_died.emit()


func heal(halves: int) -> void:
	if halves <= 0:
		push_warning("GameState.heal: halves must be > 0 (got %d)" % halves)
		return
	var before := hearts_halves
	hearts_halves = clampi(hearts_halves + halves, 0, hearts_max_halves)
	if hearts_halves != before:
		hearts_changed.emit(hearts_halves)


# ── 👀 눈치 and 떡 ─────────────────────────────────────────────────────

## Returns the overflow (points that did not fit under the cap).
func add_nunchi(n: int) -> int:
	if n <= 0:
		push_warning("GameState.add_nunchi: n must be > 0 (got %d)" % n)
		return 0
	var filled := mini(n, nunchi_cap - nunchi)
	var overflow := n - filled
	if filled > 0:
		nunchi += filled
		nunchi_changed.emit(nunchi)
	if overflow > 0:
		add_ddeok(overflow * nunchi_overflow_ddeok_per_point)
	return overflow


func spend_nunchi(n: int) -> bool:
	if n <= 0:
		push_warning("GameState.spend_nunchi: n must be > 0 (got %d)" % n)
		return false
	if nunchi < n:
		return false
	nunchi -= n
	nunchi_changed.emit(nunchi)
	return true


func add_ddeok(n: int) -> void:
	if n <= 0:
		if n < 0:
			push_warning("GameState.add_ddeok: n must be >= 0 (got %d)" % n)
		return
	ddeok += n
	ddeok_changed.emit(ddeok)


# ── 🔒 Secrets ─────────────────────────────────────────────────────────

## Returns true only when a held card was lost by this call.
func lose_secret(card: String, by: String = "") -> bool:
	if not hand.has(card):
		push_error("GameState.lose_secret: unknown card '%s'" % card)
		return false
	var held := secrets_held.has(card)
	if held:
		secrets_held.erase(card)
	var who := by if by != "" else current_boss
	if who != "":
		_teach(card, who)
		for other in leaks.get(who, []):
			_teach(card, other)
	if held:
		secret_lost.emit(card, who)
	return held


func _teach(card: String, person: String) -> void:
	if not secrets_known_by.has(card):
		secrets_known_by[card] = _str_array([])
	var people: Array = secrets_known_by[card]
	if not people.has(person):
		people.append(person)


func has_secret(card: String) -> bool:
	return secrets_held.has(card)


func knows(person: String, card: String) -> bool:
	return secrets_known_by.has(card) and secrets_known_by[card].has(person)


## In hand order.
func cards_known_by(person: String) -> Array[String]:
	var result: Array[String] = []
	for card in hand:
		if knows(person, card):
			result.append(card)
	return result


func set_boss(id: String) -> void:
	current_boss = id


# ── ⚔️ Fights ─────────────────────────────────────────────────────────

func begin_fight(boss_id: String) -> void:
	current_boss = boss_id
	in_fight = true
	fight_snapshot = {"hearts_halves": hearts_halves, "nunchi": nunchi}


func retry_fight() -> bool:
	if not in_fight or fight_snapshot.is_empty():
		push_error("GameState.retry_fight: no fight in progress")
		return false
	hearts_halves = int(fight_snapshot["hearts_halves"])
	nunchi = int(fight_snapshot["nunchi"])
	hearts_changed.emit(hearts_halves)
	nunchi_changed.emit(nunchi)
	return true


func end_fight(boss_id: String, outcome: String, score: int) -> bool:
	if not OUTCOMES.has(outcome):
		push_error("GameState.end_fight: unknown outcome '%s'" % outcome)
		return false
	in_fight = false
	fight_snapshot = {}
	if not scores.has(boss_id) or score > int(scores[boss_id]):
		scores[boss_id] = score
	if outcome == "revenge" or not outcomes.has(boss_id):
		outcomes[boss_id] = outcome
	if outcome == "revenge":
		heal(hearts_max_halves - hearts_halves)
	return true


# ── Small helpers ──────────────────────────────────────────────────────

func add_note(id: String) -> void:
	if not notes.has(id):
		notes.append(id)


func has_note(id: String) -> bool:
	return notes.has(id)


func unlock_codex(id: String) -> void:
	if not codex.has(id):
		codex.append(id)


func mark_collected(map_key: String, id: String) -> void:
	if not collected.has(map_key):
		collected[map_key] = _str_array([])
	if not collected[map_key].has(id):
		collected[map_key].append(id)


func is_collected(map_key: String, id: String) -> bool:
	return collected.has(map_key) and collected[map_key].has(id)


func mark_talked(id: String) -> void:
	if not talked.has(id):
		talked.append(id)


func has_talked(id: String) -> bool:
	return talked.has(id)


func add_item(id: String) -> void:
	if not owned_items.has(id):
		owned_items.append(id)


func owns_item(id: String) -> bool:
	return owned_items.has(id)


func set_progress(id: String) -> void:
	progress = id


# ── Resets ─────────────────────────────────────────────────────────────

func _default_state() -> Dictionary:
	return {
		"hearts_halves": hearts_max_halves,
		"nunchi": 0,
		"ddeok": 0,
		"secrets_held": hand.duplicate(),
		"secrets_known_by": {},
		"spawn_seed": 0,
		"map_day": DEFAULT_MAP_DAY,
		"collected": {},
		"notes": _str_array([]),
		"talked": _str_array([]),
		"owned_items": _str_array([]),
		"scores": {},
		"outcomes": {},
		"progress": "",
		"codex": _str_array([]),
		"current_boss": "",
		"in_fight": false,
		"fight_snapshot": {},
	}


func _current_state() -> Dictionary:
	var state := {}
	for key in _default_state():
		state[key] = _deep_copy(get(key))
	return state


func _apply_state(state: Dictionary) -> void:
	for key in state:
		set(key, state[key])


func new_game() -> void:
	_apply_state(_default_state())
	progress = "scene_01"


func death_reset() -> void:
	_death_reset_keeping(PERSISTS_THROUGH_DEATH)


func _death_reset_keeping(keep: Array[String]) -> void:
	var kept := {}
	for key in keep:
		kept[key] = _deep_copy(get(key))
	_apply_state(_default_state())
	_apply_state(kept)
	progress = "scene_01"
	state_reset.emit()


func _deep_copy(v: Variant) -> Variant:
	return v.duplicate(true) if v is Array or v is Dictionary else v


# ── Saving ─────────────────────────────────────────────────────────────

func has_save() -> bool:
	return FileAccess.file_exists(save_path)


func save_game() -> Error:
	var envelope := {
		"game": GAME_ID,
		"save_version": SAVE_VERSION,
		"state_version": STATE_VERSION,
		"state": _current_state(),
	}
	var dir := save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var made := DirAccess.make_dir_recursive_absolute(dir)
		if made != OK:
			return made
	var tmp_path := save_path + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(envelope, "\t"))
	var write_err := file.get_error()
	file.close()
	if write_err != OK:
		DirAccess.remove_absolute(tmp_path)
		return write_err
	if FileAccess.file_exists(save_path):
		var copied := DirAccess.copy_absolute(save_path, save_path + ".bak")
		if copied != OK:
			DirAccess.remove_absolute(tmp_path)
			return copied
	var renamed := DirAccess.rename_absolute(tmp_path, save_path)
	if renamed != OK:
		DirAccess.remove_absolute(tmp_path)
	return renamed


## OK; ERR_FILE_NOT_FOUND; ERR_FILE_CORRUPT (state untouched);
## ERR_UNAVAILABLE (save written by a newer version; file untouched).
func load_game() -> Error:
	var candidates: Array[String] = []
	for path in [save_path, save_path + ".bak"]:
		if FileAccess.file_exists(path):
			candidates.append(path)
	if candidates.is_empty():
		return ERR_FILE_NOT_FOUND
	for path in candidates:
		var json := JSON.new()
		if json.parse(FileAccess.get_file_as_string(path)) != OK:
			continue
		var parsed = json.data
		if typeof(parsed) != TYPE_DICTIONARY:
			continue
		var version := 0
		var state = parsed
		if parsed.has("save_version"):
			if parsed.get("game") != GAME_ID or typeof(parsed["save_version"]) != TYPE_FLOAT \
					or typeof(parsed.get("state")) != TYPE_DICTIONARY:
				continue
			version = int(parsed["save_version"])
			state = parsed["state"]
		if version > SAVE_VERSION:
			return ERR_UNAVAILABLE
		if version < 0:
			continue
		while version < SAVE_VERSION:
			state = _migrate(state, version)
			version += 1
		_apply_state(_normalize(state))
		return OK
	return ERR_FILE_CORRUPT


func _migrate(state: Dictionary, from_version: int) -> Dictionary:
	match from_version:
		0:
			return _migrate_0_to_1(state)
	push_error("GameState: no migration from save version %d" % from_version)
	return state


## Version 0 was a bare state dictionary with no envelope. The field set is
## unchanged, so this only unwraps; renames from later versions go in their own step.
func _migrate_0_to_1(state: Dictionary) -> Dictionary:
	return state


## Fill missing keys with defaults, drop unknown keys, check types, clamp, dedupe.
func _normalize(raw: Dictionary) -> Dictionary:
	var out := _default_state()
	for key in out:
		if not raw.has(key):
			continue
		var v = raw[key]
		match key:
			"hearts_halves":
				out[key] = clampi(_as_int(v, out[key]), 0, hearts_max_halves)
			"nunchi":
				out[key] = clampi(_as_int(v, out[key]), 0, nunchi_cap)
			"ddeok":
				out[key] = maxi(_as_int(v, out[key]), 0)
			"spawn_seed":
				out[key] = _as_int(v, out[key])
			"progress", "current_boss":
				if typeof(v) == TYPE_STRING:
					out[key] = v
			"map_day":
				if typeof(v) == TYPE_STRING and v != "":
					out[key] = v
			"in_fight":
				if typeof(v) == TYPE_BOOL:
					out[key] = v
			"secrets_held":
				if typeof(v) == TYPE_ARRAY:
					out[key] = _only_hand(_str_array(v))
			"notes", "talked", "owned_items", "codex":
				if typeof(v) == TYPE_ARRAY:
					out[key] = _str_array(v)
			"secrets_known_by":
				if typeof(v) == TYPE_DICTIONARY:
					for card in v:
						if hand.has(card) and typeof(v[card]) == TYPE_ARRAY:
							out[key][card] = _str_array(v[card])
			"collected":
				if typeof(v) == TYPE_DICTIONARY:
					for map_key in v:
						if typeof(v[map_key]) == TYPE_ARRAY:
							out[key][str(map_key)] = _str_array(v[map_key])
			"scores":
				if typeof(v) == TYPE_DICTIONARY:
					for boss in v:
						if typeof(v[boss]) == TYPE_INT or typeof(v[boss]) == TYPE_FLOAT:
							out[key][str(boss)] = int(v[boss])
			"outcomes":
				if typeof(v) == TYPE_DICTIONARY:
					for boss in v:
						if OUTCOMES.has(v[boss]):
							out[key][str(boss)] = v[boss]
			"fight_snapshot":
				if typeof(v) == TYPE_DICTIONARY and v.has("hearts_halves") and v.has("nunchi"):
					out[key] = {
						"hearts_halves": clampi(_as_int(v["hearts_halves"], hearts_max_halves), 0, hearts_max_halves),
						"nunchi": clampi(_as_int(v["nunchi"], 0), 0, nunchi_cap),
					}
	if out["in_fight"] and out["fight_snapshot"].is_empty():
		out["in_fight"] = false
	if not out["in_fight"]:
		out["fight_snapshot"] = {}
	return out


func _as_int(v: Variant, fallback: int) -> int:
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_FLOAT and v == floorf(v):
		return int(v)
	return fallback


func _only_hand(cards: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for card in cards:
		if hand.has(card):
			result.append(card)
	return result


## Strings only, first occurrence wins.
func _str_array(source: Array) -> Array[String]:
	var result: Array[String] = []
	for item in source:
		if typeof(item) == TYPE_STRING and not result.has(item):
			result.append(item)
	return result
