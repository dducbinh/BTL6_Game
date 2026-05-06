extends TankBase

@onready var camera_pivot = $CameraPivot
@export var shoot_cooldown: float = 0.4 # Faster fire rate
var can_shoot: bool = true

func _ready():
	speed = 12.0 # Faster movement
	health = 250 # More health
	bullet_damage = 40 # More damage
	super._ready()

func _physics_process(delta):
	# Movement
	var input_dir = Input.get_vector("turn_left", "turn_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Turn body
	if input_dir.x != 0:
		rotate_y(-input_dir.x * turn_speed * delta)

	move_and_slide()
	
	# Turret rotation towards mouse
	rotate_turret_to_mouse()
	
	# Shooting
	if Input.is_action_just_pressed("shoot") and can_shoot:
		player_shoot()

func player_shoot():
	can_shoot = false
	shoot()
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func rotate_turret_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if not camera: return
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var target_point = result.position
		var look_at_pos = Vector3(target_point.x, turret.global_position.y, target_point.z)
		turret.look_at(look_at_pos, Vector3.UP)
