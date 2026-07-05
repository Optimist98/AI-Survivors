extends CharacterBody2D
class_name Bullet

# === ПАРАМЕТРЫ ===
@export var speed: float = 400.0
@export var base_damage: int = 10
@export var lifetime: float = 5.0

# === СОСТОЯНИЕ ===
var direction: Vector2 = Vector2.ZERO
var damage: int

# === УЗЛЫ ===
@onready var collision: CollisionShape2D = $CollisionShape2D

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	damage = base_damage
	
	# Таймер на уничтожение (если не столкнулся)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# --- ДВИЖЕНИЕ ---
func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	
	if collision_info:
		var collider: Node = collision_info.get_collider()
		
		if collider.is_in_group("enemies"):
			collider.take_damage(damage)
			queue_free()

# --- ГЕТТЕРЫ ---
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
