# player.gd
# Главный скрипт игрока - объединяет все компоненты
extends CharacterBody2D

@onready var player_xp = $PlayerXP
@onready var player_health = $PlayerHealth
@onready var player_weapon_system = $PlayerWeaponSystem
@onready var radar = $Radar
@onready var enemy_radar = $EnemyRadar

func _ready():
    add_to_group("player")
    
    # Проверяем все компоненты подключены
    if not player_xp:
        push_error("PlayerXP component not found!")
    if not player_health:
        push_error("PlayerHealth component not found!")
    if not player_weapon_system:
        push_error("PlayerWeaponSystem component not found!")
    
    # Подключаем сигналы
    if player_health:
        player_health.health_changed.connect(_on_health_changed)
        player_health.died.connect(_on_player_died)
    
    if player_xp:
        player_xp.xp_changed.connect(_on_xp_changed)
        player_xp.level_up.connect(_on_level_up)

func take_damage(damage: int):
    if player_health:
        player_health.take_damage(damage)

func add_experience(amount: int):
    if player_xp:
        player_xp.add_experience(amount)

func apply_upgrade(upgrade_type: String, value: float):
    match upgrade_type:
        "damage":
            if player_weapon_system and player_weapon_system.current_weapon:
                player_weapon_system.current_weapon.apply_upgrade("damage", value)
        "fire_rate":
            if player_weapon_system and player_weapon_system.current_weapon:
                player_weapon_system.current_weapon.apply_upgrade("fire_rate", value)
        "speed":
            # Увеличиваем скорость движения
            if has_node("PlayerMovement"):
                var movement = get_node("PlayerMovement")
                movement.speed *= value
        "max_health":
            if player_health:
                player_health.max_health *= value
                player_health.health = player_health.max_health

func _on_health_changed(current_health, max_health):
    print("Player HP: ", current_health, "/", max_health)

func _on_player_died():
    print("Player died!")
    # Здесь можно добавить game over экран

func _on_xp_changed(current_xp, max_xp, level):
    print("XP: ", current_xp, "/", max_xp, " Level: ", level)

func _on_level_up(level):
    print("LEVEL UP! New level: ", level)
