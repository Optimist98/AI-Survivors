extends CharacterBody2D

# Скрипт врага (Enemy.gd)
var speed = 80.0
@onready var player = get_tree().get_first_node_in_group("player") # Не забудь добавить игрока в группу "player"

func _physics_process(_delta):
    if player:
        velocity = (player.global_position - global_position).normalized() * speed
        move_and_slide()
