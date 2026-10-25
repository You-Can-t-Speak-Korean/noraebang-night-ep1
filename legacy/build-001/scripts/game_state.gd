# Noraebang Night — global game state (autoload "GameState").
# Implements Systems Spec v0.1 §2 and §6.7.
#
# Writer's rule (spec §2.5): every dialogue choice calls at most ONE of
#   GameState.add_nunchi(1)  or  GameState.lose_secret("card_id")
# Dialogue files call these through Dialogue Manager mutations ($> ...).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

signal nunchi_changed(value: int, delta: int)
signal secret_lost(card_id: String, known_by: String)
signal hearts_changed(value: int)

const MAX_HEARTS := 3
const MAX_NUNCHI := 5  # spec §2.2 🟡

var hearts: int = MAX_HEARTS
var nunchi: int = 0
var secrets_held: Array[String] = []
var secrets_known_by: Dictionary = {}   # card_id -> Array of boss ids
var scores: Dictionary = {}             # boss_id -> best 점수
var progress: String = ""
var codex: Array[String] = []

## Card definitions for the current Act: card_id -> {icon, name, guards}.
var card_defs: Dictionary = {}
## Card ids in display order.
var card_order: Array[String] = []

## Who is "in the room" right now. A lost card becomes known by this boss.
var current_boss: String = ""

var _nunchi_at_fight_start: int = 0


func _ready() -> void:
	load_act_cards("res://data/secrets/act1_cards.json")


# ── Setup ──────────────────────────────────────────────────────────────

func load_act_cards(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY or not data.has("cards"):
		push_error("GameState: could not load cards from %s" % path)
		return
	card_defs.clear()
	card_order.clear()
	for card in data["cards"]:
		card_defs[card["id"]] = card
		card_order.append(card["id"])
	reset_act()


## Fresh start for an Act: full hand, no 눈치.
func reset_act() -> void:
	hearts = MAX_HEARTS
	nunchi = 0
	secrets_held = card_order.duplicate()
	secrets_known_by.clear()
	scores.clear()
	progress = ""
	current_boss = ""


# ── 👀 눈치 ────────────────────────────────────────────────────────────

func add_nunchi(amount: int = 1) -> void:
	var before := nunchi
	nunchi = clampi(nunchi + amount, 0, MAX_NUNCHI)
	nunchi_changed.emit(nunchi, nunchi - before)


## Spend one token (cross-out or dodge in a fight). Returns false if none left.
func spend_nunchi() -> bool:
	if nunchi <= 0:
		return false
	nunchi -= 1
	nunchi_changed.emit(nunchi, -1)
	return true


# ── 🔒 비밀 ────────────────────────────────────────────────────────────

## Lose a secret card. It becomes known by `by` (defaults to current_boss).
## Losing a card she no longer holds does nothing.
func lose_secret(card_id: String, by: String = "") -> void:
	if not card_defs.has(card_id):
		push_error("GameState: unknown secret card '%s'" % card_id)
		return
	if not secrets_held.has(card_id):
		return
	secrets_held.erase(card_id)
	var who := by if by != "" else current_boss
	if who == "":
		who = "everyone"
	if not secrets_known_by.has(card_id):
		secrets_known_by[card_id] = []
	secrets_known_by[card_id].append(who)
	secret_lost.emit(card_id, who)


func has_secret(card_id: String) -> bool:
	return secrets_held.has(card_id)


## Cards a given boss knows (used later for "loaded" blanks).
func cards_known_by(boss_id: String) -> Array[String]:
	var result: Array[String] = []
	for card_id in secrets_known_by:
		var knowers: Array = secrets_known_by[card_id]
		if knowers.has(boss_id) or knowers.has("everyone"):
			result.append(card_id)
	return result


func set_boss(boss_id: String) -> void:
	current_boss = boss_id


# ── ❤️ 체력 (fights only) ──────────────────────────────────────────────

func start_fight(boss_id: String) -> void:
	current_boss = boss_id
	hearts = MAX_HEARTS
	_nunchi_at_fight_start = nunchi
	hearts_changed.emit(hearts)


func lose_heart() -> void:
	hearts = maxi(hearts - 1, 0)
	hearts_changed.emit(hearts)


## On game over the fight restarts with pre-fight 눈치 (spec §2.2).
func retry_fight() -> void:
	nunchi = _nunchi_at_fight_start
	hearts = MAX_HEARTS
	nunchi_changed.emit(nunchi, 0)
	hearts_changed.emit(hearts)


# ── Saving (spec §7) ───────────────────────────────────────────────────

func to_dict() -> Dictionary:
	return {
		"nunchi": nunchi,
		"secrets_held": secrets_held,
		"secrets_known_by": secrets_known_by,
		"scores": scores,
		"progress": progress,
		"codex": codex,
	}
