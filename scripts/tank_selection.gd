extends Control

# UI nodes - cần tạo trong scene tương ứng
@onready var tank_buttons: Array = []
@onready var info_label = $VBoxContainer/InfoLabel
@onready var start_button = $VBoxContainer/StartButton
@onready var level_label = $VBoxContainer/LevelLabel

# Preview nodes (optional - nếu có)
var selected_index: int = 0

func _ready():
	# Hiển thị level hiện tại
	var level_cfg = GameState.LEVEL_CONFIG[GameState.current_level]
	level_label.text = "🎯 " + level_cfg["label"] + " - " + GameState.game_mode.to_upper()

	# Tìm tank button container
	var btn_container = $VBoxContainer/TankButtons
	for i in range(4):
		var btn = btn_container.get_child(i)
		if btn:
			tank_buttons.append(btn)
			var tank_name = GameState.TANK_STATS[i]["name"]
			btn.text = tank_name
			btn.disabled = i not in GameState.unlocked_tanks
			
			# Thêm icon khoá nếu chưa unlock
			if btn.disabled:
				btn.text = "🔒 " + tank_name
			
			var idx = i  # capture for lambda
			btn.pressed.connect(func(): _on_tank_selected(idx))

	_on_tank_selected(GameState.selected_tank)

func _on_tank_selected(index: int):
	if index not in GameState.unlocked_tanks:
		return
	
	selected_index = index
	GameState.selected_tank = index
	
	var stats = GameState.TANK_STATS[index]
	info_label.text = "❤️ HP: %d   ⚔️ Damage: %d   ⚡ Speed: %.0f" % [
		stats["health"], stats["damage"], stats["speed"]
	]
	
	# Highlight button được chọn
	for i in range(tank_buttons.size()):
		if tank_buttons[i]:
			tank_buttons[i].modulate = Color.YELLOW if i == index else Color.WHITE

func _on_start_pressed():
	var level_cfg = GameState.LEVEL_CONFIG[GameState.current_level]
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
