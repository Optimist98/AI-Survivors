extends Control
class_name UpgradePanel

# === УЗЛЫ ===
@onready var upgrade_card_scene: PackedScene = preload("res://Scene/UpgradeCard.tscn")
@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var coins_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CoinsLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/LevelLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# === СОСТОЯНИЕ ===
var upgrade_options: Array = []

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	# Подписываемся на события
	ProgressionManager.level_up_available.connect(_on_level_up_available)
	ProgressionManager.coins_changed.connect(_update_coins_display)
	
	# Начально скрыт
	visible = false

# --- ОБРАБОТКА СОБЫТИЯ УРОВНЯ ---
func _on_level_up_available(options: Array) -> void:
	upgrade_options = options
	show()
	_populate_upgrades()

func _populate_upgrades() -> void:
	# Очищаем старые карточки
	for child in grid.get_children():
		child.queue_free()
	
	# Создаём новые карточки апгрейдов
	for upgrade in upgrade_options:
		var card = upgrade_card_scene.instantiate()
		card.setup(upgrade)
		card.upgrade_selected.connect(_on_upgrade_selected)
		grid.add_child(card)

func _on_upgrade_selected(upgrade_id: String) -> void:
	# Применяем апгрейд
	PlayerUpgradeBus.apply_upgrade.emit(upgrade_id)
	
	# Закрываем панель и возобновляем игру
	get_tree().paused = false
	visible = false

# --- UI ОБНОВЛЕНИЯ ---
func _update_coins_display(coins: int) -> void:
	coins_label.text = "💰 " + str(coins)

func _on_level_changed(level: int) -> void:
	level_label.text = "⬆ Уровень: " + str(level)

# --- ИНПУТ ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		get_tree().paused = false
		visible = false
		get_tree().root.set_input_as_handled()
