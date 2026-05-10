extends Node

const LEVEL_SCENES = [
	"res://scenes/world.tscn",    # Level 1
	"res://scenes/world2.tscn",   # Level 2
	"res://scenes/world3.tscn",   # Level 3
]

const LEVEL_CONFIG = [
	{ "enemies": 3, "enemy_types": [0, 0, 0],         "label": "Level 1" },
	{ "enemies": 4, "enemy_types": [0, 1, 1, 0],      "label": "Level 2" },
	{ "enemies": 4, "enemy_types": [1, 1, 2, 1],      "label": "Level 3" },
]

# Stats mặc định cho player (1 loại duy nhất)
const PLAYER_STATS = { "health": 250, "damage": 40, "speed": 12.0 }

var game_mode: String = "pve"
var current_level: int = 0
var max_unlocked_level: int = 0  # level tối đa đã mở khoá

func get_player_stats() -> Dictionary:
	return PLAYER_STATS

func advance_level():
	current_level += 1
	if current_level > max_unlocked_level:
		max_unlocked_level = current_level

func reset():
	current_level = 0
