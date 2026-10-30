# Loads and checks song files (data/songs/*.json, Systems Spec §6.4). Nothing here
# knows about a particular song or boss.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongData
extends RefCounted

const DIR := "res://data/songs"
const BLANK_MARK := "___"


## The parsed song, or {} (with a push_error) when the file is missing or invalid.
static func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("SongData: %s not found" % path)
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("SongData: %s is not a JSON object" % path)
		return {}
	var problems := validate(data)
	if not problems.is_empty():
		push_error("SongData: %s is invalid: %s" % [path, "; ".join(problems)])
		return {}
	return data


## Path of the song file whose "boss" is `boss`, or "".
static func find_for_boss(boss: String, dir: String = DIR) -> String:
	for file_name in DirAccess.get_files_at(dir):
		if file_name.get_extension() != "json":
			continue
		var data = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join(file_name)))
		if typeof(data) == TYPE_DICTIONARY and data.get("boss") == boss and data.has("phases"):
			return dir.path_join(file_name)
	return ""


## Every blank in song order, each with its phase number and section added.
static func flat_blanks(song: Dictionary) -> Array:
	var out: Array = []
	for phase in song.get("phases", []):
		for blank in phase.get("blanks", []):
			var b: Dictionary = blank.duplicate()
			b["phase"] = phase["phase"]
			b["section"] = phase.get("section", "")
			out.append(b)
	return out


## Human-readable problems; empty when the song is usable.
static func validate(song: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key in ["id", "title", "boss", "countdown", "phases", "lines", "game_over", "outcomes", "length"]:
		if not song.has(key):
			errors.append("missing '%s'" % key)
	if not errors.is_empty():
		return errors
	if float(song["countdown"]) <= 0.0:
		errors.append("countdown must be > 0")
	var blanks := flat_blanks(song)
	if blanks.is_empty():
		errors.append("no blanks")
	var seen := {}
	var last_time := -1.0
	for b in blanks:
		var n: int = int(b.get("n", -1))
		if seen.has(n):
			errors.append("duplicate blank %d" % n)
		seen[n] = true
		if not str(b.get("line", "")).contains(BLANK_MARK):
			errors.append("blank %d: line has no %s" % [n, BLANK_MARK])
		var options: Array = b.get("options", [])
		if options.size() < 2 or not options.has(b.get("answer")):
			errors.append("blank %d: answer is not among 2 or more options" % n)
		for key in ["attack", "counter"]:
			if str(b.get(key, "")) == "":
				errors.append("blank %d: no %s id" % [n, key])
		if float(b.get("time", -1.0)) < last_time:
			errors.append("blank %d: times must not go backwards" % n)
		last_time = float(b.get("time", -1.0))
	var line_time := -1.0
	for l in song["lines"]:
		if not (l.has("text") and l.has("time") and l.has("phase")):
			errors.append("a line lacks text, time or phase")
			break
		if float(l["time"]) < line_time:
			errors.append("line times must not go backwards")
			break
		line_time = float(l["time"])
	if float(song["length"]) <= line_time:
		errors.append("length must be after the last line")
	for key in ["revenge", "survival"]:
		if not song["outcomes"].has(key):
			errors.append("outcomes has no '%s'" % key)
	if str(song["game_over"].get("line", "")) == "":
		errors.append("game_over has no line")
	return errors
