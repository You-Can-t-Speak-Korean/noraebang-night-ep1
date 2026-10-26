# Where the --capture-* modes write their PNGs: tests/shots/ at the repo root
# (git-ignored, with a .gdignore so Godot never imports the images).
#
# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Shots


## Absolute path of tests/shots/ (or a subfolder of it), created if missing.
static func dir(sub: String = "") -> String:
	var root := ProjectSettings.globalize_path("res://tests/shots/")
	DirAccess.make_dir_recursive_absolute(root)
	var marker := root.path_join(".gdignore")
	if not FileAccess.file_exists(marker):
		FileAccess.open(marker, FileAccess.WRITE).close()
	var path := root if sub == "" else root.path_join(sub)
	DirAccess.make_dir_recursive_absolute(path)
	return path.trim_suffix("/")
