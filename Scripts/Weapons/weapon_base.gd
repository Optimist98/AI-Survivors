# weapon_base.gd
# Базовый класс для всех типов оружия
class_name Weapon
extends Node2D

## Сигналы
signal ammo_changed(current, max)
signal fired

## Экспортируемые параметры
@export var damage: float = 25.0
@export var fire_rate: float = 0.5  # время между выстрелами в секундах
@export var bullet_speed: float = 600.0

## Внутренние переменные
var can_fire: bool = true
var player: CharacterBody2D
var bullet_scene: PackedScene

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
    if not player:
        push_error("Player not found in 'player' group!")

## Главный метод для стрельбы
func fire(direction: Vector2) -> void:
    if not can_fire or not player:
        return
    
    _do_fire(direction)
    
    can_fire = false
    await get_tree().create_timer(fire_rate).timeout
    can_fire = true
    fired.emit()

## Переопределяется в наследниках
func _do_fire(direction: Vector2) -> void:
    push_error("_do_fire not implemented in", self.name)

## Применить апгрейд во время забега
func apply_upgrade(upgrade_type: String, value: float) -> void:
    match upgrade_type:
        "damage":
            damage *= value
        "fire_rate":
            fire_rate *= value
        "speed":
            bullet_speed *= value
