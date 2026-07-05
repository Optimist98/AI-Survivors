extends CharacterBody2D
class_name Player

# === ПАРАМЕТРЫ ПЕРСОНАЖА (Баланс) ===
@export var base_speed: float = 150.0
@export var base_max_health: int = 100
@export var base_damage: int = 10
@export var base_fire_rate: float = 0.5
@export var base_crit_chance: float = 0.05
@export var base_projectile_range: float = 800.0
@export var base_vision_range: float = 300.0

# === МОДИФИКАТОРЫ (Система прокачки) ===
var modifiers: Dictionary = {
	"speed_multiplier": 1.0,
	"max_health_multiplier": 1.0,
	"damage_multiplier": 1.0,
	"fire_rate_multiplier": 1.0,
	"crit_chance_bonus": 0.0,
	"projectile_range_multiplier": 1.0,
	"vision_range_multiplier": 1.0,
}

# === ТЕКУЩИЕ ЗНАЧЕНИЯ ===
var current_health: int
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100

# === ВЫЧИСЛЯЕМЫЕ СВОЙСТВА ===
var current_max_health: int:
	get: return int(base_max_health * modifiers["max_health_multiplier"])

var current_speed: float:
	get: return base_speed * modifiers["speed_multiplier"]

var current_damage: int:
	get: return int(base_damage * modifiers["damage_multiplier"])

var current_fire_rate: float:
	get: return base_fire_rate / modifiers["fire_rate_multiplier"]

var current_crit_chance: float:
	get: return clamp(base_crit_chance + modifiers["crit_chance_bonus"], 0.0, 1.0)

var current_projectile_range: float:
	get: return base_projectile_range * modifiers["projectile_range_multiplier"]

var current_vision_range: float:
	get: return base_vision_range * modifiers["vision_range_multiplier"]

# === СИГНАЛЫ ===
signal health_changed(current: int, max: int)
signal exp_changed(current_exp: int, max_exp: int, level: int)
signal player_died

# === НАВИГАЦИЯ И ВРАГИ ===
var directions: Array[Vector2] = []
var danger: Array[float] = []
var interest: Array[float] = []
var enemies_in_range: Array[Node2D] = []

@onready var radar: Area2D = $Radar
@onready var enemy_radar: Area2D = $EnemyRadar

# === СТРЕЛЬБА ===
@export var bullet_scene: PackedScene
var can_shoot: bool = true

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	add_to_group("player")
	
	# Инициализируем здоровье
	current_health = current_max_health
	health_changed.emit(current_health, current_max_health)
	
	# Инициализируем направления
	directions = [
		Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
		Vector2.UP + Vector2.LEFT, Vector2.UP + Vector2.RIGHT,
		Vector2.DOWN + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT
	]
	for i in range(directions.size()):
		directions[i] = directions[i].normalized()
	
	danger = [0.0] * 8
	interest = [0.0] * 8
	
	# Подписываемся на сигналы
	enemy_radar.body_entered.connect(_on_enemy_entered)
	enemy_radar.body_exited.connect(_on_enemy_exited)
	ProgressionManager.level_up_available.connect(_on_level_up)
	PlayerUpgradeBus.apply_upgrade.connect(_on_upgrade_applied)

# --- ОСНОВНОЙ ЦИКЛ ---
func _physics_process(_delta: float) -> void:
	get_danger_weights()
	get_interest_weights()
	
	var chosen_direction: Vector2 = Vector2.ZERO
	for i in range(directions.size()):
		var result_weight: float = interest[i] - danger[i]
		chosen_direction += directions[i] * result_weight
	
	if chosen_direction != Vector2.ZERO:
		velocity = chosen_direction.normalized() * current_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _process(_delta: float) -> void:
	auto_shoot()

# --- СИСТЕМА AI (ВЕСА) ---
func get_danger_weights() -> void:
	danger = [0.0] * 8
	var overlapping_bodies: Array[Node2D] = radar.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("enemies"):
			var direction_to_enemy: Vector2 = (body.global_position - global_position).normalized()
			var distance: float = global_position.distance_to(body.global_position)
			var panic_factor: float = 1.0 - (distance / 300.0)
			panic_factor = clamp(panic_factor, 0.0, 1.0)
			
			for i in range(directions.size()):
				var dot: float = directions[i].dot(direction_to_enemy)
				if dot > 0:
					danger[i] = max(danger[i], dot * panic_factor)

func get_interest_weights() -> void:
	interest = [0.0] * 8
	var gems: Array[Node] = get_tree().get_nodes_in_group("gems")
	
	if gems.size() > 0:
		var closest_gem: Node = null
		var min_dist: float = 999999.0
		
		for g in gems:
			var dist: float = global_position.distance_to(g.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_gem = g
		
		if closest_gem:
			var dir_to_gem: Vector2 = (closest_gem.global_position - global_position).normalized()
			for i in range(directions.size()):
				var dot: float = directions[i].dot(dir_to_gem)
				if dot > 0:
					interest[i] = dot * 1.5

# --- СИСТЕМА СТРЕЛЬБЫ ---
func auto_shoot() -> void:
	if not can_shoot:
		return
	
	var enemy: Node2D = get_nearest_enemy()
	if enemy == null:
		return
	
	shoot(enemy)
	
	can_shoot = false
	await get_tree().create_timer(current_fire_rate).timeout
	can_shoot = true

func shoot(enemy: Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var dir: Vector2 = (enemy.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.damage = current_damage
	
	get_tree().current_scene.add_child(bullet)

func _on_enemy_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and not body in enemies_in_range:
		enemies_in_range.append(body)

func _on_enemy_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func get_nearest_enemy() -> Node2D:
	if enemies_in_range.is_empty():
		return null
	
	var nearest: Node2D = enemies_in_range[0]
	var min_dist: float = global_position.distance_to(nearest.global_position)
	
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var dist: float = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = enemy
	
	return nearest

# --- СИСТЕМА ЗДОРОВЬЯ ---
func take_damage(damage: int) -> void:
	current_health -= damage
	health_changed.emit(current_health, current_max_health)
	
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, current_max_health)
	health_changed.emit(current_health, current_max_health)

func die() -> void:
	player_died.emit()
	get_tree().reload_current_scene()

# --- СИСТЕМА ПРОКАЧКИ ---
func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"damage_up":
			modifiers["damage_multiplier"] *= 1.2
		"speed_up":
			modifiers["fire_rate_multiplier"] *= 1.15
		"move_up":
			modifiers["speed_multiplier"] *= 1.1
		"max_hp":
			modifiers["max_health_multiplier"] += 0.25
			heal(25)
		"coin_magnet":
			modifiers["vision_range_multiplier"] *= 1.33
		"crit_chance":
			modifiers["crit_chance_bonus"] += 0.05
		"projectile_range":
			modifiers["projectile_range_multiplier"] *= 1.2
		_:
			push_warning("Unknown upgrade: ", upgrade_id)

func _on_upgrade_applied(upgrade_id: String) -> void:
	apply_upgrade(upgrade_id)
	print("✓ Апгрейд применён: ", upgrade_id)

func _on_level_up(_upgrade_options: Array) -> void:
	print("⬆ УРОВЕНЬ! Доступные апгрейды: ", _upgrade_options)
