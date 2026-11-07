# The logic of the blank-timing tap tool (--mark-song), apart from the screen and the audio:
# the calibration clicks and the lag they give, onset/end from a press and a release, the
# average-or-third-pass rule, and the save (which changes only the [n] label of the blank
# measured, plus the label after it when that is its marker). The tool is SongTapTool.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongTap
extends RefCounted

const CLICK_COUNT := 8
const CLICK_GAP := 0.75
## Where the first click sounds in the click track.
const CLICK_FIRST := 1.0
const CLICK_MIX_RATE := 44100
## A tap belongs to the click nearest to it, if that is within this many seconds.
const CLICK_MATCH := CLICK_GAP / 2.0
## The lag is the median over the last LAG_TAPS matched taps, clamped to 0..LAG_MAX.
const LAG_TAPS := 6
const LAG_MAX := 0.4
## Two passes whose onsets are within this many seconds are averaged; else a third is taken.
const AGREE := 0.25
const MAX_PASSES := 3
## Playback for a pass starts this long before the blank word's current start.
const LEAD_IN := 4.0
## No press this long after the current word_start: the pass is replayed.
const NO_PRESS_TIMEOUT := 4.0
## A key held longer than this, or shorter than MIN_HOLD, is not a measurement.
const MAX_HOLD := 6.0
const MIN_HOLD := 0.05
## The preview starts this long before the new onset, and holds this long at the new pause.
const PREVIEW_LEAD := 3.0
const PREVIEW_HOLD := 0.7


## Click times in the click track, seconds.
static func click_times() -> Array[float]:
	var times: Array[float] = []
	for i in CLICK_COUNT:
		times.append(CLICK_FIRST + i * CLICK_GAP)
	return times


