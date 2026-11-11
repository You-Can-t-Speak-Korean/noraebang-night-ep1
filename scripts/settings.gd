# Player settings in a ConfigFile (user://settings.cfg). Only quick_heal_order for now, and no
# settings menu yet. Tests, captures and `-s` runs use user://sandbox/settings.cfg, never the real
# one (the same rule as the save: GameState.wants_sandbox).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Settings
extends RefCounted

const PATH := "user://settings.cfg"
const SANDBOX_PATH := "user://sandbox/settings.cfg"
const SECTION := "gameplay"
const HEAL_ORDERS: Array[String] = ["lowest_first", "highest_first"]
const DEFAULT_HEAL_ORDER := "lowest_first"


## quick_heal_order from `path`. A missing file is created with the default; a bad value is the default.
static func load_heal_order(path: String) -> String:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		save_heal_order(path, DEFAULT_HEAL_ORDER)
		return DEFAULT_HEAL_ORDER
	var v := str(cfg.get_value(SECTION, "quick_heal_order", DEFAULT_HEAL_ORDER))
	return v if HEAL_ORDERS.has(v) else DEFAULT_HEAL_ORDER


static func save_heal_order(path: String, order: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var cfg := ConfigFile.new()
	cfg.load(path)
	cfg.set_value(SECTION, "quick_heal_order", order if HEAL_ORDERS.has(order) else DEFAULT_HEAL_ORDER)
	return cfg.save(path)
