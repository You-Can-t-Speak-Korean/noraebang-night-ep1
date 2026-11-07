# The blank-timing tap tool (--mark-song <boss>): measures the 10 blank words on Godot's own
# playback instead of by ear in Audacity. English placeholder UI. The rules (lag, passes,
# the save) are SongTap's; this is the state machine, the clocks and the screen.
#   1. Calibrate: 8 clicks made in code play through a clock of the same kind as the song's;
#      Space on each one gives the lag. Enter accepts, R redoes.
#   2. Per blank: the song plays from 4 s before its current word_start; HOLD Space while
#      the word is sung (press = onset, release = end, both on the song clock minus the lag).
#      Two passes (a third if the onsets differ by more than 0.25 s), then a preview; Enter
#      keeps and saves (labels + song JSON), R redoes the blank, B goes back one blank.
# Esc quits. Nothing is written until a blank is kept.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name SongTapTool
extends Node

enum State { CAL_READY, CAL_PLAY, CAL_DONE, PASS, PASS_GAP, PREVIEW, DONE, FAILED }
enum Preview { PLAY, HOLD, WORD, END }

const TuningScript := preload("res://scripts/tuning.gd")
const FONT := preload("res://art/fonts/NotoSansKR/NotoSansKR-VF.ttf")
## Seconds between a finished pass and the next one.
const GAP_TIME := 1.0

var state: State = State.CAL_READY
var preview: Preview = Preview.PLAY
var song: Dictionary = {}
var song_path := ""
var labels_path := ""
## True: the owner calls step() (tests, captures); false: _process does.
var manual := false
var click_clock: SongClock
var song_clock: SongClock
## The measured tap lag in seconds; -1 until the calibration has one.
var lag := -1.0
var blank_index := 0
## The passes of the current blank: [{"onset", "end"}].
var passes: Array[Dictionary] = []
var new_onset := NAN
var new_end := NAN
var message := ""
var message_is_error := false
var backed_up := false
## Blank numbers kept (saved) in this run.
var saved: Array[int] = []

var _taps: Array[float] = []
var _tap_offsets: Array[float] = []
## One line per calibration tap: which click it belongs to and its offset in ms.
var _tap_log: Array[String] = []
var _tap_clicks := {}
## Space is down right now (the raw key, in any state; the indicator shows it).
var _space_held := false
var _space_presses := 0
var _keys_seen := 0
## The latest warnings (errors given to _say), shown in red until the next blank or redo.
var _warnings: Array[String] = []
var _cue := ""
var _held := false
var _press := 0.0
var _gap_left := 0.0
var _preview_left := 0.0
var _title: Label
var _step_label: Label
var _blank_label: Label
var _times_label: Label
var _passes_label: Label
var _lag_label: Label
var _status: Label
var _keys: Label
var _clock_label: Label
var _cue_label: Label
var _line_rich: RichTextLabel
var _warning_label: Label
var _input_label: Label
var _hold_box: ColorRect
var _hold_label: Label


## Call before add_child. `click_player` and `song_player` are the clocks for the click track
## and for the song (the audio backend for both in a real run; silent ones for the capture and
## the tests). Those with a stream are set up by the caller: the click clock plays click_stream().
func setup(song_data: Dictionary, song_file: String, click_player: SongClock, song_player: SongClock, manual_steps := false) -> void:
	song = song_data
	song_path = song_file
	labels_path = str(song_data.get("labels", ""))
	click_clock = click_player
	song_clock = song_player
	manual = manual_steps


func _ready() -> void:
	click_clock.mount(self)
	song_clock.mount(self)
	_build_ui()
	_take_focus()
	_take_focus.call_deferred()
	var problem := ""
	if labels_path == "" or not FileAccess.file_exists(labels_path):
		problem = "The song names no label file that exists (%s). Nothing to measure into." % labels_path
	else:
		var applied := SongLabels.load_and_apply(song)
		if applied != "":
			problem = "%s\nFix the labels file first (the tap tool writes nothing until it applies); for a missing outro label, add a line like:  114.00<TAB>116.00<TAB>(outro) 잘 먹겠습니다" % applied
	if problem == "" and SongData.flat_blanks(song).is_empty():
		problem = "The song has no blanks."
	if problem != "":
		state = State.FAILED
		_say(problem, true)
	_refresh()
	set_process(not manual)


