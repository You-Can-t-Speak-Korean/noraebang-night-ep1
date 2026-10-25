# A door or stairway. Pressing confirm at it moves the player to
# `target_room` / `target_spawn` (the World handles the fade).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends "res://maps/interactable.gd"

@export var target_room := ""
@export var target_spawn := ""
## Placeholder lock: locked-by-day logic comes later.
@export var locked := false


func is_door() -> bool:
	return true
