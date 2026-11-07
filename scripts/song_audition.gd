# The label audition (--check-song): holds the song's Audacity labels in memory, nudges a
# blank word's start or end, re-applies the timing to the running song, and saves. Saving
# copies the labels file to <file>.bak (once per run), rewrites it with the same labels in
# the same order (only the [n] labels change), then applies the labels to the song JSON on
# disk. It writes nothing else.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongAudition
extends RefCounted

const STEP := 0.01
const BIG_STEP := 0.05

var song: Dictionary
var labels: Array[Dictionary] = []
var labels_path := ""
var song_path := ""
var unsaved := false
var backed_up := false
var last_message := ""


func _init(song_data: Dictionary, labels_file: String, song_file: String) -> void:
	song = song_data
	labels_path = labels_file
	song_path = song_file
	labels = SongLabels.load_file(labels_file)


func has_labels() -> bool:
	return not labels.is_empty()


## {"word_start", "word_end", "marked", "pause_at"} of blank `n` from the song now.
func info(n: int) -> Dictionary:
	for b in SongData.flat_blanks(song):
		if int(b["n"]) == n:
			return {"word_start": float(b.get("word_start", b["time"])), "word_end": float(b.get("word_end", b["time"])),
					"marked": bool(b.get("word_end_marked", false)), "pause_at": float(b.get("pause_at", b["time"]))}
	return {}


## Moves blank `n`'s word_start (`which` "start") or word_end ("end") by `delta` seconds
## (to 0.01) and re-applies the timing. An unmarked end moves with the start; nudging the end
## marks it. Returns the song's problems after the change (empty when fine).
func nudge(n: int, which: String, delta: float) -> Array[String]:
	for l in labels:
		if l["kind"] != "blank" or int(l["n"]) != n:
			continue
		var cur := info(n)
		if which == "start":
			var marked: bool = float(l["end"]) > float(l["start"]) + SongLabels.EPS
			var s := SongLabels.round3(float(l["start"]) + delta)
			if marked:
				s = minf(s, float(l["end"]) - STEP)
			else:
				l["end"] = s
			l["start"] = maxf(s, 0.0)
		else:
			var e := SongLabels.round3(float(cur["word_end"]) + delta)
			l["end"] = maxf(e, float(l["start"]) + STEP)
		unsaved = true
		return SongLabels.apply(song, labels)
	return ["no [%d] label" % n]


## Saves as described in the header. Returns the problems (empty = saved).
func save() -> Array[String]:
	var errors: Array[String] = []
	var disk = JSON.parse_string(FileAccess.get_file_as_string(song_path)) if FileAccess.file_exists(song_path) else null
	if typeof(disk) != TYPE_DICTIONARY:
		errors.append("cannot read the song file %s" % song_path)
		return errors
	errors.append_array(SongLabels.apply(disk, labels))
	if not errors.is_empty():
		return errors
	var original := FileAccess.get_file_as_string(labels_path)
	if not backed_up:
		var bak := FileAccess.open(labels_path + ".bak", FileAccess.WRITE)
		if bak == null:
			errors.append("cannot write %s.bak" % labels_path)
			return errors
		bak.store_string(original)
		bak.close()
		backed_up = true
	var lf := FileAccess.open(labels_path, FileAccess.WRITE)
	var sf := FileAccess.open(song_path, FileAccess.WRITE)
	if lf == null or sf == null:
		errors.append("cannot write the labels or the song file")
		return errors
	# Full precision and the file's own line ending, so no other label's time moves.
	lf.store_string(SongLabels.serialize_full(labels, SongLabels.eol_of(original)))
	lf.close()
	sf.store_string(JSON.stringify(disk, "\t", false) + "\n")
	sf.close()
	unsaved = false
	return errors
