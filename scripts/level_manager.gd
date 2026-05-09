extends Node

@onready var game_over_ui = $"../CanvasLayer/GameOverUI"
@onready var result_label = $"../CanvasLayer/GameOverUI/VBoxContainer/ResultLabel"
@onready var pause_ui = $"../CanvasLayer/PauseUI"
@onready var hud_label = $"../CanvasLayer/HUDLabel"  # Label hiện level info (thêm vào scene)

var enemies_count = 0
var is_game_over = false

func _ready():
	await get_tree().process_frame
	
	# Spawn player tank đúng loại
	_spawn_player_tank()
	
	# Setup enemies theo level config
	_setup_level_enemies()
	
	enemies_count = get_tree().get_nodes_in_group("enemies").size()
	
	# Connect tank destruction signals
	for tank in get_tree().get_nodes_in_group("tanks"):
		tank.tank_destroyed.connect(_on_tank_destroyed.bind(tank))
	
	# Hiển thị HUD level
	if hud_label:
		var cfg = GameState.LEVEL_CONFIG[GameState.current_level]
		hud_label.text = cfg["label"] + " | " + GameState.TANK_STATS[GameState.selected_tank]["name"]
		
	_spawn_stars()

func _spawn_stars():
	var star_scene = load("res://scenes/star_pickup.tscn")
	var positions = [
	Vector3(-8, 1, -8),
	Vector3(5, 1, -18),
	Vector3(12, 1, 3)
	]
	
	for pos in positions:
		var star = star_scene.instantiate()
		get_parent().add_child(star)
		star.global_position = pos

func _spawn_player_tank():
	# Tìm PlayerTank placeholder trong scene
	var existing_player = get_tree().get_first_node_in_group("player")
	if not existing_player:
		return
	
	# Áp dụng stats từ GameState
	var stats = GameState.get_selected_stats()
	existing_player.health = stats["health"]
	existing_player.bullet_damage = stats["damage"]
	existing_player.speed = stats["speed"]
	existing_player.max_health = stats["health"]
	
	# Cập nhật health bar
	if existing_player.health_bar:
		existing_player.health_bar.update_health(stats["health"], stats["health"])
	
	# Đổi visual mesh sang tank tương ứng nếu có scene riêng
	# (Nếu muốn swap mesh, làm ở đây)

func _setup_level_enemies():
	var cfg = GameState.LEVEL_CONFIG[GameState.current_level]
	var enemy_types = cfg["enemy_types"]
	var enemies_node = get_node_or_null("../Enemies")
	if not enemies_node:
		return
	
	# Gán enemy_type cho từng enemy con
	var children = enemies_node.get_children()
	for i in range(min(children.size(), enemy_types.size())):
		if children[i].has_method("setup_stats"):
			children[i].enemy_type = enemy_types[i]
			children[i].setup_stats()
	
	# Ẩn các enemy dư (nếu scene có nhiều hơn config)
	for i in range(enemy_types.size(), children.size()):
		children[i].queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("pause") and not is_game_over:
		toggle_pause()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	pause_ui.visible = new_pause_state
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_tank_destroyed(tank):
	if is_game_over:
		return
	
	if tank.is_in_group("player"):
		show_game_over("BẠN ĐÃ THUA!")
	elif tank.is_in_group("enemies"):
		enemies_count -= 1
		if enemies_count <= 0:
			_on_level_complete()

func _on_level_complete():
	is_game_over = true
	GameState.advance_level()
	
	var is_last_level = GameState.current_level >= GameState.LEVEL_CONFIG.size()
	
	if is_last_level:
		result_label.text = "BẠN ĐÃ THẮNG TẤT CẢ!"
		# Xoá nút Next Level nếu có
		var next_btn = game_over_ui.find_child("NextLevelButton", true, false)
		if next_btn:
			next_btn.visible = false
	else:
		var unlocked = GameState.LEVEL_CONFIG[GameState.current_level]["label"]
		result_label.text = "LEVEL HOÀN THÀNH!\nĐã mở: " + unlocked
	
	game_over_ui.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_game_over(text: String):
	is_game_over = true
	result_label.text = text
	game_over_ui.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_button_pressed():
	get_tree().paused = false
	# Reset level, giữ nguyên tank đã chọn
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/tank_selection.tscn")

func _on_next_level_button_pressed():
	get_tree().paused = false
	# Sang màn chọn tank (có thêm tank mới unlock)
	get_tree().change_scene_to_file("res://scenes/tank_selection.tscn")

func _on_menu_button_pressed():
	get_tree().paused = false
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_resume_button_pressed():
	toggle_pause()
