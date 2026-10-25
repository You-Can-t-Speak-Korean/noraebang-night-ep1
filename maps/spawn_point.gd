# Where the player appears. The node name is the spawn name; x comes from the
# node position.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Marker3D

@export var lane := 0


func is_spawn_point() -> bool:
	return true
