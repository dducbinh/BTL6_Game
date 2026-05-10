extends Node

func _ready():
	optimize_physics()
	optimize_rendering()

func optimize_physics():
	# Giảm physics tick rate nếu cần
	Engine.physics_ticks_per_second = 60

	# Tắt physics debug nếu bật
	if get_tree().debug_collisions_hint:
		get_tree().debug_collisions_hint = false

func optimize_rendering():
	# Tối ưu rendering
	get_viewport().msaa_3d = Viewport.MSAA_2X

	# Giảm shadow quality nếu cần
	var light = get_tree().get_first_node_in_group("lights")
	if light and light is DirectionalLight3D:
		light.shadow_blur = 1
		light.directional_shadow_split_1 = 0.1
		light.directional_shadow_split_2 = 0.3
		light.directional_shadow_split_3 = 0.6
