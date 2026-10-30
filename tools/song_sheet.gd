# Reads a song sheet (docs/songs/songsheet-*.md) into plain data: the lyrics code
# block (§2), the blank table (§3), the loaded-blank table (§4) and the game-over
# anchor line (§5). Used by tools/build_song.gd to write the song JSON and by the
# tests to check that JSON against the doc. Knows nothing about any one song.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongSheet
extends RefCounted

const PHASE_NAMES := {"Verse": 1, "Chorus": 2, "Bridge": 3, "Final": 4}


## {"title", "lyrics": [{"kind": "intro"|"lyric"|"outro", "phase": int, "section": String,
## "speaker": String, "text": String (blank as "___"), "blank": int (0 = none), "answer": String}],
## "blanks": {n: {"n", "phase_name", "line", "options", "answer", "teaches"}},
## "loaded": [{"card_name", "blank", "extra_option"}], "anchor": String, "errors": [String]}
static func parse(markdown: String) -> Dictionary:
	var out := {"title": "", "lyrics": [], "blanks": {}, "loaded": [], "anchor": "", "errors": []}
	var in_block := false
	var phase := 0
	var section := ""
	var kind := ""
	var header := RegEx.create_from_string("^\\[(Intro|Outro|Phase (\\d) — ([^—\\]]+?))\\s*(?:—.*)?\\]")
	var blank_re := RegEx.create_from_string("^(.*)⟦([^⟧]+)⟧(.*?)\\s*\\[(\\d+)\\]\\s*$")
	var anchor_re := RegEx.create_from_string("^>\\s*\\*\"(.+)\"\\*\\s*$")
	for raw in markdown.split("\n"):
		var line: String = raw.strip_edges(false, true)
		if line.begins_with("```"):
			if in_block:
				in_block = false
			elif out["lyrics"].is_empty() and out["title"] == "":
				in_block = true
			continue
		if in_block:
			if line.strip_edges() == "":
				continue
			if line.begins_with("〈"):
				out["title"] = line.trim_prefix("〈").trim_suffix("〉")
				continue
			var m := header.search(line)
			if m != null:
				if m.get_string(1) == "Intro":
					kind = "intro"
					phase = 1
					section = "Intro"
				elif m.get_string(1) == "Outro":
					kind = "outro"
					phase = 4
					section = "Outro"
				else:
					kind = "lyric"
					phase = int(m.get_string(2))
					section = m.get_string(3).strip_edges()
				continue
			if line.begins_with("("):
				continue  # a stage direction, not a lyric
			var entry := {"kind": kind, "phase": phase, "section": section, "speaker": "", "text": line, "blank": 0, "answer": ""}
			if kind == "intro" or kind == "outro":
				var colon := line.find(": ")
				entry["speaker"] = line.substr(0, colon)
				entry["text"] = line.substr(colon + 2)
			var b := blank_re.search(line)
			if b != null:
				entry["text"] = "%s___%s" % [b.get_string(1), b.get_string(3)]
				entry["answer"] = b.get_string(2)
				entry["blank"] = int(b.get_string(4))
			out["lyrics"].append(entry)
			continue
		var a := anchor_re.search(line)
		if a != null:
			out["anchor"] = a.get_string(1)
		if line.begins_with("|"):
			var cells: Array[String] = []
			for c in line.trim_prefix("|").trim_suffix("|").split("|"):
				cells.append(c.strip_edges())
			if cells.size() >= 8 and cells[0].is_valid_int():
				var n := int(cells[0])
				out["blanks"][n] = {"n": n, "phase_name": cells[1], "line": cells[2],
						"options": _split_options(cells[3]), "answer": cells[4].replace("*", ""), "teaches": cells[5]}
			elif cells.size() >= 3 and cells[1].begins_with("#"):
				var hangul := -1
				for i in cells[0].length():
					if cells[0].unicode_at(i) >= 0xAC00 and cells[0].unicode_at(i) <= 0xD7A3:
						hangul = i
						break
				out["loaded"].append({"card_name": cells[0].substr(hangul) if hangul != -1 else cells[0],
						"blank": int(cells[1].trim_prefix("#").split(" ")[0]), "extra_option": cells[2]})
	if out["title"] == "" or out["lyrics"].is_empty():
		out["errors"].append("no lyrics block found")
	if out["anchor"] == "":
		out["errors"].append("no game-over anchor line found")
	return out


static func _split_options(cell: String) -> Array[String]:
	var result: Array[String] = []
	for part in cell.split(" / "):
		result.append(part.strip_edges())
	return result


## "Verse" -> 1, "Chorus" -> 2, "Bridge" -> 3, "Final" -> 4 (the table's Phase column).
static func phase_of(phase_name: String) -> int:
	return PHASE_NAMES.get(phase_name, 0)
