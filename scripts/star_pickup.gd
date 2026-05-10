extends Area3D

enum BuffType {
	HEAL,
	DAMAGE_BOOST,
	SPEED_BOOST,
}

@export var buff_duration: float = 8.0
@export var heal_amount: int = 60
@export var damage_multiplier: float = 1.8
@export var speed_multiplier: float = 1.6

@export var rotate_speed: float = 2.0
@export var bob_amplitude: float = 0.3
@export var bob_speed: float = 2.0

var _original_y: float
var _time: float = 0.0
var _collected: bool = false

const BUFF_COLORS = {
	BuffType.HEAL: Color(0.2, 1.0, 0.2),
	BuffType.DAMAGE_BOOST: Color(1.0, 0.3, 0.1),
	BuffType.SPEED_BOOST: Color(0.2, 0.6, 1.0),
}

const BUFF_NAMES = {
	BuffType.HEAL: "💚 Hồi máu",
	BuffType.DAMAGE_BOOST: "🔥 Tăng sát thương",
	BuffType.SPEED_BOOST: "⚡ Tăng tốc độ",
}

var buff_type: BuffType

func _ready():
	_original_y = global_position.y
	buff_type = randi() % 3 as BuffType
	
	# Đảm bảo Area3D có thể detect collision
	monitoring = true
	monitorable = true
	
	_apply_visual_color()
	body_entered.connect(_on_body_entered)

func _apply_visual_color():
	var color = BUFF_COLORS[buff_type]
	# Tìm MeshInstance3D trong toàn bộ cây con
	for child in find_children("*", "MeshInstance3D", true, false):
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color * 0.5
		child.material_override = mat
		break

func _process(delta):
	if _collected:
		return
	_time += delta
	rotate_y(rotate_speed * delta)
	global_position.y = _original_y + sin(_time * bob_speed) * bob_amplitude

func _on_body_entered(body: Node3D):
	if _collected:
		return
	# Kiểm tra có phải tank player không (có thuộc tính health)
	if not "health" in body:
		return
	# Chỉ player mới nhận buff (enemy bỏ qua)
	if not body.is_in_group("player"):
		return
	
	_collected = true
	_apply_buff(body)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)

func _apply_buff(target: Node):
	var buff_name = BUFF_NAMES[buff_type]
	print("[PowerUp] ", target.name, " nhận buff: ", buff_name)
	
	match buff_type:
		BuffType.HEAL:
			_apply_heal(target)
		BuffType.DAMAGE_BOOST:
			_apply_damage_boost(target)
		BuffType.SPEED_BOOST:
			_apply_speed_boost(target)
	
	_show_buff_popup(buff_name)

func _apply_heal(target: Node):
	if not "health" in target or not "max_health" in target:
		return
	var old_health = target.health
	target.health = min(target.health + heal_amount, target.max_health)
	if target.has_method("") or "health_bar" in target:
		if target.health_bar:
			target.health_bar.update_health(target.health, target.max_health)
	print("[Heal] ", old_health, " -> ", target.health)

func _apply_damage_boost(target: Node):
	if not "bullet_damage" in target:
		return
	var original = target.bullet_damage
	target.bullet_damage = int(original * damage_multiplier)
	print("[DamageBoost] ", original, " -> ", target.bullet_damage)
	get_tree().create_timer(buff_duration).timeout.connect(func():
		if is_instance_valid(target):
			target.bullet_damage = original
	)

func _apply_speed_boost(target: Node):
	if not "speed" in target:
		return
	var original = target.speed
	target.speed = original * speed_multiplier
	print("[SpeedBoost] ", original, " -> ", target.speed)
	get_tree().create_timer(buff_duration).timeout.connect(func():
		if is_instance_valid(target):
			target.speed = original
	)

func _show_buff_popup(text: String):
	var label = Label3D.new()
	label.text = text
	label.font_size = 48
	label.modulate = BUFF_COLORS[buff_type]
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = global_position + Vector3(0, 1.5, 0)
	get_parent().add_child(label)
	
	var tween = label.create_tween()
	tween.tween_property(label, "global_position",
		label.global_position + Vector3(0, 2.0, 0), 1.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)
