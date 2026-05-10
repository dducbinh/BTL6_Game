extends Node

# Tank stats theo loại
const TANK_STATS = {
	0: { "name": "Tank 1 - Cơ bản",   "health": 250, "damage": 40, "speed": 12.0 },
	1: { "name": "Tank 2 - Sát thương cao", "health": 250, "damage": 70, "speed": 12.0 },
	2: { "name": "Tank 3 - Máu nhiều", "health": 450, "damage": 40, "speed": 11.0 },
	3: { "name": "Tank 4 - Toàn năng", "health": 450, "damage": 70, "speed": 11.0 },
}


# Level scenes
const LEVEL_SCENES = [
	"res://scenes/world.tscn",   # Level 1
	"res://scenes/world.tscn",   # Level 2 (dùng chung map, thay đổi enemy)
	"res://scenes/world.tscn",   # Level 3
	"res://scenes/world.tscn",   # Level 4
]

# Enemy count và difficulty per level
const LEVEL_CONFIG = [
	{ "enemies": 3, "enemy_types": [0, 0, 0],         "label": "Level 1" },
	{ "enemies": 4, "enemy_types": [0, 1, 1, 0],      "label": "Level 2" },
	{ "enemies": 4, "enemy_types": [1, 1, 2, 1],      "label": "Level 3" },
	{ "enemies": 5, "enemy_types": [1, 2, 2, 2, 1],   "label": "Level 4" },
]

# Game mode: "pve" hoặc "coop"
var game_mode: String = "pve"

# Level hiện tại (0-based)
var current_level: int = 0

# Tank đã chọn (index 0-3)
var selected_tank: int = 0

# Tank nào đã unlock (ban đầu chỉ có tank 0)
var unlocked_tanks: Array[int] = [0]

func unlock_tank(index: int):
	if index not in unlocked_tanks:
		unlocked_tanks.append(index)

func get_selected_stats() -> Dictionary:
	return TANK_STATS[selected_tank]

func advance_level():
	current_level += 1
	# Unlock tank sau mỗi level hoàn thành
	if current_level == 1 and 1 not in unlocked_tanks:
		unlock_tank(1)
	if current_level == 2 and 2 not in unlocked_tanks:
		unlock_tank(2)
	if current_level == 3 and 3 not in unlocked_tanks:
		unlock_tank(3)

func reset():
	current_level = 0
	selected_tank = 0
	unlocked_tanks = [0]
