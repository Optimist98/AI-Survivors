extends Node
## Глобальный менеджер прогрессии (опыт, уровни, монеты)
## Добавить в Autoload как "ProgressionManager"

# === СИГНАЛЫ ДЛЯ UI ===
signal exp_changed(current_exp: int, max_exp: int, level: int)
signal coins_changed(amount: int)
signal level_up_available(upgrade_options: Array)  # массив словарей с апгрейдами

# === ИНСПЕКТОР (Баланс) ===
@export var exp_per_level_base: int = 10        # Опыта для 1-го уровня
@export var exp_per_level_growth: float = 1.5   # Множитель на каждый след. уровень
@export var coins_per_enemy_base: int = 1
@export var coins_per_enemy_variance: int = 2   # Разброс (от 1 до 1+2 = 3 монет)

# === ПРИВАТНЫЕ ПЕРЕМЕННЫЕ ===
var _current_level: int = 1
var _current_exp: int = 0
var _current_coins: int = 0

# === СВОЙСТВА (для чтения снаружи) ===
var current_level: int:
	get: return _current_level

var current_exp: int:
	get: return _current_exp

var current_coins: int:
	get: return _current_coins

# === КЭШ ДЛЯ БЫСТРОГО РАСЧЕТА ===
var _cached_exp_required: int:
	get:
		return int(exp_per_level_base * pow(exp_per_level_growth, _current_level - 1))

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	# Подписываемся на сигнал смерти врага (глобальный)
	if not EnemySignalBus:
		push_error("ProgressionManager: Не найден EnemySignalBus. Создайте Autoload с сигналом enemy_died.")
	else:
		EnemySignalBus.enemy_died.connect(_on_enemy_died)
	
	# Первичная отправка UI
	exp_changed.emit(_current_exp, _cached_exp_required, _current_level)
	coins_changed.emit(_current_coins)

# --- ПУБЛИЧНЫЕ МЕТОДЫ (Вызываются извне) ---
func add_exp(amount: int) -> void:
	_current_exp += amount
	_check_level_up()

func add_coins(amount: int) -> void:
	_current_coins += amount
	coins_changed.emit(_current_coins)

func spend_coins(amount: int) -> bool:
	if _current_coins >= amount:
		_current_coins -= amount
		coins_changed.emit(_current_coins)
		return true
	return false

# --- ПРИВАТНАЯ ЛОГИКА ---
func _on_enemy_died(enemy: Node2D, position: Vector2) -> void:
	# 1. Начисляем опыт
	var exp_gain: int = 5
	if enemy.has_method("get_exp_value"):
		exp_gain += enemy.get_exp_value()
	add_exp(exp_gain)
	
	# 2. Генерируем монеты с вариативностью
	var coin_gain: int = coins_per_enemy_base + randi_range(0, coins_per_enemy_variance)
	add_coins(coin_gain)

func _check_level_up() -> void:
	var required = _cached_exp_required
	while _current_exp >= required:
		_current_exp -= required
		_current_level += 1
		required = _cached_exp_required  # пересчет для нового уровня
		
		# ГЕНЕРАЦИЯ КАРТОЧЕК АПГРЕЙДА (3 случайных)
		var options: Array = _generate_upgrade_options(3)
		level_up_available.emit(options)
		
		# Пауза игры
		get_tree().paused = true
	
	# Обновляем UI
	exp_changed.emit(_current_exp, _cached_exp_required, _current_level)

func _generate_upgrade_options(count: int) -> Array:
	var all_abilities = [
		{"id": "damage_up", "name": "Урон +20%", "icon": preload("res://icon.svg")},
		{"id": "speed_up", "name": "Скорость стрельбы +15%", "icon": preload("res://icon.svg")},
		{"id": "move_up", "name": "Скорость героя +10%", "icon": preload("res://icon.svg")},
		{"id": "max_hp", "name": "Макс. здоровье +25", "icon": preload("res://icon.svg")},
		{"id": "coin_magnet", "name": "Магнит на монеты +100px", "icon": preload("res://icon.svg")},
	]
	all_abilities.shuffle()
	return all_abilities.slice(0, count)
