extends Control

@onready var level_label = $VBoxContainer/LevelLabel
@onready var level_buttons_container = $VBoxContainer/LevelButtons

func _ready():
	level_label.text = "Chọn màn chơi"
	
	for i in range(3):
		var btn = level_buttons_container.get_child(i)
		if not btn:
			continue
		
		var cfg = GameState.LEVEL_CONFIG[i]
		btn.text = cfg["label"]
		btn.disabled = i > GameState.max_unlocked_level
		
		if btn.disabled:
			btn.text = "🔒 " + cfg["label"]
		
		var idx = i
		btn.pressed.connect(func(): _on_level_selected(idx))

func _on_level_selected(index: int):
	if index > GameState.max_unlocked_level:
		return
	GameState.current_level = index
	get_tree().change_scene_to_file(GameState.LEVEL_SCENES[index])

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
