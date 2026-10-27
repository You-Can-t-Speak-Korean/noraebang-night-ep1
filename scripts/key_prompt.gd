# The "press Enter" cue: a small drawn keycap that hovers above the nearest
# interactable (never above 보람). The World owns one per room and calls
# `point_at` every frame.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

const FONT := preload("res://art/fonts/NotoSansKR/NotoSansKR-VF.ttf")
const KEY_TEXT := "Enter"
## Cap texture size in pixels, and the quad's size in metres.
const TEX_SIZE := Vector2i(160, 96)
const QUAD_SIZE := Vector2(1.1, 0.66)
## Clearance above the interactable's top; the dev name label sits just under this.
const LIFT := 1.0

var _sprite: MeshInstance3D
var _label: Label3D


func _init() -> void:
	name = "KeyPrompt"
	visible = false


func _ready() -> void:
	var quad := QuadMesh.new()
	quad.size = QUAD_SIZE
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _make_cap_texture()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.no_depth_test = true
	mat.render_priority = 10
	_sprite = MeshInstance3D.new()
	_sprite.mesh = quad
	_sprite.material_override = mat
	add_child(_sprite)
	_label = Label3D.new()
	_label.name = "KeyText"
	_label.text = KEY_TEXT
	_label.font = FONT
	_label.font_size = 40
	_label.pixel_size = 0.0072
	_label.modulate = Color(0.12, 0.12, 0.14)
	_label.outline_size = 0
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.render_priority = 11
	_label.position = Vector3(0, 0.03, 0.01)
	add_child(_label)


## Shows the cue above `target` (an Interactable), or hides it when `target` is
## null or `active` is false.
func point_at(target: Node3D, active: bool) -> void:
	visible = active and target != null and is_instance_valid(target)
	if not visible:
		return
	var top: float = target.size.y if "size" in target else 1.5
	var depth: float = target.size.z if "size" in target else 0.4
	global_position = target.global_position + Vector3(0, top + LIFT, depth / 2.0 + 0.3)


## A rounded keycap: dark rim, light face, a darker lip along the bottom edge.
static func _make_cap_texture() -> ImageTexture:
	var w := TEX_SIZE.x
	var h := TEX_SIZE.y
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var lip := 12
	_fill_round(img, Rect2i(0, 0, w, h), 18, Color(0.1, 0.1, 0.12))
	_fill_round(img, Rect2i(4, 4, w - 8, h - 8), 15, Color(0.45, 0.45, 0.5))
	_fill_round(img, Rect2i(8, 8, w - 16, h - 8 - lip - 4), 12, Color(0.93, 0.92, 0.88))
	return ImageTexture.create_from_image(img)


static func _fill_round(img: Image, rect: Rect2i, radius: int, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var cx := clampi(x, rect.position.x + radius, rect.end.x - 1 - radius)
			var cy := clampi(y, rect.position.y + radius, rect.end.y - 1 - radius)
			if Vector2(x - cx, y - cy).length() <= radius:
				img.set_pixel(x, y, color)
