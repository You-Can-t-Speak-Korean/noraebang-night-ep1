# Resolves attack and counter ids from a song file to their placeholder look
# (data/fight/registry.json). An id the registry does not know gets the fallback
# look with "placeholder": true, so a new song plays before its art exists.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name FightRegistry
extends RefCounted

const PATH := "res://data/fight/registry.json"
const FALLBACK_ATTACK := {"color": "#8a8a8a", "size": [0.5, 0.5, 0.5]}
const FALLBACK_COUNTER := {"tone": "slapstick"}
const FALLBACK_FLOURISH := {"shake": 0.35, "extra_splats": 1, "label": "LOADED"}

var _attacks: Dictionary = {}
var _counters: Dictionary = {}
var _fallback_attack: Dictionary = FALLBACK_ATTACK
var _fallback_counter: Dictionary = FALLBACK_COUNTER
var _flourish: Dictionary = FALLBACK_FLOURISH
var _sfx: Dictionary = {}


func _init(path: String = PATH) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if typeof(data) != TYPE_DICTIONARY:
		push_error("FightRegistry: could not read %s, every id will use the fallback" % path)
		return
	_attacks = data.get("attacks", {})
	_counters = data.get("counters", {})
	var fb: Dictionary = data.get("fallback", {})
	_fallback_attack = fb.get("attack", FALLBACK_ATTACK)
	_fallback_counter = fb.get("counter", FALLBACK_COUNTER)
	_flourish = data.get("loaded_flourish", FALLBACK_FLOURISH)
	_sfx = data.get("sfx", {})


## {"id", "color": Color, "size": Vector3, "placeholder": bool}
func attack(id: String) -> Dictionary:
	var known := _attacks.has(id)
	var entry: Dictionary = _attacks[id] if known else _fallback_attack
	var s: Array = entry.get("size", FALLBACK_ATTACK["size"])
	return {"id": id, "color": Color.from_string(str(entry.get("color", "#8a8a8a")), Color.GRAY),
			"size": Vector3(s[0], s[1], s[2]), "placeholder": not known}


## {"id", "tone": "slapstick" | "gory", "placeholder": bool}
func counter(id: String) -> Dictionary:
	var known := _counters.has(id)
	var entry: Dictionary = _counters[id] if known else _fallback_counter
	return {"id": id, "tone": str(entry.get("tone", "slapstick")), "placeholder": not known}


## The sound effect file for `id` (e.g. "wrong_scream"), or "" when the registry names none.
## With a list this is the first path; see sfx_list.
func sfx(id: String) -> String:
	var list := sfx_list(id)
	return list[0] if not list.is_empty() else ""


## Every sound effect path for `id`: the registry entry may be a list of paths or (old data) a single string.
func sfx_list(id: String) -> Array[String]:
	var out: Array[String] = []
	var v = _sfx.get(id, null)
	if v is Array:
		for p in v:
			if str(p) != "":
				out.append(str(p))
	elif v != null and str(v) != "":
		out.append(str(v))
	return out


## The nastier landing of a loaded blank's attack: {"shake": float (screen shake, 0 = none),
## "extra_splats": int (blood bursts on top of the usual one), "label": String (shown with the card id)}.
func loaded_flourish() -> Dictionary:
	return {"shake": float(_flourish.get("shake", FALLBACK_FLOURISH["shake"])),
			"extra_splats": int(_flourish.get("extra_splats", FALLBACK_FLOURISH["extra_splats"])),
			"label": str(_flourish.get("label", FALLBACK_FLOURISH["label"]))}
