extends Area3D

@export var speed: float = 30.0
@export var damage: int = 25
@export var lifetime: float = 5.0

var shooter: Node = null
var shooter_team: int = -1

func _ready():
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)

func _process(delta):
	global_position += -global_transform.basis.z * speed * delta

func set_shooter(node: Node):
	shooter = node
	if "team" in node:
		shooter_team = node.team

func set_damage(val: int):
	damage = val

func _on_body_entered(body):
	if body == shooter:
		return
	
	print("Bullet hit: ", body.name)
	if body.has_method("take_damage"):
		# Neutralize bullet if shooter is gone
		if not is_instance_valid(shooter):
			queue_free()
			return
			
		# Only damage if not in the same team
		if not ("team" in body) or body.team != shooter_team:
			body.take_damage(damage)
	
	queue_free()
