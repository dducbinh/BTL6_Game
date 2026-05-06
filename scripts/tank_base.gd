extends CharacterBody3D

class_name TankBase

@export var speed: float = 10.0
@export var turn_speed: float = 2.0
@export var health: int = 100
@export var bullet_damage: int = 25
@export var team: int = 0 # 0 for Player, 1 for Enemies
var max_health: int = 100
@export var bullet_scene: PackedScene

@onready var turret = $Turret
@onready var barrel = $Turret/Barrel
@onready var shoot_point = $Turret/Barrel/ShootPoint
@onready var health_bar = get_node_or_null("HealthBar")

signal health_changed(new_health)
signal tank_destroyed

func _ready():
	add_to_group("tanks")
	max_health = health
	if health_bar:
		health_bar.update_health(health, max_health)

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health)
	if health_bar:
		health_bar.update_health(health, max_health)
	print(name, " took ", amount, " damage. HP left: ", health)
	if health <= 0:
		die()

func die():
	tank_destroyed.emit()
	queue_free()

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.set_shooter(self)
		bullet.set_damage(bullet_damage)
		get_parent().add_child(bullet)
		bullet.global_transform = shoot_point.global_transform

func rotate_turret_towards(target_pos: Vector3):
	var local_target = turret.to_local(target_pos)
	local_target.y = 0
	if local_target.length() > 0.1:
		var target_dir = local_target.normalized()
		var angle = atan2(target_dir.x, target_dir.z)
		turret.rotate_y(angle * 0.1) # Smooth rotation
