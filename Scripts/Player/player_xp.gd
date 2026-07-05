# player_xp.gd
# Система опыта и уровней
class_name PlayerXP
extends Node

var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100

signal xp_changed(current_xp, max_xp, current_level)
signal level_up(new_level)

func add_experience(amount: int) -> void:
    xp += amount
    
    # Проверка на повышение уровня
    while xp >= xp_to_next_level:
        xp -= xp_to_next_level
        level += 1
        xp_to_next_level += 50  # Увеличиваем сложность на 50 с каждым уровнем
        print("Уровень повышен! Новый уровень: ", level)
        level_up.emit(level)
    
    # Отправляем данные в интерфейс
    xp_changed.emit(xp, xp_to_next_level, level)

func reset() -> void:
    xp = 0
    level = 1
    xp_to_next_level = 100