func _exit_tree() -> void:
	for c in [click_clock, song_clock]:
		if c != null:
			c.stop()


func _process(delta: float) -> void:
	step(delta)


func step(delta: float) -> void:
	click_clock.tick(delta)
	song_clock.tick(delta)
	match state:
		State.CAL_PLAY:
			if click_clock.get_position() >= SongTap.click_track_end():
				_finish_calibration()
		State.PASS:
			var t := song_clock.get_position()
			var word_start := float(_blank()["word_start"])
			if not _held and t > word_start + SongTap.NO_PRESS_TIMEOUT:
				_replay_pass("No press in time; replaying the pass." + ("" if _space_presses > 0 else " No Space press has reached the tool yet: click the window and check it has focus."))
			elif _held and t - _press > SongTap.MAX_HOLD:
				_replay_pass("Space was held too long; replaying the pass.")
		State.PASS_GAP:
			_gap_left -= delta
			if _gap_left <= 0.0:
				_after_gap()
		State.PREVIEW:
			_step_preview(delta)
	_clock_label.text = "clock: song %.2f s" % song_clock.get_position()
	_update_cue()
	_update_input_label()


## Steps in `dt` slices until `clock` reads `seconds` or more (the tests and the capture, on silent clocks).
func advance_until(clock: SongClock, seconds: float, dt := 0.005) -> void:
	var guard := 0
	while clock.get_position() < seconds and guard < 200000:
		step(dt)
		guard += 1


## Keys are read here, before any Control sees them: a focused Control would otherwise take
## Space as ui_accept. The physical key is used (so a Korean IME or another layout does not
## matter), falling back to the keycode.
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var viewport := get_viewport()
	if viewport.gui_get_focus_owner() != null:
		viewport.gui_release_focus()
	var code: int = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	handle_key(code, event.pressed, event.echo)
	viewport.set_input_as_handled()


## Releases any GUI focus and asks the OS for the window's focus (a window that was started
## from a terminal often does not have it, and then no key reaches the game).
func _take_focus() -> void:
	if not is_inside_tree():
		return
	get_viewport().gui_release_focus()
	if not manual and DisplayServer.get_name() != "headless":
		get_window().grab_focus()
		DisplayServer.window_move_to_foreground()


## A key going down or up (what _input forwards; the tests call it too).
func handle_key(keycode: int, pressed: bool, echo := false) -> void:
	if echo:
		return
	_keys_seen += 1
	if keycode == KEY_SPACE:
		_space_held = pressed
		if pressed:
			_space_presses += 1
		_update_hold_indicator()
	if keycode == KEY_ESCAPE and pressed:
		if is_inside_tree():
			get_tree().quit()
		return
	if state == State.FAILED:
		return
	if keycode == KEY_SPACE:
		if pressed:
			_space_down()
		else:
			_space_up()
		return
	if not pressed:
		return
	match keycode:
		KEY_ENTER, KEY_KP_ENTER:
			_enter()
		KEY_R:
			_redo()
		KEY_B:
			_back()
		KEY_P:
			if state == State.PREVIEW and preview == Preview.END:
				_begin_preview()
	_refresh()


# ── Calibration ────────────────────────────────────────────────────────

