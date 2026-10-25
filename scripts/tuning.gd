# Reads movement tunables from data/config/tuning.json (GameState reads the rest).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends RefCounted

const PATH := "res://data/config/tuning.json"
const DEFAULT_LANE_COUNT := 3
const DEFAULT_LANE_SPACING := 1.5


## {"lane_count": int >= 1, "lane_spacing": float > 0}
static func lane_config() -> Dictionary:
	var config := {"lane_count": DEFAULT_LANE_COUNT, "lane_spacing": DEFAULT_LANE_SPACING}
	var data = JSON.parse_string(FileAccess.get_file_as_string(PATH)) if FileAccess.file_exists(PATH) else null
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Tuning: could not read %s, using lane defaults" % PATH)
		return config
	var count = data.get("lane_count")
	if (typeof(count) == TYPE_FLOAT or typeof(count) == TYPE_INT) and int(count) >= 1:
		config["lane_count"] = int(count)
	else:
		push_error("Tuning: lane_count missing or invalid, using %d" % DEFAULT_LANE_COUNT)
	var spacing = data.get("lane_spacing")
	if (typeof(spacing) == TYPE_FLOAT or typeof(spacing) == TYPE_INT) and float(spacing) > 0.0:
		config["lane_spacing"] = float(spacing)
	else:
		push_error("Tuning: lane_spacing missing or invalid, using %s" % DEFAULT_LANE_SPACING)
	return config
