# THROWAWAY DEBUG STAGE — proves Forward+ fog (standard + volumetric), the
# input map and Korean glyphs. Not part of the game; delete once real maps exist.
#   F1 toggles volumetric fog, F2 toggles standard fog.
#   Capture run (needs a real window, not --headless):
#     godot --path . -- --capture
#   saves three PNGs to tests/shots/ and exits non-zero if they look wrong.
#
# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

const ROOM_HALF_WIDTH := 6.0
const ROOM_DEPTH := 14.0
const ROOM_HEIGHT := 5.0
const BORAM_SPEED := 4.0
const SETTLE_FRAMES := 20
const COMPARE_SIZE := Vector2i(480, 270)

var env: Environment
var boram: MeshInstance3D
var label: Label
var grey := StandardMaterial3D.new()


func _ready() -> void:
	grey.albedo_color = Color(0.55, 0.55, 0.57)
	grey.roughness = 1.0
	_build_room()
	_build_boxes()
	_build_boram()
	_build_camera_and_light()
	_build_label()
	if "--capture" in OS.get_cmdline_user_args():
		_run_capture()


func _process(delta: float) -> void:
	boram.position.x = clampf(
		boram.position.x + Input.get_axis("move_left", "move_right") * BORAM_SPEED * delta,
		-ROOM_HALF_WIDTH + 0.5, ROOM_HALF_WIDTH - 0.5)
	label.text = _status_text()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			env.volumetric_fog_enabled = not env.volumetric_fog_enabled
		elif event.keycode == KEY_F2:
			env.fog_enabled = not env.fog_enabled


# ── Build ──────────────────────────────────────────────────────────────

func _add_box(pos: Vector3, size: Vector3, node_name: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var inst := MeshInstance3D.new()
	inst.name = node_name
	inst.mesh = mesh
	inst.material_override = grey
	inst.position = pos
	add_child(inst)
	return inst


func _build_room() -> void:
	_add_box(Vector3(0, -0.1, -ROOM_DEPTH / 2), Vector3(ROOM_HALF_WIDTH * 2, 0.2, ROOM_DEPTH), "Floor")
	_add_box(Vector3(0, ROOM_HEIGHT / 2, -ROOM_DEPTH), Vector3(ROOM_HALF_WIDTH * 2, ROOM_HEIGHT, 0.2), "BackWall")
	_add_box(Vector3(-ROOM_HALF_WIDTH, ROOM_HEIGHT / 2, -ROOM_DEPTH / 2), Vector3(0.2, ROOM_HEIGHT, ROOM_DEPTH), "LeftWall")
	_add_box(Vector3(ROOM_HALF_WIDTH, ROOM_HEIGHT / 2, -ROOM_DEPTH / 2), Vector3(0.2, ROOM_HEIGHT, ROOM_DEPTH), "RightWall")


func _build_boxes() -> void:
	# Different depths (z) so fog falloff reads front to back.
	var specs := [
		[Vector3(-3.5, 0.75, -3.0), Vector3(1.0, 1.5, 1.0)],
		[Vector3(3.0, 1.0, -5.0), Vector3(1.2, 2.0, 1.2)],
		[Vector3(-2.0, 1.5, -7.5), Vector3(1.0, 3.0, 1.0)],
		[Vector3(2.5, 0.5, -9.5), Vector3(1.6, 1.0, 1.6)],
		[Vector3(-3.5, 2.0, -11.5), Vector3(1.2, 4.0, 1.2)],
		[Vector3(1.0, 1.25, -12.5), Vector3(1.0, 2.5, 1.0)],
	]
	for i in specs.size():
		_add_box(specs[i][0], specs[i][1], "Box%d" % i)


func _build_boram() -> void:
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.25
	mesh.height = 1.2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.35, 0.3)
	boram = MeshInstance3D.new()
	boram.name = "Boram"
	boram.mesh = mesh
	boram.material_override = mat
	boram.position = Vector3(0, 0.6, -1.5)
	add_child(boram)