## Adds the tap at `tap` (click-clock seconds) to the on-screen list: the click it belongs to
## (the same rule as SongTap.match_taps) and its offset in ms, or why it counts for none.
func _log_tap(tap: float) -> void:
	var clicks := SongTap.click_times()
	var best := 0
	for i in clicks.size():
		if absf(tap - clicks[i]) < absf(tap - clicks[best]):
			best = i
	var d := tap - clicks[best]
	var text := "tap %d:  " % _taps.size()
	if absf(d) > SongTap.CLICK_MATCH:
		text += "no click near it (%+d ms from click %d)  - not counted" % [roundi(d * 1000.0), best + 1]
	elif _tap_clicks.has(best):
		text += "click %d again, %+d ms  - not counted (the first tap on a click counts)" % [best + 1, roundi(d * 1000.0)]
	else:
		_tap_clicks[best] = true
		text += "click %d:  %+d ms" % [best + 1, roundi(d * 1000.0)]
	_tap_log.append(text)


func _finish_calibration() -> void:
	click_clock.stop()
	_tap_offsets = SongTap.match_taps(_taps, SongTap.click_times())
	lag = SongTap.calibration_lag(_tap_offsets)
	state = State.CAL_DONE
	var missed := PackedStringArray()
	for i in SongTap.CLICK_COUNT:
		if not _tap_clicks.has(i):
			missed.append(str(i + 1))
	if not missed.is_empty():
		_tap_log.append("clicks with no tap: %s" % ", ".join(missed))
	if _taps.is_empty():
		_say("No Space press reached the tool at all (%d key events so far). Click the window and check it has focus, then R and Enter to try again." % _keys_seen, true)
	elif lag < 0.0:
		_say("Only %d of %d taps matched a click; at least %d are needed. R redoes it." % [_tap_offsets.size(), SongTap.CLICK_COUNT, SongTap.LAG_TAPS], true)
	else:
		_say("Measured lag %.3f s from the last %d taps. Enter accepts, R redoes." % [lag, SongTap.LAG_TAPS], false)
	_refresh()


# ── Blanks ─────────────────────────────────────────────────────────────

func blank_count() -> int:
	return SongData.flat_blanks(song).size()


func _blank() -> Dictionary:
	return SongData.flat_blanks(song)[blank_index]


func _begin_blank(index: int) -> void:
	_warnings.clear()
	blank_index = index
	passes.clear()
	new_onset = NAN
	new_end = NAN
	_start_pass()


func _start_pass() -> void:
	state = State.PASS
	_held = false
	_play_from(song_clock, maxf(float(_blank()["word_start"]) - SongTap.LEAD_IN, 0.0))
	_say("Pass %d: HOLD Space while the word is sung." % (passes.size() + 1), false)


func _replay_pass(why: String) -> void:
	_start_pass()
	_say(why, true)
	_refresh()


func _space_down() -> void:
	match state:
		State.CAL_PLAY:
			_taps.append(click_clock.get_position())
			_log_tap(_taps[-1])
		State.PASS:
			if not _held:
				_held = true
				_press = song_clock.get_position()
	_refresh()


func _space_up() -> void:
	if state != State.PASS or not _held:
		return
	_held = false
	var release := song_clock.get_position()
	if release - _press < SongTap.MIN_HOLD:
		_replay_pass("Space was released at once; replaying the pass.")
		return
	passes.append(SongTap.measure(_press, release, lag))
	song_clock.pause()
	state = State.PASS_GAP
	_gap_left = GAP_TIME
	var p: Dictionary = passes[-1]
	_say("Pass %d: start %.3f, end %.3f." % [passes.size(), p["onset"], p["end"]], false)
	_refresh()


func _after_gap() -> void:
	var result := SongTap.resolve(passes)
	if result["done"]:
		new_onset = SongLabels.round3(result["onset"])
		new_end = SongLabels.round3(result["end"])
		if new_onset < 0.0 or new_end <= new_onset:
			_begin_blank(blank_index)
			_say("The passes gave an impossible word (%.3f to %.3f); starting this blank again." % [new_onset, new_end], true)
		else:
			_begin_preview()
	else:
		_start_pass()
		if passes.size() >= 2:
			_say("The two onsets differ by more than %.2f s: a third pass." % SongTap.AGREE, false)
	_refresh()


# ── Preview ────────────────────────────────────────────────────────────

