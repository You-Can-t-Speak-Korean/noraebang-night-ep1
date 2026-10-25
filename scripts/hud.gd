# Always-on HUD: hearts, 눈치, DDEOK and secret cards. Reads GameState and
# redraws on its signals.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends CanvasLayer

@onready var hearts: Control = $Box/Hearts
@onready var nunchi_label: Label = $Box/Stats/Nunchi
@onready var ddeok_label: Label = $Box/Stats/Ddeok
@onready var secrets_label: Label = $Box/Stats/Secrets


func _ready() -> void:
	GameState.hearts_changed.connect(_on_changed)
	GameState.nunchi_changed.connect(_on_changed)
	GameState.ddeok_changed.connect(_on_changed)
	GameState.secret_lost.connect(_on_secret_lost)
	GameState.state_reset.connect(refresh)
	refresh()


func refresh() -> void:
	hearts.set_hearts(GameState.hearts_halves, GameState.hearts_max_halves)
	nunchi_label.text = "눈치 %d/%d" % [GameState.nunchi, GameState.nunchi_cap]
	ddeok_label.text = "DDEOK %d" % GameState.ddeok
	secrets_label.text = "비밀 %d/%d" % [GameState.secrets_held.size(), GameState.hand.size()]


func _on_changed(_value: int) -> void:
	refresh()


func _on_secret_lost(_card: String, _by: String) -> void:
	refresh()
