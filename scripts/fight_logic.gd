# The rules of one noraebang fight, with no nodes and no clock: which blank is
# next, how its options are shuffled, what an answer costs, the 점수 and the
# outcome. Fight (scripts/fight.gd) drives it from the song clock; the tests drive
# it directly. All content comes from the song file.
#   Wrong answer or timeout: -fight_wrong_halves (a whole heart). No dodges, no
#   cross-outs, no loaded blanks yet (Build 4b).
#   Revenge: no wrong answer. Survival: some wrong, hearts left. 0 hearts: lost.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name FightLogic
extends RefCounted

var song: Dictionary
var boss := ""
var seed_value := 0
## Counts retries, so each attempt shuffles the options differently.
var attempt := 0
var blanks: Array = []
var index := 0
var correct := 0
var wrong := 0
var wrong_halves := 2
## One entry per answered blank: {"n", "picked", "right", "timeout"}.
var results: Array[Dictionary] = []

var _state: Node


## `state` is the GameState node (the autoload in the game).
func _init(song_data: Dictionary, seed_number: int, state: Node, wrong_cost_halves: int = 2) -> void:
	song = song_data
	boss = str(song_data["boss"])
	seed_value = seed_number
	blanks = SongData.flat_blanks(song_data)
	wrong_halves = wrong_cost_halves
	_state = state


## Back to blank 1 with no answers. `next_attempt` reshuffles the options.
func restart(next_attempt: bool = false) -> void:
	if next_attempt:
		attempt += 1
	index = 0
	correct = 0
	wrong = 0
	results.clear()


func total() -> int:
	return blanks.size()


func has_blank() -> bool:
	return index < blanks.size()


## The blank waiting for an answer, or {}.
func current() -> Dictionary:
	return blanks[index] if has_blank() else {}


## The blank's options in this attempt's order (stable until the next retry).
func options_for(blank: Dictionary) -> Array[String]:
	var options: Array[String] = []
	for o in blank["options"]:
		options.append(str(o))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, attempt, int(blank["n"])])
	for i in range(options.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := options[i]
		options[i] = options[j]
		options[j] = tmp
	return options


## Answers the current blank. `picked` is the option text, or "" for a timeout (which
## counts as wrong). A wrong answer takes the heart here. Returns
## {"n", "right", "timeout", "picked", "answer", "attack", "counter", "lost"}.
func answer(picked: String) -> Dictionary:
	if not has_blank():
		push_error("FightLogic.answer: no blank left")
		return {}
	var blank: Dictionary = blanks[index]
	var timeout := picked == ""
	var right: bool = not timeout and picked == blank["answer"]
	index += 1
	if right:
		correct += 1
	else:
		wrong += 1
		_state.damage(wrong_halves)
	results.append({"n": blank["n"], "picked": picked, "right": right, "timeout": timeout})
	return {"n": blank["n"], "right": right, "timeout": timeout, "picked": picked, "answer": blank["answer"],
			"attack": blank["attack"], "counter": blank["counter"], "lost": lost()}


func lost() -> bool:
	return _state.hearts_halves <= 0


## True once every blank is answered and the hearts held.
func finished() -> bool:
	return not has_blank() and not lost()


## 점수 = round(100 x correct / total).
func score() -> int:
	return roundi(100.0 * correct / float(maxi(total(), 1)))


## "revenge" when nothing was lost, else "survival".
func outcome() -> String:
	return "revenge" if wrong == 0 else "survival"


## Records the win in GameState (best score, outcome, and hearts to full on
## revenge). Returns {"score", "outcome"}, or {} if the fight is not won.
func finish() -> Dictionary:
	if not finished():
		return {}
	var result := {"score": score(), "outcome": outcome()}
	_state.end_fight(boss, result["outcome"], result["score"])
	return result
