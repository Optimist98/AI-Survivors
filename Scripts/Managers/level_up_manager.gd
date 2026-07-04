# level_up_manager.gd
# Система выбора апгрейдов при повышении уровня
class_name LevelUpManager
extends CanvasLayer

@export var upgrade_ui_scene: PackedScene

var player_xp: PlayerXP
var player_movement: PlayerMovement
var is_level_up_active: bool = false

signal upgrade_selected(upgrade_type: String, value: float)

func _ready() -> void:
    player_xp = get_tree().get_first_node_in_group("player").get_node("PlayerXP")
    player_movement = get_tree().get_first_node_in_group("player")
    
    if player_xp:
        player_xp.level_up.connect(_on_level_up)

func _on_level_up(level: int) -> void:
    if is_level_up_active:
        return
    
    is_level_up_active = true
    show_upgrade_menu(level)

func show_upgrade_menu(level: int) -> void:
    # Генерируем 3 случайных апгрейда
    var upgrades = _generate_random_upgrades(3)
    
    # Паузим игру
    get_tree().paused = true
    
    # Создаем UI для выбора
    if upgrade_ui_scene:
        var ui = upgrade_ui_scene.instantiate()
        add_child(ui)
        ui.set_upgrades(upgrades)
        ui.upgrade_selected.connect(_on_upgrade_selected.bind(ui))

func _generate_random_upgrades(count: int) -> Array:
    var upgrade_types = ["damage", "fire_rate", "speed", "max_health"]
    var upgrades = []
    
    for i in range(count):
        var upgrade_type = upgrade_types[randi() % upgrade_types.size()]
        var value = randf_range(1.1, 1.5)  # От 10% до 50% бонус
        upgrades.append({"type": upgrade_type, "value": value})
    
    return upgrades

func _on_upgrade_selected(upgrade: Dictionary, ui: Node) -> void:
    # Применяем апгрейд
    upgrade_selected.emit(upgrade["type"], upgrade["value"])
    
    # Удаляем UI
    ui.queue_free()
    
    # Возобновляем игру
    get_tree().paused = false
    is_level_up_active = false
    
    print("Upgrade applied: ", upgrade["type"], " x", upgrade["value"])
