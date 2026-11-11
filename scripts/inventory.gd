# The rules of 보람's containers, as pure functions on a plain dictionary (so a save, a fight
# snapshot and a test can all hold one):
#   {"bag": item id or "", "bag_items": [heal item ids], "case": nested bag id or "",
#    "case_items": [heal item ids in the nested bag], "notebook": item id or ""}
# The bag slot holds a 필통 or a 책가방; a bag with size_in_bag > 0 (the 필통) can ride inside a bag
# with size_in_bag 0 (the 책가방), taking size_in_bag of its slots and keeping its own slots and
# contents. One level only. The notebook's notes live in GameState.notes (one per page).
# Item numbers come from data/items/items.json (Items); nothing here names an item.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Inventory
extends RefCounted


static func empty() -> Dictionary:
	return {"bag": "", "bag_items": [], "case": "", "case_items": [], "notebook": ""}


static func has_bag(inv: Dictionary) -> bool:
	return str(inv.get("bag", "")) != ""


static func has_notebook(inv: Dictionary) -> bool:
	return str(inv.get("notebook", "")) != ""


static func notebook_pages(inv: Dictionary) -> int:
	return Items.pages(str(inv.get("notebook", "")))


## Slots `items` take, with stacking: each distinct item takes ceil(count / stack_max).
static func slots_used(items: Array) -> int:
	var counts := {}
	for id in items:
		counts[id] = int(counts.get(id, 0)) + 1
	var used := 0
	for id in counts:
		used += ceili(counts[id] / float(Items.stack_max(str(id))))
	return used


## Slots the nested bag takes out of the equipped bag (0 when none is nested).
static func nested_size(inv: Dictionary) -> int:
	var c := str(inv.get("case", ""))
	return Items.size_in_bag(c) if c != "" else 0


static func bag_capacity(inv: Dictionary) -> int:
	return Items.slots(str(inv.get("bag", "")))


static func bag_used(inv: Dictionary) -> int:
	return slots_used(inv.get("bag_items", [])) + nested_size(inv)


static func case_capacity(inv: Dictionary) -> int:
	return Items.slots(str(inv.get("case", "")))


## The containers that hold items, equipped bag first, then the nested one:
## [{"key": "bag" | "case", "id", "capacity", "used", "items": Array}] (items is the live array).
static func groups(inv: Dictionary) -> Array:
	var out: Array = []
	if has_bag(inv):
		out.append({"key": "bag", "id": inv["bag"], "capacity": bag_capacity(inv), "used": bag_used(inv), "items": inv["bag_items"]})
	if str(inv.get("case", "")) != "":
		out.append({"key": "case", "id": inv["case"], "capacity": case_capacity(inv), "used": slots_used(inv["case_items"]), "items": inv["case_items"]})
	return out


## True when container `key` can take one more `item_id` (a free slot, or room in a stack).
static func can_hold(inv: Dictionary, key: String, item_id: String) -> bool:
	for g in groups(inv):
		if g["key"] == key:
			var after: int = slots_used(g["items"] + [item_id]) + (nested_size(inv) if key == "bag" else 0)
			return after <= int(g["capacity"])
	return false


## Puts one health item in the first container with room. The container's key, or "" when
## there is no bag or every container is full.
static func store(inv: Dictionary, item_id: String) -> String:
	if not Items.is_heal(item_id):
		return ""
	for g in groups(inv):
		if can_hold(inv, g["key"], item_id):
			g["items"].append(item_id)
			return g["key"]
	return ""


## The equipped bag's item id: the container a "full" message names ("" with no bag).
static func main_container(inv: Dictionary) -> String:
	return str(inv.get("bag", ""))


## One entry per health item held: [{"key", "id"}], equipped bag first.
static func heal_entries(inv: Dictionary) -> Array:
	var out: Array = []
	for g in groups(inv):
		for id in g["items"]:
			out.append({"key": g["key"], "id": id})
	return out


## Takes one `item_id` out of container `key`. False if it is not there.
static func remove_unit(inv: Dictionary, key: String, item_id: String) -> bool:
	for g in groups(inv):
		if g["key"] == key:
			var at: int = g["items"].find(item_id)
			if at == -1:
				return false
			g["items"].remove_at(at)
			return true
	return false


