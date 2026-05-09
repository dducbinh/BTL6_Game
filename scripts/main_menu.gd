extends Control

func _on_pve_button_pressed():
	GameState.game_mode = "pve"
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/tank_selection.tscn")

func _on_pvp_button_pressed():
	print("PvP Mode - Coming Soon!")

func _on_coop_button_pressed():
	GameState.game_mode = "coop"
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/tank_selection.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