func _build_camera_and_light() -> void:
	var cam := Camera3D.new()
	cam.name = "Camera"
	cam.fov = 50.0
	cam.position = Vector3(0, 3.6, 9.0)
	add_child(cam)
	cam.look_at(Vector3(0, 1.4, -6.0))

	var light := SpotLight3D.new()
	light.name = "Light"
	light.position = Vector3(0, 4.6, -2.0)
	add_child(light)
	light.look_at(Vector3(0, 0, -8.0))
	light.spot_range = 24.0
	light.spot_angle = 45.0
	light.light_energy = 10.0
	light.shadow_enabled = true
	light.light_volumetric_fog_energy = 4.0

	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.04, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.25, 0.25, 0.3)
	env.fog_enabled = true
	env.fog_light_color = Color(0.45, 0.45, 0.5)
	env.fog_density = 0.025
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.035
	env.volumetric_fog_albedo = Color(0.9, 0.9, 1.0)
	env.volumetric_fog_length = 40.0
	env.volumetric_fog_temporal_reprojection_enabled = false
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)


func _build_label() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	label = Label.new()
	label.position = Vector2(16, 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	layer.add_child(label)


func _status_text() -> String:
	return "method: %s\ndriver: %s\nadapter: %s\nFPS: %d\nvolumetric fog (F1): %s\nstandard fog (F2): %s\n%s" % [
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_current_rendering_driver_name(),
		RenderingServer.get_video_adapter_name(),
		Engine.get_frames_per_second(),
		"on" if env.volumetric_fog_enabled else "off",
		"on" if env.fog_enabled else "off",
		"니가 한국어 못해 · 장보람 · 눈치 · 빨간약 · 반창고",
	]


# ── Capture mode ───────────────────────────────────────────────────────

func _run_capture() -> void:
	var shots_dir := Shots.dir()
	var steps := [
		["fog_off", false, false],
		["fog_standard", true, false],
		["fog_both", true, true],
	]
	var images := {}
	for step in steps:
		env.fog_enabled = step[1]
		env.volumetric_fog_enabled = step[2]
		for i in SETTLE_FRAMES:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := "%s/%s.png" % [shots_dir, step[0]]
		img.save_png(path)
		print("saved ", path)
		img.convert(Image.FORMAT_RGB8)
		img.resize(COMPARE_SIZE.x, COMPARE_SIZE.y, Image.INTERPOLATE_BILINEAR)
		images[step[0]] = img
	print("adapter: ", RenderingServer.get_video_adapter_name())
	print("rendering method: ", RenderingServer.get_current_rendering_method())
	print("rendering driver: ", RenderingServer.get_current_rendering_driver_name())

	var ok := true
	for key in images:
		var lum := _mean_luminance(images[key])
		print("mean luminance %s: %.4f" % [key, lum])
		if lum < 0.001:
			print("FAIL: %s is fully black" % key)
			ok = false
	var d_std := _mean_abs_diff(images["fog_off"], images["fog_standard"])
	var d_both := _mean_abs_diff(images["fog_off"], images["fog_both"])
	print("mean abs diff off vs standard: %.5f" % d_std)
	print("mean abs diff off vs both: %.5f" % d_both)
	if d_std == 0.0 or d_both == 0.0:
		print("FAIL: fog states produced identical images")
		ok = false
	get_tree().quit(0 if ok else 1)


## 0..1 over RGB.
func _mean_abs_diff(a: Image, b: Image) -> float:
	var da := a.get_data()
	var db := b.get_data()
	var total := 0
	for i in da.size():
		total += absi(da[i] - db[i])
	return float(total) / float(da.size()) / 255.0


## Rec. 709 luminance, 0..1.
func _mean_luminance(img: Image) -> float:
	var d := img.get_data()
	var total := 0.0
	for i in range(0, d.size(), 3):
		total += 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]
	return total / float(d.size() / 3) / 255.0
