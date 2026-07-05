extends CharacterBody2D
class_name Enemy

# === ЭКСПОРТ (Баланс) ===
@export var max_health: int = 10
@export var exp_value: int = 3
@export var speed: float = 80.0
@export var knockback_strength: float = 350.0
@export var gem_scene: PackedScene = preload("res://Scene/gem.tscn")

# === УЗЛЫ ===
@onready var health_bar: ProgressBar = $ProgressBar
@onready var sprite: Polygon2D = $Polygon2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

# === СОСТОЯНИЕ ===
var health: int
var knockback_velocity: Vector2 = Vector2.ZERO

# --- ЖИЗНЕННЫЙ ЦИКЛ ---
func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false
	
	# Сообщаем системе, что враг спавнулся
	EnemySignalBus.enemy_spawned.emit(self)

func _physics_process(_delta: float) -> void:
	if player:
		var dir: Vector2 = (player.global_position - global_position).normalized() * speed
		velocity = dir + knockback_velocity
		
		# Декэй knockback каждый кадр
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
		
		move_and_slide()

# --- СИСТЕМА УРОНА ---
func take_damage(damage: int) -> void:
	hit_flash()
	health -= damage
	health_bar.visible = true
	health_bar.value = health
	
	if health > 0:
		# Knockback только если жив
		var player_pos: Vector2 = get_tree().get_first_node_in_group("player").global_position
		var knockback_dir: Vector2 = (global_position - player_pos).normalized()
		knockback_velocity += knockback_dir * knockback_strength
	else:
		die()

func hit_flash() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_callback(func(): 
		sprite.modulate = Color.WHITE
		sprite.scale = Vector2.ONE
	)

# --- СМЕРТЬ ---
func _die() -> void:
	# 1. Излучаем сигнал ДО уничтожения (чтобы менеджер успел обработать)
	EnemySignalBus.enemy_died.emit(self, global_position)
	
	# 2. Визуальный фидбек (покиданию на спавн гема)
	if gem_scene:
		call_deferred("spawn_gem")
	
	# 3. Удаляем объект
	call_deferred("queue_free")

func spawn_gem() -> void:
	var gem = gem_scene.instantiate()
	get_parent().add_child(gem)
	gem.global_position = global_position

# --- ГЕТТЕРЫ ---
func get_exp_value() -> int:
	return exp_value

func die() -> void:
	_die()
