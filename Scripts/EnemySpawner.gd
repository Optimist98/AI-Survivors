extends Node2D
class_name EnemySpawner

# === ПАРАМЕТРЫ СПАВНА ===
@export var enemy_scene: PackedScene
@export var initial_spawn_rate: float = 2.0  # враг в сек
@export var spawn_rate_growth: float = 1.02  # умножитель каждые 10 сек
@export var spawn_area_radius: float = 400.0
@export var max_enemies: int = 50
@export var difficulty_scale_time: float = 10.0  # каждые N сек сложность растёт

# === УЗЛЫ ===
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var enemies_container: Node2D = $Enemies

# === СОСТОЯНИЕ ===
var current_spawn_rate: float = 1.0
var time_elapsed: float = 0.0
var spawn_cooldown: float = 0.0
var active_enemies: int = 0

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	if not enemies_container:
		enemies_container = Node2D.new()
		enemies_container.name = "Enemies"
		add_child(enemies_container)
	
	current_spawn_rate = initial_spawn_rate
	spawn_cooldown = 1.0 / current_spawn_rate
	
	# Слушаем событие смерти врага
	EnemySignalBus.enemy_died.connect(_on_enemy_died)

# --- ОСНОВНОЙ ЦИКЛ ---
func _process(delta: float) -> void:
	if not player:
		return
	
	time_elapsed += delta
	spawn_cooldown -= delta
	
	# Растём сложность
	_update_difficulty()
	
	# Спавним если кулдаун истёк и не много врагов
	if spawn_cooldown <= 0.0 and active_enemies < max_enemies:
		spawn_enemy()
		spawn_cooldown = 1.0 / current_spawn_rate

# --- СПАВН ВРАГА ---
func spawn_enemy() -> void:
	if not enemy_scene or not player:
		return
	
	# Случайное направление и расстояние
	var angle: float = randf() * TAU
	var distance: float = spawn_area_radius
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	# Создаём врага
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemies_container.add_child(enemy)
	
	active_enemies += 1

# --- СИСТЕМА СЛОЖНОСТИ ---
func _update_difficulty() -> void:
	var difficulty_level: int = int(time_elapsed / difficulty_scale_time)
	var new_spawn_rate: float = initial_spawn_rate * pow(spawn_rate_growth, difficulty_level)
	
	current_spawn_rate = new_spawn_rate

func _on_enemy_died(_enemy: Node2D, _pos: Vector2) -> void:
	active_enemies = max(0, active_enemies - 1)

# --- ОТЛАДКА ---
func get_enemy_count() -> int:
	return active_enemies

func get_difficulty_level() -> int:
	return int(time_elapsed / difficulty_scale_time)

func get_current_spawn_rate() -> float:
	return current_spawn_rate
