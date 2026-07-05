extends CanvasLayer
class_name HUD

# === УЗЛЫ ===
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var exp_bar: ProgressBar = $VBoxContainer/ExpBar
@onready var exp_label: Label = $VBoxContainer/ExpLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var coins_label: Label = $VBoxContainer/CoinsLabel
@onready var wave_timer_label: Label = $VBoxContainer/WaveTimerLabel

# === СОСТОЯНИЕ ===
var player: Player = null
var elapsed_time: float = 0.0

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		push_error("HUD: Player не найден!")
		return
	
	# Подписываемся на сигналы игрока
	player.health_changed.connect(_on_player_health_changed)
	
	# Подписываемся на сигналы менеджера прогрессии
	ProgressionManager.exp_changed.connect(_on_exp_changed)
	ProgressionManager.coins_changed.connect(_on_coins_changed)
	
	# Инициализируем UI
	_on_player_health_changed(player.current_health, player.current_max_health)
	_on_exp_changed(0, 100, 1)
	_on_coins_changed(0)

# --- ОСНОВНОЙ ЦИКЛ ---
func _process(delta: float) -> void:
	elapsed_time += delta
	_update_wave_timer()

# --- ОБНОВЛЕНИЕ ЗДОРОВЬЯ ---
func _on_player_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
	health_label.text = "%d/%d ❤️" % [current, max_health]
	
	# Визуальный фидбек если мало HP
	if current < max_health * 0.25:
		health_bar.modulate = Color.RED
	elif current < max_health * 0.5:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.WHITE

# --- ОБНОВЛЕНИЕ ОПЫТА ---
func _on_exp_changed(current_exp: int, max_exp: int, level: int) -> void:
	exp_bar.max_value = max_exp
	exp_bar.value = current_exp
	exp_label.text = "%d/%d ⭐" % [current_exp, max_exp]
	level_label.text = "Уровень: %d" % level

# --- ОБНОВЛЕНИЕ МОНЕТ ---
func _on_coins_changed(coins: int) -> void:
	coins_label.text = "💰 %d" % coins

# --- ТАЙМЕР ВОЛ��Ы ---
func _update_wave_timer() -> void:
	var minutes: int = int(elapsed_time) / 60
	var seconds: int = int(elapsed_time) % 60
	wave_timer_label.text = "⏱️ %02d:%02d" % [minutes, seconds]

# --- ОТЛАДКА ---
func print_stats() -> void:
	if not player:
		return
	
	print("=== PLAYER STATS ===")
	print("HP: %d/%d" % [player.current_health, player.current_max_health])
	print("Speed: %.2f" % player.current_speed)
	print("Damage: %d" % player.current_damage)
	print("Fire Rate: %.2f" % player.current_fire_rate)
	print("Crit Chance: %.1f%%" % (player.current_crit_chance * 100))
	print("Projectile Range: %.2f" % player.current_projectile_range)
	print("Vision Range: %.2f" % player.current_vision_range)
	print("===================")
