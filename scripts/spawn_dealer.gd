# Deals a map-day's DDEOK, notes, health items and traps into its pool of
# search spots. Pure: the same inputs always give the same layout.
#
# Spot ids and entries:
#   spots   spot_id -> {"room", "days": [..], "trap": {"name", "damage" (halves), "weight"} (optional)}
#   budget  {"ddeok", "ddeok_amount", "extras", "traps"} for the whole map-day
#   extras  id -> {"kind": "note", "weight", "ids": [note ids]} or
#                 {"kind": "health", "weight", "name", "heal" (halves)}
#   result  spot_id -> {"kind": "ddeok" | "note" | "health" | "trap", ...}
# A spot missing from the result holds nothing.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends RefCounted

const SPAWNS_PATH := "res://data/spawns/map_01.json"
const NOTES_PATH := "res://data/notes/act1_notes.json"


## Loads spawn data and notes into one config:
## {"spots", "budgets", "extras", "lines", "notes": id -> text}. Empty on bad data.
static func load_config(spawns_path: String = SPAWNS_PATH, notes_path: String = NOTES_PATH) -> Dictionary:
	var data = _read_json(spawns_path)
	var note_list = _read_json(notes_path)
	if typeof(data) != TYPE_DICTIONARY or typeof(note_list) != TYPE_ARRAY:
		push_error("SpawnDealer: could not read %s or %s" % [spawns_path, notes_path])
		return {}
	var notes := {}
	for n in note_list:
		if typeof(n) == TYPE_DICTIONARY and typeof(n.get("id")) == TYPE_STRING and typeof(n.get("text")) == TYPE_STRING:
			notes[n["id"]] = n["text"]
	var extras: Dictionary = data.get("extras", {})
	for id in extras:
		if extras[id].get("kind") == "note":
			extras[id]["ids"] = notes.keys()
	var config := {
		"spots": data.get("spots", {}),
		"budgets": data.get("budgets", {}),
		"extras": extras,
		"lines": data.get("lines", {}),
		"notes": notes,
	}
	if config["spots"].is_empty() or config["budgets"].is_empty():
		push_error("SpawnDealer: %s has no spots or budgets" % spawns_path)
		return {}
	return config


static func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


## `collected` is the entry list for this map-day ("<spot_id>:<kind>").
static func deal(spots: Dictionary, budget: Dictionary, extras: Dictionary, seed: int,
		collected: Array, notes_owned: Array, day: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var searched := {}
	var taken := {"ddeok": 0, "extras": 0, "traps": 0}
	for entry in collected:
		var parts := str(entry).split(":")
		if parts.size() != 2:
			continue
		searched[parts[0]] = true
		match parts[1]:
			"ddeok":
				taken["ddeok"] += 1
			"note", "health":
				taken["extras"] += 1
			"trap":
				taken["traps"] += 1

	var ids: Array = spots.keys()
	ids.sort()
	var pool: Array = ids.filter(func(id): return spots[id].get("days", []).has(day) and not searched.has(id))
	var layout := {}

	# Traps first: weighted, without replacement, only spots that carry a trap.
	var trap_spots: Array = pool.filter(func(id): return _trap_weight(spots[id]) > 0)
	var traps_left := maxi(int(budget.get("traps", 0)) - taken["traps"], 0)
	for i in mini(traps_left, trap_spots.size()):
		var total := 0
		for id in trap_spots:
			total += _trap_weight(spots[id])
		var roll := rng.randi_range(0, total - 1)
		for id in trap_spots:
			roll -= _trap_weight(spots[id])
			if roll < 0:
				var trap: Dictionary = spots[id]["trap"]
				layout[id] = {"kind": "trap", "name": trap["name"], "damage": int(trap["damage"])}
				trap_spots.erase(id)
				pool.erase(id)
				break

	# Rewards go to the rest of the pool in a seeded shuffle.
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var rewards: Array = []
	var ddeok_left := maxi(int(budget.get("ddeok", 0)) - taken["ddeok"], 0)
	for i in ddeok_left:
		rewards.append({"kind": "ddeok", "amount": int(budget.get("ddeok_amount", 1))})
	var dealt_notes: Array = []
	var extras_left := maxi(int(budget.get("extras", 0)) - taken["extras"], 0)
	for i in extras_left:
		var pick := _pick_extra(extras, rng, notes_owned, dealt_notes)
		if not pick.is_empty():
			rewards.append(pick)
			if pick["kind"] == "note":
				dealt_notes.append(pick["note_id"])
	for i in mini(rewards.size(), pool.size()):
		layout[pool[i]] = rewards[i]
	return layout


static func _trap_weight(spot: Dictionary) -> int:
	var trap = spot.get("trap")
	if typeof(trap) != TYPE_DICTIONARY:
		return 0
	return maxi(int(trap.get("weight", 0)), 0)


## One weighted extra. Notes the player owns (or that were already dealt) are
## never offered; a note extra with none left is skipped.
static func _pick_extra(extras: Dictionary, rng: RandomNumberGenerator, notes_owned: Array, dealt_notes: Array) -> Dictionary:
	var keys: Array = extras.keys()
	keys.sort()
	var options: Array = []
	var total := 0
	for key in keys:
		var extra: Dictionary = extras[key]
		var weight := maxi(int(extra.get("weight", 0)), 0)
		if weight == 0:
			continue
		if extra.get("kind") == "note" and _free_notes(extra, notes_owned, dealt_notes).is_empty():
			continue
		options.append(key)
		total += weight
	if options.is_empty():
		return {}
	var roll := rng.randi_range(0, total - 1)
	for key in options:
		var extra: Dictionary = extras[key]
		roll -= int(extra["weight"])
		if roll < 0:
			if extra["kind"] == "note":
				var free := _free_notes(extra, notes_owned, dealt_notes)
				return {"kind": "note", "note_id": free[rng.randi_range(0, free.size() - 1)]}
			return {"kind": "health", "item": key, "name": extra.get("name", key), "heal": int(extra.get("heal", 1))}
	return {}


static func _free_notes(extra: Dictionary, notes_owned: Array, dealt_notes: Array) -> Array:
	var free: Array = []
	var all: Array = extra.get("ids", [])
	all.sort()
	for id in all:
		if not notes_owned.has(id) and not dealt_notes.has(id):
			free.append(id)
	return free