func _pause_at() -> float:
	return new_onset - float(TuningScript.fight_config()["pause_lead"])


func _begin_preview() -> void:
	state = State.PREVIEW
	preview = Preview.PLAY
	_play_from(song_clock, maxf(new_onset - SongTap.PREVIEW_LEAD, 0.0))
	_say("Preview: it stops at the new pause, then plays the word.", false)


func _step_preview(delta: float) -> void:
	match preview:
		Preview.PLAY:
			if song_clock.get_position() >= _pause_at():
				song_clock.pause()
				_preview_left = SongTap.PREVIEW_HOLD
				preview = Preview.HOLD
		Preview.HOLD:
			_preview_left -= delta
			if _preview_left <= 0.0:
				song_clock.resume()
				preview = Preview.WORD
		Preview.WORD:
			if song_clock.get_position() >= new_end:
				song_clock.pause()
				preview = Preview.END
				_say("Enter keeps this timing and saves it. R redoes the blank, B goes back one blank, P hears it again.", false)
				_refresh()


# ── Keys ───────────────────────────────────────────────────────────────

func _enter() -> void:
	match state:
		State.CAL_READY:
			_taps.clear()
			_tap_log.clear()
			_tap_clicks.clear()
			_warnings.clear()
			click_clock.play()
			state = State.CAL_PLAY
			_say("Tap Space on every click.", false)
		State.CAL_DONE:
			if lag >= 0.0:
				_begin_blank(0)
		State.PREVIEW:
			if preview == Preview.END:
				_keep()


func _redo() -> void:
	match state:
		State.CAL_READY, State.CAL_PLAY, State.CAL_DONE:
			click_clock.stop()
			_warnings.clear()
			lag = -1.0
			state = State.CAL_READY
			_say("Press Enter to play the clicks again.", false)
		State.PASS, State.PASS_GAP, State.PREVIEW:
			song_clock.pause()
			_begin_blank(blank_index)
			_say("Blank %d again from the first pass." % _blank()["n"], false)


func _back() -> void:
	if state != State.PASS and state != State.PASS_GAP and state != State.PREVIEW and state != State.DONE:
		return
	song_clock.pause()
	if blank_index == 0 and state != State.DONE:
		state = State.CAL_DONE if lag >= 0.0 else State.CAL_READY
		_say("Back at the calibration. Enter accepts the lag, R redoes it.", false)
		return
	_begin_blank(blank_count() - 1 if state == State.DONE else blank_index - 1)


func _keep() -> void:
	var n := int(_blank()["n"])
	var result := SongTap.save_blank(labels_path, song_path, n, new_onset, new_end, backed_up)
	backed_up = result["backed_up"]
	if not result["errors"].is_empty():
		_say("NOT SAVED: %s" % "; ".join(result["errors"]), true)
		return
	if not saved.has(n):
		saved.append(n)
	var applied := SongLabels.load_and_apply(song)
	if blank_index + 1 >= blank_count():
		state = State.DONE
		song_clock.pause()
		_say("Blank %d saved. All blanks measured." % n if applied == "" else applied, applied != "")
	else:
		_begin_blank(blank_index + 1)
		_say("Blank %d saved (labels + song JSON; backup: .bak). Blank %d next." % [n, _blank()["n"]], false)


## Plays `clock` from `seconds` (a clock starts from 0, so it is started, held and moved).
func _play_from(clock: SongClock, seconds: float) -> void:
	clock.play()
	clock.pause()
	clock.seek(seconds)
	clock.resume()


# ── The screen ─────────────────────────────────────────────────────────

func _say(text: String, is_error: bool) -> void:
	message = text
	message_is_error = is_error
	if is_error:
		push_warning("SongTapTool: " + text)
		_warnings.append(text)
		while _warnings.size() > 3:
			_warnings.remove_at(0)
	if _warning_label != null:
		_warning_label.text = "\n".join(_warnings.map(func(w): return "WARNING: " + w))
	if _status != null:
		_status.text = text
		_status.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4) if is_error else Color(0.85, 0.95, 0.8))


