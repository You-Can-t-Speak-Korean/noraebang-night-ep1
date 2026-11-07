# Song timing from an Audacity label file (File > Export > Export Labels: start<TAB>end<TAB>text,
# seconds). parse() reads it, serialize() writes it back, apply() matches the labels to a song
# dict's lyric lines and writes the timing into it. Used by tools/build_song.gd and the
# audition mode; knows nothing about any one song.
#   "(intro) ..." / "(outro) ...": the spoken intro/outro in the audio. Timing only, matched
#                by tag and never by text. "(skip) ...": ignored.
#   "[n] word":  sung blank word n. start = onset, end = end of the word; start == end means
#                the end is not marked yet.
#   anything else: a sung lyric fragment.
# A line is matched by its Hangul syllables only: the song's line with the blank filled by its
# answer must be spelled by consecutive labels. A [n] label followed by a label that starts at
# (about) the same time and begins with the [n] word is a marker: it adds no text to the match.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongLabels
extends RefCounted

const TuningScript := preload("res://scripts/tuning.gd")
## How close the next label's start must be to a [n] label's start for the marker rule. The
## label file has them at the same time; the slack keeps the rule true after a nudge.
const MARKER_WINDOW := 0.5
const EPS := 0.0005


## [{"start": float, "end": float, "text": String (as in the file), "kind": "intro"|"outro"|"skip"|"blank"|"lyric",
## "n": int (blank number, 0 if none), "body": String (text without its tag)}], in file order.
## A run of tabs separates columns like a single tab. Blank lines are skipped, and so are lines
## that are not "start end text" (parse_errors() names those).
static func parse(text: String) -> Array[Dictionary]:
	var labels: Array[Dictionary] = []
	var tag_re := RegEx.create_from_string("^\\((intro|outro|skip)\\)\\s*(.*)$")
	var blank_re := RegEx.create_from_string("^\\[(\\d+)\\]\\s*(.*)$")
	for raw in text.split("\n"):
		var line := raw.strip_edges(false, true)
		if line.strip_edges() == "":
			continue
		var cols := _columns(line)
		if cols.is_empty():
			continue
		var label := {"start": cols[0].to_float(), "end": cols[1].to_float(), "text": cols[2], "kind": "lyric", "n": 0, "body": cols[2]}
		var m := tag_re.search(cols[2])
		if m != null:
			label["kind"] = m.get_string(1)
			label["body"] = m.get_string(2)
		else:
			m = blank_re.search(cols[2])
			if m != null:
				label["kind"] = "blank"
				label["n"] = int(m.get_string(1))
				label["body"] = m.get_string(2)
		labels.append(label)
	return labels


## [start, end, text] of a label line (a run of tabs is one separator), or [] if it is not one.
static func _columns(line: String) -> PackedStringArray:
	var m := RegEx.create_from_string("^([^\t]+)\t+([^\t]+)\t+(.*)$").search(line)
	if m == null or not m.get_string(1).is_valid_float() or not m.get_string(2).is_valid_float():
		return PackedStringArray()
	return PackedStringArray([m.get_string(1), m.get_string(2), m.get_string(3)])


## One message per non-blank line of `text` that parse() cannot read as a label, naming its
## line number (1-based) and the line: [] when every line is a label.
static func parse_errors(text: String) -> Array[String]:
	var errors: Array[String] = []
	var n := 0
	for raw in text.split("\n"):
		n += 1
		var line := raw.strip_edges(false, true)
		if line.strip_edges() != "" and _columns(line).is_empty():
			errors.append("line %d is not a label (start<TAB>end<TAB>text): '%s'" % [n, line])
	return errors


## The file text: one "start<TAB>end<TAB>text" line per label, times to 2 decimals.
static func serialize(labels: Array) -> String:
	var out := ""
	for l in labels:
		out += "%.2f\t%.2f\t%s\n" % [float(l["start"]), float(l["end"]), l["text"]]
	return out