## The click track, made in code: CLICK_COUNT short ticks at click_times(), then silence.
static func click_stream() -> AudioStreamWAV:
	var total := int((CLICK_FIRST + CLICK_COUNT * CLICK_GAP + 0.5) * CLICK_MIX_RATE)
	var data := PackedByteArray()
	data.resize(total * 2)
	var tick_len := int(0.03 * CLICK_MIX_RATE)
	for t in click_times():
		var at := int(t * CLICK_MIX_RATE)
		for s in tick_len:
			var env := exp(-float(s) / (0.006 * CLICK_MIX_RATE))
			var v := sin(TAU * 1500.0 * float(s) / CLICK_MIX_RATE) * env * 0.8
			data.encode_s16((at + s) * 2, int(v * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = CLICK_MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav


## Seconds after which the click track is over (the tool shows the lag then).
static func click_track_end() -> float:
	return CLICK_FIRST + (CLICK_COUNT - 1) * CLICK_GAP + CLICK_GAP


## (tap - click) for the taps that belong to a click, in click order. Each tap goes to the
## nearest click within CLICK_MATCH; a click keeps its first tap. An unmatched click or tap is skipped.
static func match_taps(taps: Array, clicks: Array) -> Array[float]:
	var first := {}  # click index -> tap time
	for tap in taps:
		var best := -1
		var best_d := INF
		for i in clicks.size():
			var d := absf(float(tap) - float(clicks[i]))
			if d <= CLICK_MATCH and d < best_d:
				best = i
				best_d = d
		if best != -1 and not first.has(best):
			first[best] = float(tap)
	var offsets: Array[float] = []
	for i in clicks.size():
		if first.has(i):
			offsets.append(float(first[i]) - float(clicks[i]))
	return offsets


## The median of `values` (the mean of the middle two for an even count); 0 for none.
static func median(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	var mid := floori(sorted.size() / 2.0)
	if sorted.size() % 2 == 1:
		return float(sorted[mid])
	return (float(sorted[mid - 1]) + float(sorted[mid])) / 2.0


## The tap lag: the median of the last LAG_TAPS offsets, clamped to 0..LAG_MAX. -1 when there
## are fewer than LAG_TAPS offsets (the calibration has to be redone).
static func calibration_lag(offsets: Array) -> float:
	if offsets.size() < LAG_TAPS:
		return -1.0
	return clampf(median(offsets.slice(offsets.size() - LAG_TAPS)), 0.0, LAG_MAX)


## One pass: the press and release on the song clock, minus the lag.
static func measure(press: float, release: float, lag: float) -> Dictionary:
	return {"onset": press - lag, "end": release - lag}


## What the passes so far give: {"done": bool, "onset": float, "end": float}. One pass is
## never enough. Two passes whose onsets are within AGREE are averaged; two that are not call
## for a third (done = false), and with three (or more) the median of each is taken.
static func resolve(passes: Array) -> Dictionary:
	if passes.size() < 2:
		return {"done": false, "onset": 0.0, "end": 0.0}
	if passes.size() == 2:
		var a: Dictionary = passes[0]
		var b: Dictionary = passes[1]
		if absf(float(a["onset"]) - float(b["onset"])) <= AGREE + 1e-9:
			return {"done": true, "onset": (float(a["onset"]) + float(b["onset"])) / 2.0, "end": (float(a["end"]) + float(b["end"])) / 2.0}
		return {"done": false, "onset": 0.0, "end": 0.0}
	return {"done": true, "onset": median(passes.map(func(p): return float(p["onset"]))), "end": median(passes.map(func(p): return float(p["end"])))}


## `labels` (a copy) with blank `n`'s [n] label set to start `onset`, end `end` (to the
## millisecond). If that label is a marker for the label after it (SongLabels.is_marker), the
## label after it starts at `onset` too, so the marker rule still holds. Nothing else changes,
## and no label moves in the list. {"labels": Array, "error": String ("" when fine)}.
static func with_blank_timing(labels: Array, n: int, onset: float, end: float) -> Dictionary:
	var out: Array = []
	for l in labels:
		out.append(l.duplicate())
	var start := SongLabels.round3(onset)
	var finish := SongLabels.round3(end)
	if start < 0.0 or finish <= start:
		return {"labels": labels, "error": "blank %d: the word must end after it starts (%.3f to %.3f)" % [n, start, finish]}
	for i in out.size():
		if out[i]["kind"] != "blank" or int(out[i]["n"]) != n:
			continue
		var marker := SongLabels.is_marker(out, i)
		out[i]["start"] = start
		out[i]["end"] = finish
		if marker:
			out[i + 1]["start"] = start
			if float(out[i + 1]["end"]) <= start:
				return {"labels": labels, "error": "blank %d: its marker partner '%s' ends at %.3f, before the new onset" % [n, out[i + 1]["text"], float(out[i + 1]["end"])]}
		return {"labels": out, "error": ""}
	return {"labels": labels, "error": "no [%d] label in the labels file" % n}


## Saves blank `n`'s measured timing: reads the labels file and the song JSON, changes the [n]
## label (with_blank_timing), applies the labels to the JSON's song, and only if everything
## fits writes the labels (after a .bak copy, once per run: pass `backed_up` from the last
## call) and the song JSON. {"errors": Array[String], "backed_up": bool}. Nothing is written
## when there are errors.
static func save_blank(labels_path: String, song_path: String, n: int, onset: float, end: float, backed_up := false) -> Dictionary:
	var errors: Array[String] = []
	if not FileAccess.file_exists(labels_path) or not FileAccess.file_exists(song_path):
		errors.append("cannot read %s or %s" % [labels_path, song_path])
		return {"errors": errors, "backed_up": backed_up}
	var text := FileAccess.get_file_as_string(labels_path)
	errors.append_array(SongLabels.parse_errors(text))
	if not errors.is_empty():
		return {"errors": errors, "backed_up": backed_up}
	var changed := with_blank_timing(SongLabels.parse(text), n, onset, end)
	if changed["error"] != "":
		errors.append(changed["error"])
		return {"errors": errors, "backed_up": backed_up}
	var disk = JSON.parse_string(FileAccess.get_file_as_string(song_path))
	if typeof(disk) != TYPE_DICTIONARY:
		errors.append("cannot read the song file %s" % song_path)
		return {"errors": errors, "backed_up": backed_up}
	errors.append_array(SongLabels.apply(disk, changed["labels"]))
	if not errors.is_empty():
		return {"errors": errors, "backed_up": backed_up}
	if not backed_up:
		var bak := FileAccess.open(labels_path + ".bak", FileAccess.WRITE)
		if bak == null:
			errors.append("cannot write %s.bak" % labels_path)
			return {"errors": errors, "backed_up": backed_up}
		bak.store_string(text)
		bak.close()
		backed_up = true
	var lf := FileAccess.open(labels_path, FileAccess.WRITE)
	var sf := FileAccess.open(song_path, FileAccess.WRITE)
	if lf == null or sf == null:
		errors.append("cannot write the labels or the song file")
		return {"errors": errors, "backed_up": backed_up}
	lf.store_string(SongLabels.serialize_full(changed["labels"], SongLabels.eol_of(text)))
	lf.close()
	sf.store_string(JSON.stringify(disk, "\t", false) + "\n")
	sf.close()
	return {"errors": errors, "backed_up": backed_up}


## `text` (a labels file's text) with an (outro) label added after the last label when it has
## none. Scaffolding for the tests and the capture, which need labels that apply; the real
## labels file is never changed by it.
static func with_outro(text: String) -> String:
	var labels := SongLabels.parse(text)
	var last_end := 0.0
	for l in labels:
		if l["kind"] == "outro":
			return text
		last_end = maxf(last_end, float(l["end"]))
	var eol := SongLabels.eol_of(text)
	if not text.ends_with("\n"):
		text += eol
	return text + "%.6f\t%.6f\t(outro) 잘 먹겠습니다%s" % [last_end + 1.0, last_end + 3.0, eol]
