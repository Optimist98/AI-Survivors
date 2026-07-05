# player_health.gd
# Система здоровья игрока
class_name PlayerHealth
extends Node

@export var max_health: int = 100
var health: int

signal health_changed(current_health, max_health)
signal died

func _ready():
    health = max_health
    health_changed.emit(health, max_health)

func take_damage(damage: int):
    health -= damage
    health = max(health, 0)
    health_changed.emit(health, max_health)
    
    if health <= 0:
        die()

func heal(amount: int):
    health += amount
    health = min(health, max_health)
    health_changed.emit(health, max_health)

func die():
    print("Player died!")
    died.emit()
    # Можно добавить анимацию смерти здесь
