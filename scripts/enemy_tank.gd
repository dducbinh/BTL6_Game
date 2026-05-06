extends TankBase

enum EnemyType { LIGHT, MEDIUM, HEAVY }
@export var enemy_type: EnemyType = EnemyType.MEDIUM

@export var detection_range: float = 40.0
@export var attack_range: float = 25.0
@export var shoot_cooldown: float = 2.0

var player: Node3D = null
var can_shoot: bool = true

func _ready():
	team = 1
	super._ready()
	setup_stats()
	player = get_tree().get_first_node_in_group("player")

func setup_stats():
	var body_mesh: MeshInstance3D = $Body
	var mat = body_mesh.get_surface_override_material(0).duplicate()
	
	match enemy_type:
		EnemyType.LIGHT:
			speed = 18.0
			health = 50
			bullet_damage = 15
			shoot_cooldown = 1.0
			attack_range = 20.0
			scale = Vector3(0.8, 0.9, 0.8) # Not too short, so bullets can hit it
			$Turret.scale = Vector3(0.9, 0.9, 0.9)
			$Turret/Barrel.scale = Vector3(0.7, 0.7, 1.2)
			mat.albedo_color = Color(0.8, 0.8, 0.2)
		EnemyType.MEDIUM:
			speed = 13.0
			health = 100
			bullet_damage = 25
			shoot_cooldown = 2.0
			attack_range = 25.0
			scale = Vector3(1.0, 1.0, 1.0)
			mat.albedo_color = Color(0.8, 0.4, 0.1)
		EnemyType.HEAVY:
			speed = 9.0
			health = 350
			bullet_damage = 45
			shoot_cooldown = 3.5
			attack_range = 30.0
			scale = Vector3(1.4, 1.2, 1.4)
			$Turret.scale = Vector3(1.2, 1.1, 1.2)
			$Turret/Barrel.scale = Vector3(1.5, 1.5, 0.8)
			mat.albedo_color = Color(0.5, 0.1, 0.1)
	
	body_mesh.set_surface_override_material(0, mat)
	$Turret/TurretMesh.set_surface_override_material(0, mat)
	$Turret/Barrel/BarrelMesh.set_surface_override_material(0, mat)
	
	max_health = health
	if health_bar:
		health_bar.update_health(health, max_health)

func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return

	var dist = global_position.distance_to(player.global_position)
	
	if dist < detection_range:
		# Rotate turret to player
		var look_at_pos = Vector3(player.global_position.x, turret.global_position.y, player.global_position.z)
		turret.look_at(look_at_pos, Vector3.UP)
		
		if dist > attack_range:
			# Move towards player
			var dir = (player.global_position - global_position).normalized()
			velocity = dir * speed
			
			# Smooth rotate body to face movement using quaternions (to avoid scale issues)
			var target_basis = Basis.looking_at(dir, Vector3.UP, true) # true means dir is a direction, not a target
			var target_quat = target_basis.get_rotation_quaternion()
			quaternion = quaternion.slerp(target_quat, 5.0 * delta)
		else:
			# Stop and shoot
			velocity = Vector3.ZERO
			if can_shoot:
				ai_shoot()
	else:
		velocity = Vector3.ZERO

	move_and_slide()

func ai_shoot():
	can_shoot = false
	shoot()
	# Add a small random jitter to prevent perfect sync
	var jitter = randf_range(0.8, 1.2)
	await get_tree().create_timer(shoot_cooldown * jitter).timeout
	can_shoot = true
