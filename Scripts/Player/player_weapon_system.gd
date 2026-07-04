# player_weapon_system.gd
# Система управления оружием и автоматической стрельбой
class_name PlayerWeaponSystem
extends Node

var current_weapon: Weapon
var player_movement: PlayerMovement

func _ready() -> void:
    player_movement = get_parent() as PlayerMovement
    if not player_movement:
        push_error("PlayerWeaponSystem parent must be PlayerMovement!")
    
    # Найти оружие в дочерних узлах
    current_weapon = get_tree().get_first_node_in_group("weapon")
    if not current_weapon:
        push_error("No weapon found in 'weapon' group!")

func _process(_delta: float) -> void:
    if not current_weapon or not player_movement:
        return
    
    # Автоматическая стрельба в ближайшего врага
    var nearest_enemy = player_movement.get_nearest_enemy()
    if nearest_enemy:
        var direction = (nearest_enemy.global_position - player_movement.global_position).normalized()
        current_weapon.fire(direction)

func change_weapon(new_weapon: Weapon) -> void:
    current_weapon = new_weapon
    print("Weapon changed to: ", new_weapon.name)

func apply_weapon_upgrade(upgrade_type: String, value: float) -> void:
    if current_weapon:
        current_weapon.apply_upgrade(upgrade_type, value)
        print("Weapon upgraded: ", upgrade_type, " x", value)
