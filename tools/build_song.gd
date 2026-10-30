# Writes data/songs/eunju_dalnim.json from the song sheet (never retyped).
#   godot --headless --path . -s res://tools/build_song.gd
# The attack ids below are the only hand-written part: the sheet describes the
# attacks in English prose, so each gets a snake_case id here. Counter ids follow
# Systems Spec §6.5: the attack id plus _slapstick or _gory (the sheet's 🤡 / 🩸).
# Placeholder line times come from tuning.json (song_first_line_time, song_line_gap).
# Stops with a message, writing nothing, if the sheet is inconsistent with itself.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends SceneTree

const TuningScript := preload("res://scripts/tuning.gd")
const SHEET := "res://docs/songs/songsheet-01-eunju-dalnim-v0.2.md"
const OUT := "res://data/songs/eunju_dalnim.json"
const CARDS := "res://data/secrets/act1_cards.json"
const SONG_ID := "eunju_dalnim"
const BOSS := "eunju"
const COUNTDOWN := 5.0
## blank number -> [attack id, "slapstick" | "gory"]
const ATTACKS := {
	1: ["booger_flick", "slapstick"],
	2: ["soda_bottle_rocket", "slapstick"],
	3: ["candle_hairspray_flame", "slapstick"],
	4: ["thumbtack_party_popper", "slapstick"],
	5: ["cake_knife_throw", "slapstick"],
	6: ["party_hat_cone_stab", "slapstick"],
	7: ["paper_doll_blade_storm", "gory"],
	8: ["mic_cord_electrocution", "gory"],
	9: ["booger_sniper", "gory"],
	10: ["color_tv_drop", "gory"],
}


func _initialize() -> void:
	var errors := build()
	if not errors.is_empty():
		for e in errors:
			printerr("build_song: ", e)
		quit(1)
		return
	print("build_song: wrote ", OUT)
	quit(0)


## Returns the problems found; writes OUT only when there are none.
func build() -> Array[String]:
	var errors: Array[String] = []
	if not FileAccess.file_exists(SHEET):
		errors.append("missing %s" % SHEET)
		return errors
	var sheet := SongSheet.parse(FileAccess.get_file_as_string(SHEET))
	errors.append_array(sheet["errors"])
	var cfg: Dictionary = TuningScript.fight_config()
	var names := {}
	for card in JSON.parse_string(FileAccess.get_file_as_string(CARDS))["cards"]:
		names[card["name"]] = card["id"]

	# Lines in order. The spoken intro is at 0; lyric k (0-based) is first_line_time + k * gap;
	# the spoken outro takes the next slot.
	var lines: Array = []
	var line_of_blank := {}
	var slot := 0
	for l in sheet["lyrics"]:
		var t := 0.0
		if l["kind"] != "intro":
			t = cfg["first_line_time"] + slot * cfg["line_gap"]
			slot += 1
		var entry := {"kind": l["kind"], "phase": l["phase"], "time": snappedf(t, 0.001), "text": l["text"]}
		if l["speaker"] != "":
			entry["speaker"] = l["speaker"]
		if l["blank"] != 0:
			entry["blank"] = l["blank"]
			line_of_blank[l["blank"]] = entry
		lines.append(entry)

	# Blanks, grouped by phase.
	var phases: Array = []
	for n in range(1, sheet["blanks"].size() + 1):
		if not sheet["blanks"].has(n):
			errors.append("blank %d missing from the blank table" % n)
			continue
		var b: Dictionary = sheet["blanks"][n]
		if not line_of_blank.has(n):
			errors.append("blank %d has no [%d] marker in the lyrics" % [n, n])
			continue
		var lyric: Dictionary = line_of_blank[n]
		if not lyric["text"].begins_with(b["line"]):  # the table may abbreviate a line (#4)
			errors.append("blank %d: lyrics say '%s' but the table says '%s'" % [n, lyric["text"], b["line"]])
		var phase := SongSheet.phase_of(b["phase_name"])
		if phase == 0 or phase != lyric["phase"]:
			errors.append("blank %d: table phase '%s' does not match its lyric section" % [n, b["phase_name"]])
		if not b["options"].has(b["answer"]):
			errors.append("blank %d: answer '%s' is not among the options" % [n, b["answer"]])
		if not ATTACKS.has(n):
			errors.append("blank %d has no attack id in build_song.gd" % n)
			continue
		var attack: String = ATTACKS[n][0]
		var entry := {"n": n, "time": lyric["time"], "line": lyric["text"], "options": b["options"],
				"answer": b["answer"], "teaches": b["teaches"], "attack": attack,
				"counter": "%s_%s" % [attack, ATTACKS[n][1]]}
		if phases.is_empty() or phases[-1]["phase"] != phase:
			phases.append({"phase": phase, "section": _section_of(sheet, phase), "blanks": []})
		phases[-1]["blanks"].append(entry)

	var loaded: Array = []
	for item in sheet["loaded"]:
		if not names.has(item["card_name"]):
			errors.append("loaded card '%s' is not in %s" % [item["card_name"], CARDS])
			continue
		loaded.append({"card": names[item["card_name"]], "blank": item["blank"], "extra_option": item["extra_option"]})
	if not errors.is_empty():
		return errors

	var last: Dictionary = lines[-1]
	var song := {
		"id": SONG_ID,
		"title": sheet["title"],
		"boss": BOSS,
		"countdown": COUNTDOWN,
		"length": snappedf(last["time"] + cfg["line_gap"], 0.001),
		"phases": phases,
		"lines": lines,
		"loaded": loaded,
		"outcomes": {
			"revenge": {"card": "[placeholder] REVENGE: carnage card"},
			"survival": {"card": "[placeholder] SURVIVAL: quelled card"},
		},
		"game_over": {"anchor": "문태식", "line": sheet["anchor"]},
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	if f == null:
		errors.append("cannot write %s" % OUT)
		return errors
	f.store_string(JSON.stringify(song, "\t", false) + "\n")
	f.close()
	return errors


func _section_of(sheet: Dictionary, phase: int) -> String:
	for l in sheet["lyrics"]:
		if l["kind"] == "lyric" and l["phase"] == phase:
			return l["section"]
	return ""