## Like serialize(), but 6 decimals (Audacity's own precision, so no other label's time moves
## when one is changed) and the file's own line ending (see eol_of).
static func serialize_full(labels: Array, eol := "\n") -> String:
	var out := ""
	for l in labels:
		out += "%.6f\t%.6f\t%s%s" % [float(l["start"]), float(l["end"]), l["text"], eol]
	return out


## The line ending `text` uses: "\r\n" when its first line break has one, else "\n".
static func eol_of(text: String) -> String:
	var at := text.find("\n")
	return "\r\n" if at > 0 and text[at - 1] == "\r" else "\n"


static func load_file(path: String) -> Array[Dictionary]:
	if not FileAccess.file_exists(path):
		return []
	return parse(FileAccess.get_file_as_string(path))


## Applies the label file the song names (its "labels" field) to `song` in memory. "" when
## there is nothing to report: no labels named, the file missing, or applied. Otherwise the
## problems (also logged); the song then keeps the times baked into its JSON.
static func load_and_apply(song: Dictionary) -> String:
	var path := str(song.get("labels", ""))
	if path == "" or not FileAccess.file_exists(path):
		return ""
	var text := FileAccess.get_file_as_string(path)
	var errors := parse_errors(text)
	if errors.is_empty():
		errors = apply(song, parse(text))
	if errors.is_empty():
		return ""
	var message := "labels %s do not apply (the song keeps its baked times): %s" % [path.get_file(), "; ".join(errors)]
	push_error("SongLabels: " + message)
	return message


## Only the Hangul syllables of `s` (what the matching compares).
static func hangul(s: String) -> String:
	var out := ""
	for i in s.length():
		var c := s.unicode_at(i)
		if c >= 0xAC00 and c <= 0xD7A3:
			out += s[i]
	return out


## True when label `i` is a [n] label whose next label restates the word (see the header).
static func is_marker(labels: Array, i: int) -> bool:
	var l: Dictionary = labels[i]
	if l["kind"] != "blank" or i + 1 >= labels.size():
		return false
	var next: Dictionary = labels[i + 1]
	var word := hangul(str(l["body"]))
	return next["kind"] == "lyric" and absf(float(next["start"]) - float(l["start"])) <= MARKER_WINDOW \
			and word != "" and hangul(str(next["body"])).begins_with(word)


