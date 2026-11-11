# The store layer: every purchase goes through Store.buy(shop_id, item_id). A shop is a data file
# (data/shop/<shop_id>.json: shopkeeper, lines, stock of item id / price in DDEOK / quantity), so a
# second shop needs no code. Prices are DDEOK only; 눈치 is non-commercial and has no code path here
# (stock may only name ids from data/items/items.json). This layer is off-chain: it spends DDEOK and
# changes GameState.shop_stock through GameState; an on-chain backend can replace buy() later.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Store
extends RefCounted

const DEFAULT_DIR := "res://data/shop"
const REASONS: Array[String] = ["not_enough", "sold_out", "no_bag", "bag_full", "cannot_equip"]

## Where shop files are looked up (tests point it at a test directory; set it back to DEFAULT_DIR).
static var dir := DEFAULT_DIR
static var _cache: Dictionary = {}


static func _gs() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node("GameState")


## The shop's data: {"name", "shopkeeper": {"name", "label"}, "lines": {}, "stock": [{"item", "price", "quantity"}]}
## ({} for an unknown shop). Stock entries with an unknown item id are dropped.
static func load_shop(shop_id: String) -> Dictionary:
	var path := "%s/%s.json" % [dir, shop_id]
	if _cache.has(path):
		return _cache[path]
	var out := {}
	if FileAccess.file_exists(path):
		var data = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(data) == TYPE_DICTIONARY:
			out = {"name": str(data.get("name", shop_id)), "shopkeeper": {}, "lines": {}, "stock": []}
			var keeper = data.get("shopkeeper", {})
			if typeof(keeper) == TYPE_DICTIONARY:
				out["shopkeeper"] = {"name": str(keeper.get("name", "")), "label": str(keeper.get("label", keeper.get("name", "")))}
			var lines = data.get("lines", {})
			if typeof(lines) == TYPE_DICTIONARY:
				for k in lines:
					out["lines"][str(k)] = str(lines[k])
			var seen := {}
			for e in data.get("stock", []):
				if typeof(e) != TYPE_DICTIONARY:
					continue
				var id := str(e.get("item", ""))
				if not Items.exists(id) or seen.has(id):
					push_error("Store: shop '%s' lists '%s', which is not an item; ignoring it" % [shop_id, id])
					continue
				seen[id] = true
				out["stock"].append({"item": id, "price": maxi(int(e.get("price", 0)), 0), "quantity": maxi(int(e.get("quantity", 0)), 0)})
		else:
			push_error("Store: could not read %s" % path)
	_cache[path] = out
	return out


static func clear_cache() -> void:
	_cache = {}


static func exists(shop_id: String) -> bool:
	return not load_shop(shop_id).is_empty()


## Every shop id in `dir`, sorted.
static func shop_ids() -> Array:
	var out: Array = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out


static func stock_entries(shop_id: String) -> Array:
	return load_shop(shop_id).get("stock", [])


## {item id: quantity} as the data starts it.
static func starting_stock(shop_id: String) -> Dictionary:
	var out := {}
	for e in stock_entries(shop_id):
		out[e["item"]] = int(e["quantity"])
	return out


## {shop id: {item id: quantity}} for every shop file: what a new game, a death reset and a
## migrated old save start with.
static func starting_stock_all() -> Dictionary:
	var out := {}
	for id in shop_ids():
		if exists(id):
			out[id] = starting_stock(id)
	return out


## The price in DDEOK, or -1 if the shop does not sell this item.
static func price(shop_id: String, item_id: String) -> int:
	for e in stock_entries(shop_id):
		if e["item"] == item_id:
			return int(e["price"])
	return -1


## How many of `item_id` the shop has left in this save (the data's quantity until the first sale).
static func stock_left(shop_id: String, item_id: String) -> int:
	var stock: Dictionary = _gs().shop_stock
	if stock.has(shop_id) and stock[shop_id].has(item_id):
		return int(stock[shop_id][item_id])
	return int(starting_stock(shop_id).get(item_id, 0))


static func line(shop_id: String, key: String) -> String:
	return str(load_shop(shop_id).get("lines", {}).get(key, ""))


## The name the speaker label shows ("문방구 할머니").
static func speaker(shop_id: String) -> String:
	return str(load_shop(shop_id).get("shopkeeper", {}).get("label", ""))


## What handing over `item_id` would need, checked on a copy: "" if it would work, else a reason.
static func grant_problem(item_id: String) -> String:
	var inv: Dictionary = _gs().inventory.duplicate(true)
	if Items.is_heal(item_id):
		if not Inventory.has_bag(inv):
			return "no_bag"
		return "" if Inventory.store(inv, item_id) != "" else "bag_full"
	if ["equip", "nest", "upgrade"].has(Inventory.give_result(inv, item_id)):
		return ""
	return "cannot_equip"


## Buys one `item_id` from shop `shop_id`. {"ok": bool, "reason": "" or one of REASONS (or
## "unknown" for a shop or item that does not exist), "item", "price"}. Checks the stock, then the
## DDEOK, then whether the item can be carried; only a sale that passes all three spends DDEOK, hands
## the item over (the 5a inventory rules) and lowers the stock.
static func buy(shop_id: String, item_id: String) -> Dictionary:
	var result := {"ok": false, "reason": "unknown", "item": item_id, "price": 0}
	var cost := price(shop_id, item_id)
	if cost < 0:
		return result
	result["price"] = cost
	if stock_left(shop_id, item_id) <= 0:
		result["reason"] = "sold_out"
		return result
	var gs := _gs()
	if gs.ddeok < cost:
		result["reason"] = "not_enough"
		return result
	var problem := grant_problem(item_id)
	if problem != "":
		result["reason"] = problem
		return result
	if cost > 0 and not gs.spend_ddeok(cost):
		result["reason"] = "not_enough"
		return result
	if not gs.give_item(item_id):
		if cost > 0:
			gs.add_ddeok(cost)
		result["reason"] = "cannot_equip"
		return result
	gs.set_shop_stock(shop_id, item_id, stock_left(shop_id, item_id) - 1)
	result["ok"] = true
	result["reason"] = ""
	return result