func _refresh() -> void:
	if _title == null:
		return
	var total := blank_count()
	var step_text := ""
	var keys := ""
	match state:
		State.CAL_READY:
			step_text = "STEP 1 of 2: calibrate the tap lag"
			keys = "Enter: play the %d clicks, then tap Space on each   Esc: quit" % SongTap.CLICK_COUNT
		State.CAL_PLAY:
			step_text = "STEP 1 of 2: calibrate - tap Space on every click (%d taps so far)" % _taps.size()
			keys = "Space: tap   R: redo   Esc: quit"
		State.CAL_DONE:
			step_text = "STEP 1 of 2: calibration finished"
			keys = "Enter: accept the lag   R: redo   Esc: quit"
		State.PASS, State.PASS_GAP:
			step_text = "STEP 2 of 2: blank %d of %d, pass %d%s" % [blank_index + 1, total, mini(passes.size() + (1 if state == State.PASS else 0), SongTap.MAX_PASSES), "  [HOLDING]" if _held else ""]
			keys = "HOLD Space while the blank word is sung (press = start, release = end)   R: redo this blank   B: back one blank   Esc: quit"
		State.PREVIEW:
			step_text = "STEP 2 of 2: blank %d of %d, preview%s" % [blank_index + 1, total, "" if preview == Preview.END else " (listening)"]
			keys = "Enter: keep and save (when the preview is over)   R: redo this blank   B: back one blank   P: hear it again   Esc: quit"
		State.DONE:
			step_text = "DONE: all %d blanks measured" % total
			keys = "B: back to blank %d   Esc: quit" % total
		State.FAILED:
			step_text = "CANNOT START"
			keys = "Esc: quit"
	_step_label.text = step_text
	_keys.text = keys
	_lag_label.text = "tap lag: %s" % ("not measured yet" if lag < 0.0 else "%.3f s" % lag)
	if _warning_label != null:
		_warning_label.text = "\n".join(_warnings.map(func(w): return "WARNING: " + w))
	_line_rich.text = ""
	if state == State.CAL_READY or state == State.CAL_PLAY or state == State.CAL_DONE or state == State.FAILED or total == 0:
		_blank_label.text = ""
		_times_label.text = ""
		_passes_label.text = "\n".join(_tap_log)
		return
	if state == State.DONE:
		var lines := PackedStringArray()
		for b in SongData.flat_blanks(song):
			lines.append("blank %2d  %s   start %.3f   end %.3f%s" % [b["n"], b["answer"], b["word_start"], b["word_end"], "   (saved)" if saved.has(int(b["n"])) else ""])
		_blank_label.text = ""
		_times_label.text = "\n".join(lines)
		_passes_label.text = ""
		return
	var b := _blank()
	_blank_label.text = "Blank %d of %d: sing \"%s\"" % [b["n"], total, b["answer"]]
	_line_rich.text = _line_markup(b)
	var old_line := "old:  start %.3f   end %.3f%s   (pause %.3f)" % [b["word_start"], b["word_end"], "" if b.get("word_end_marked", false) else " (end not marked)", b["pause_at"]]
	var new_line := "new:  not measured yet"
	if not is_nan(new_onset):
		new_line = "new:  start %.3f   end %.3f   (pause %.3f)" % [new_onset, new_end, _pause_at()]
	_times_label.text = old_line + "\n" + new_line
	var pass_lines := PackedStringArray()
	for i in passes.size():
		pass_lines.append("pass %d:  start %.3f   end %.3f" % [i + 1, passes[i]["onset"], passes[i]["end"]])
	_passes_label.text = "\n".join(pass_lines)


## The blank's lyric line as BBCode, the blank word (its answer) highlighted where the blank is.
func _line_markup(b: Dictionary) -> String:
	var parts := str(b["line"]).split(SongData.BLANK_MARK)
	var out := ""
	for i in parts.size():
		out += parts[i].replace("[", "[lb]")
		if i < parts.size() - 1:
			out += "[color=#ffd84a][u]%s[/u][/color]" % str(b["answer"]).replace("[", "[lb]")
	return out