## Matches `labels` to the song's lines and writes the timing into `song`:
##   lines[i].time / .end   first label start / last label end (intro and outro by tag)
##   blank.word_start, .word_end, .word_end_marked, .pause_at, and .time = pause_at
##   song.length = the last label end
## `cfg` overrides tuning.json's pause_lead and word_default_len (tests). Returns the problems
## found; the song is only changed when there are none.
static func apply(song: Dictionary, labels: Array, cfg: Dictionary = {}) -> Array[String]:
	var errors: Array[String] = []
	var tuning: Dictionary = TuningScript.fight_config()
	var lead: float = float(cfg.get("pause_lead", tuning["pause_lead"]))
	var default_len: float = float(cfg.get("word_default_len", tuning["word_default_len"]))
	var answers := {}
	for b in SongData.flat_blanks(song):
		answers[int(b["n"])] = str(b["answer"])
	var lines: Array = song["lines"]
	var line_times: Array = []  # [start, end] per line
	var blank_label := {}  # n -> label index
	var at := 0
	var last_time := -1.0
	for li in lines.size():
		var line: Dictionary = lines[li]
		var kind := str(line.get("kind", "lyric"))
		var name := "line %d '%s'" % [li + 1, line.get("text", "")]
		while at < labels.size() and labels[at]["kind"] == "skip":
			at += 1
		var first := at
		var finish := at
		if kind == "intro" or kind == "outro":
			var last := first - 1
			while at < labels.size() and (labels[at]["kind"] == kind or labels[at]["kind"] == "skip"):
				if labels[at]["kind"] == kind:
					last = at
				at += 1
			if last < first:
				errors.append("%s: expected a (%s) label at label %d%s" % [name, kind, first + 1, _describe(labels, first)])
				return errors
			finish = last
		else:
			var n := int(line.get("blank", 0))
			var target := hangul(str(line["text"]).replace(SongData.BLANK_MARK, str(answers.get(n, ""))))
			var got := ""
			var found_blank := false
			while got.length() < target.length():
				if at >= labels.size():
					errors.append("%s: ran out of labels after '%s' (need '%s')" % [name, got, target])
					return errors
				var l: Dictionary = labels[at]
				if l["kind"] == "skip":
					at += 1
					continue
				if l["kind"] == "intro" or l["kind"] == "outro":
					errors.append("%s: hit a (%s) label at label %d%s while matching" % [name, l["kind"], at + 1, _describe(labels, at)])
					return errors
				if l["kind"] == "blank":
					if int(l["n"]) != n:
						errors.append("%s: label %d%s is blank [%d], not this line's blank" % [name, at + 1, _describe(labels, at), int(l["n"])])
						return errors
					found_blank = true
					blank_label[n] = at
				if not is_marker(labels, at):
					got += hangul(str(l["body"]))
					if not target.begins_with(got):
						errors.append("%s: label %d%s does not fit; the line so far is '%s' of '%s'" % [name, at + 1, _describe(labels, at), got, target])
						return errors
				finish = at
				at += 1
			if n != 0 and not found_blank:
				errors.append("%s: no [%d] label among its labels" % [name, n])
				return errors
		var start := 1e9
		var end := -1e9
		for k in range(first, finish + 1):
			if labels[k]["kind"] == "skip":
				continue
			start = minf(start, float(labels[k]["start"]))
			end = maxf(end, float(labels[k]["end"]))
		if start < last_time:
			errors.append("%s: starts at %.2f, before the previous line's start %.2f" % [name, start, last_time])
			return errors
		last_time = start
		line_times.append([start, end])
	while at < labels.size():
		if labels[at]["kind"] != "skip":
			errors.append("label %d%s is left over after the last line" % [at + 1, _describe(labels, at)])
			return errors
		at += 1

	# Blank timing.
	var timing := {}
	var prev_end := -1.0
	for b in SongData.flat_blanks(song):
		var n := int(b["n"])
		if not blank_label.has(n):
			errors.append("blank %d has no [%d] label" % [n, n])
			return errors
		var l: Dictionary = labels[blank_label[n]]
		var word_start := float(l["start"])
		var marked: bool = float(l["end"]) > word_start + EPS
		var word_end := float(l["end"])
		if not marked:
			word_end = word_start + default_len
			for other in labels:
				if float(other["start"]) > word_start + EPS:
					word_end = minf(word_end, float(other["start"]))
		var pause_at := word_start - lead
		if pause_at < prev_end:
			errors.append("blank %d: pause at %.2f is before the previous blank's word ends (%.2f)" % [n, pause_at, prev_end])
			return errors
		prev_end = word_end
		timing[n] = {"word_start": _r3(word_start), "word_end": _r3(word_end),
				"word_end_marked": marked, "pause_at": _r3(pause_at)}

	for li in lines.size():
		lines[li]["time"] = _r3(line_times[li][0])
		lines[li]["end"] = _r3(line_times[li][1])
	for phase in song["phases"]:
		for b in phase["blanks"]:
			var t: Dictionary = timing[int(b["n"])]
			for key in t:
				b[key] = t[key]
			b["time"] = t["pause_at"]
	var length := 0.0
	for l in labels:
		length = maxf(length, float(l["end"]))
	song["length"] = _r3(length)
	return errors


static func _describe(labels: Array, i: int) -> String:
	if i < 0 or i >= labels.size():
		return " (end of file)"
	return " (%.2f '%s')" % [float(labels[i]["start"]), labels[i]["text"]]


## `x` rounded to 3 decimals in a way that survives a JSON round trip (snappedf does not:
## 41.3 comes back as 41.30000000000001 and no longer equals what was parsed).
static func _r3(x: float) -> float:
	return ("%.3f" % x).to_float()


## `x` to the millisecond (what the tap tool writes).
static func round3(x: float) -> float:
	return _r3(x)


## `x` to 2 decimals, as the label file stores it (what the audition's nudges use).
static func round2(x: float) -> float:
	return ("%.2f" % x).to_float()
