# upgrade_ui.gd
# UI для выбора апгрейдов
class_name UpgradeUI
extends Control

signal upgrade_selected(upgrade: Dictionary)

var upgrades: Array = []

@onready var container = VBoxContainer.new()

func _ready() -> void:
    # Создаем основной контейнер
    add_child(container)
    container.anchor_left = 0.5
    container.anchor_top = 0.5
    container.anchor_right = 0.5
    container.anchor_bottom = 0.5
    container.offset_left = -150
    container.offset_top = -100
    container.custom_minimum_size = Vector2(300, 200)
    
    # Добавляем заголовок
    var title = Label.new()
    title.text = "⭐ ВЫБЕРИТЕ АПГРЕЙД ⭐"
    title.add_theme_font_size_override("font_size", 24)
    container.add_child(title)

func set_upgrades(new_upgrades: Array) -> void:
    upgrades = new_upgrades
    
    # Создаем кнопки для каждого апгрейда
    for upgrade in upgrades:
        var button = Button.new()
        var upgrade_name = upgrade["type"].to_upper()
        var upgrade_bonus = int(upgrade["value"] * 100 - 100)
        button.text = "%s +%d%%" % [upgrade_name, upgrade_bonus]
        button.custom_minimum_size = Vector2(250, 50)
        button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade))
        container.add_child(button)

func _on_upgrade_button_pressed(upgrade: Dictionary) -> void:
    upgrade_selected.emit(upgrade)