## The 3-2-1 before the blank word (by the word's current word_start), then the cue to hold.
func _cue_for(remaining: float) -> String:
	if remaining > 3.0:
		return ""
	if remaining > 0.0:
		return str(ceili(remaining))
	if remaining > -1.5 and not _held:
		return "NOW: hold Space"
	return ""


func _update_cue() -> void:
	if _cue_label == null:
		return
	var text := ""
	if state == State.PASS:
		text = _cue_for(float(_blank()["word_start"]) - song_clock.get_position())
	if text != _cue:
		_cue = text
		_cue_label.text = text


func _update_hold_indicator() -> void:
	if _hold_box == null:
		return
	_hold_box.color = Color(0.2, 0.75, 0.3) if _space_held else Color(0.18, 0.18, 0.22)
	_hold_label.text = "SPACE: HELD" if _space_held else "SPACE: up"


func _update_input_label() -> void:
	if _input_label == null:
		return
	var focused := get_window().has_focus() if is_inside_tree() else false
	_input_label.text = "input: window %s   key events %d   Space presses %d" % ["focused" if focused else "NOT FOCUSED (click it)", _keys_seen, _space_presses]
	_input_label.add_theme_color_override("font_color", Color(0.55, 0.58, 0.65) if focused else Color(1.0, 0.45, 0.4))


func _label(size: int, color := Color(0.92, 0.92, 0.95)) -> Label:
	var l := Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.focus_mode = Control.FOCUS_NONE
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(1700, 0)
	return l


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 40
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.focus_mode = Control.FOCUS_NONE
	layer.add_child(bg)
	var box := VBoxContainer.new()
	box.position = Vector2(110, 70)
	box.add_theme_constant_override("separation", 22)
	layer.add_child(box)
	_title = _label(34, Color(1.0, 0.9, 0.5))
	_title.text = "TAP TOOL: %s (placeholder UI)" % song.get("title", "")
	_step_label = _label(40)
	_blank_label = _label(38, Color(0.7, 0.9, 1.0))
	_times_label = _label(34)
	_passes_label = _label(30, Color(0.75, 0.8, 0.9))
	_lag_label = _label(30, Color(0.8, 0.8, 0.6))
	_status = _label(32)
	_keys = _label(28, Color(0.7, 0.75, 0.8))
	_clock_label = _label(24, Color(0.55, 0.58, 0.65))
	_cue_label = _label(110, Color(1.0, 0.85, 0.3))
	_warning_label = _label(28, Color(1.0, 0.45, 0.4))
	_input_label = _label(24, Color(0.55, 0.58, 0.65))
	_line_rich = RichTextLabel.new()
	_line_rich.bbcode_enabled = true
	_line_rich.fit_content = true
	_line_rich.scroll_active = false
	_line_rich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_line_rich.focus_mode = Control.FOCUS_NONE
	_line_rich.custom_minimum_size = Vector2(1700, 0)
	_line_rich.add_theme_font_override("normal_font", FONT)
	_line_rich.add_theme_font_size_override("normal_font_size", 52)
	_line_rich.add_theme_color_override("default_color", Color(0.92, 0.92, 0.95))
	for l in [_title, _step_label, _blank_label, _line_rich, _cue_label, _times_label, _passes_label, _lag_label, _status, _warning_label, _keys, _clock_label, _input_label]:
		box.add_child(l)
	_hold_box = ColorRect.new()
	_hold_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_hold_box.offset_left = -420.0
	_hold_box.offset_right = -20.0
	_hold_box.offset_top = 20.0
	_hold_box.offset_bottom = 100.0
	_hold_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_hold_box)
	_hold_label = _label(40)
	_hold_label.custom_minimum_size = Vector2.ZERO
	_hold_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hold_box.add_child(_hold_label)
	_update_hold_indicator()