## Can `guest` ride inside `host`? Both bags, the guest has a size, the host does not.
static func nestable_in(host: String, guest: String) -> bool:
	return Items.kind(host) == "bag" and Items.kind(guest) == "bag" and Items.size_in_bag(host) == 0 \
			and Items.size_in_bag(guest) > 0 and Items.size_in_bag(guest) < Items.slots(host)


## What handing the player container `id` does: "equip" (that slot was empty), "nest" (a bag rides
## in the equipped one), "upgrade" (the equipped bag moves inside the new one), "swap" (it replaces
## the equipped bag; see swap_plan) or "none" (already carrying one of it).
static func give_result(inv: Dictionary, id: String) -> String:
	match Items.kind(id):
		"notebook":
			return "none" if has_notebook(inv) else "equip"
		"bag":
			if not has_bag(inv):
				return "equip"
			var cur := str(inv["bag"])
			if cur == id:
				return "none"
			if nestable_in(cur, id):
				return "none" if str(inv["case"]) != "" else "nest"
			if nestable_in(id, cur) and str(inv["case"]) == "":
				return "upgrade"
			return "swap"
	return "none"


## Does the "equip", "nest" or "upgrade" of give_result. False for anything else.
static func give(inv: Dictionary, id: String) -> bool:
	match give_result(inv, id):
		"equip":
			if Items.kind(id) == "notebook":
				inv["notebook"] = id
			else:
				inv["bag"] = id
				inv["bag_items"] = []
			return true
		"nest":
			inv["case"] = id
			inv["case_items"] = []
			return true
		"upgrade":
			inv["case"] = inv["bag"]
			inv["case_items"] = inv["bag_items"]
			inv["bag"] = id
			inv["bag_items"] = []
			return true
	return false


## Replacing the equipped bag with `new_id` puts every health item into the new bag (a nested bag
## goes away). {"items": the ids to place, "capacity": the new bag's slots, "over": true when they do not fit}.
static func swap_plan(inv: Dictionary, new_id: String) -> Dictionary:
	var items: Array = (inv.get("bag_items", []) + inv.get("case_items", [])).duplicate()
	var capacity := Items.slots(new_id)
	return {"items": items, "capacity": capacity, "over": slots_used(items) > capacity}


## Does the swap, dropping the items at `drop` (indices into swap_plan's items). Returns
## {"ok": bool, "dropped": [ids]}; not ok (and nothing changed) if what is left still does not fit.
static func swap(inv: Dictionary, new_id: String, drop: Array = []) -> Dictionary:
	if Items.kind(new_id) != "bag":
		return {"ok": false, "dropped": []}
	var plan := swap_plan(inv, new_id)
	var keep: Array = []
	var dropped: Array = []
	for i in plan["items"].size():
		if drop.has(i):
			dropped.append(plan["items"][i])
		else:
			keep.append(plan["items"][i])
	if slots_used(keep) > int(plan["capacity"]):
		return {"ok": false, "dropped": []}
	inv["bag"] = new_id
	inv["bag_items"] = keep
	inv["case"] = ""
	inv["case_items"] = []
	return {"ok": true, "dropped": dropped}


## A valid inventory from whatever was saved: unknown ids dropped, contents cut to their capacity.
static func normalize(raw: Variant) -> Dictionary:
	var out := empty()
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	var bag = raw.get("bag", "")
	if typeof(bag) == TYPE_STRING and Items.kind(bag) == "bag":
		out["bag"] = bag
		out["bag_items"] = _fit(raw.get("bag_items", []), Items.slots(bag))
		var c = raw.get("case", "")
		if typeof(c) == TYPE_STRING and c != "" and nestable_in(bag, c):
			out["case"] = c
			out["case_items"] = _fit(raw.get("case_items", []), Items.slots(c))
			out["bag_items"] = _fit(out["bag_items"], Items.slots(bag) - Items.size_in_bag(c))
	var nb = raw.get("notebook", "")
	if typeof(nb) == TYPE_STRING and Items.kind(nb) == "notebook":
		out["notebook"] = nb
	return out


## `items` without the unknown or non-health ids and without what does not fit in `capacity` slots.
static func _fit(items: Variant, capacity: int) -> Array:
	var out: Array = []
	if typeof(items) != TYPE_ARRAY:
		return out
	for id in items:
		if typeof(id) == TYPE_STRING and Items.is_heal(id) and slots_used(out + [id]) <= capacity:
			out.append(id)
	return out
