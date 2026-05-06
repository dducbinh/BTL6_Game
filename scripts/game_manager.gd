extends Node

@onready var game_over_ui = $"../CanvasLayer/GameOverUI"
@onready var result_label = $"../CanvasLayer/GameOverUI/VBoxContainer/ResultLabel"
@onready var pause_ui = $"../CanvasLayer/PauseUI"

var enemies_count = 0
var is_game_over = false

func _ready():
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	enemies_count = get_tree().get_nodes_in_group("enemies").size()
	
	# Connect to all tanks' destruction signals
	for tank in get_tree().get_nodes_in_group("tanks"):
		tank.tank_destroyed.connect(_on_tank_destroyed.bind(tank))

func _process(_delta):
	if Input.is_action_just_pressed("pause") and not is_game_over:
		toggle_pause()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	pause_ui.visible = new_pause_state
	
	if new_pause_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Keep visible for aiming

func _on_tank_destroyed(tank):
	if is_game_over: return
	
	if tank.is_in_group("player"):
		show_game_over("BẠN ĐÃ THUA!")
	elif tank.is_in_group("enemies"):
		enemies_count -= 1
		if enemies_count <= 0:
			show_game_over("BẠN ĐÃ THẮNG!")

func show_game_over(text):
	is_game_over = true
	result_label.text = text
	game_over_ui.show()
	get_tree().paused = true # Pause the world but keep UI active
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_resume_button_pressed():
	toggle_pause()
