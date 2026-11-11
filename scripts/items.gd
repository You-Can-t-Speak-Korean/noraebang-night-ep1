# Item data (data/items/items.json) and boss rewards (data/items/rewards.json).
# Pure lookups; the logic that uses them is in Inventory and GameState. New items are data only.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Items
extends RefCounted

const ITEMS_PATH := "res://data/items/items.json"
const REWARDS_PATH := "res://data/items/rewards.json"

static var _items: Dictionary = {}
static var _rewards: Dictionary = {}
static var _loaded := false


## (Re)loads both files. Tests pass other paths; call with no arguments to go back to the real data.
static func load_data(items_path: String = ITEMS_PATH, rewards_path: String = REWARDS_PATH) -> void:
	_items = {}
	_rewards = {}
	_loaded = true
	var data = _read_json(items_path)
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("items")) != TYPE_DICTIONARY:
		push_error("Items: could not read %s, there are no items" % items_path)
	else:
		for id in data["items"]:
			if typeof(data["items"][id]) == TYPE_DICTIONARY:
				_items[str(id)] = data["items"][id]
	var rewards = _read_json(rewards_path)
	if typeof(rewards) != TYPE_DICTIONARY:
		push_error("Items: could not read %s, there are no rewards" % rewards_path)
	else:
		for boss in rewards:
			if typeof(rewards[boss]) == TYPE_DICTIONARY:
				_rewards[str(boss)] = rewards[boss]


static func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func _ensure() -> void:
	if not _loaded:
		load_data()


static func ids() -> Array:
	_ensure()
	return _items.keys()


static func exists(id: String) -> bool:
	_ensure()
	return _items.has(id)


## The item's data dictionary ({} for an unknown id).
static func get_item(id: String) -> Dictionary:
	_ensure()
	return _items.get(id, {})


static func item_name(id: String) -> String:
	return str(get_item(id).get("name", id))


static func kind(id: String) -> String:
	return str(get_item(id).get("kind", ""))


static func is_heal(id: String) -> bool:
	return kind(id) == "heal"


static func heal_halves(id: String) -> int:
	return maxi(int(get_item(id).get("heal_halves", 0)), 0)


## Slots a bag has (0 for anything else).
static func slots(id: String) -> int:
	return maxi(int(get_item(id).get("slots", 0)), 0) if kind(id) == "bag" else 0


## Pages a notebook has (0 for anything else).
static func pages(id: String) -> int:
	return maxi(int(get_item(id).get("pages", 0)), 0) if kind(id) == "notebook" else 0


static func size_in_bag(id: String) -> int:
	return maxi(int(get_item(id).get("size_in_bag", 1)), 0)


## How many of this item share one slot (default 1).
static func stack_max(id: String) -> int:
	return maxi(int(get_item(id).get("stack_max", 1)), 1)


## The items `boss`'s fight gives for `outcome`: [{"item": id, "unless_equipped_kind": kind or ""}].
static func rewards(boss: String, outcome: String) -> Array:
	_ensure()
	var out: Array = []
	var by_outcome = _rewards.get(boss, {})
	if typeof(by_outcome) != TYPE_DICTIONARY or typeof(by_outcome.get(outcome)) != TYPE_ARRAY:
		return out
	for r in by_outcome[outcome]:
		if typeof(r) == TYPE_DICTIONARY and exists(str(r.get("item", ""))):
			out.append({"item": str(r["item"]), "unless_equipped_kind": str(r.get("unless_equipped_kind", ""))})
	return out


## "이" or "가" for a Korean noun: 이 after a final consonant, else 가.
static func josa_i_ga(word: String) -> String:
	if word == "":
		return "이"
	var code := word.unicode_at(word.length() - 1)
	if code >= 0xAC00 and code <= 0xD7A3 and (code - 0xAC00) % 28 == 0:
		return "가"
	return "이"
