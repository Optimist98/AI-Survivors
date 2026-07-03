extends CharacterBody2D

# Скрипт врага (Enemy.gd)
var speed = 80.0
@onready var player = get_tree().get_first_node_in_group("player") # Не забудь добавить игрока в группу "player"

func _physics_process(_delta):
    if player:
        velocity = (player.global_position - global_position).normalized() * speed
        move_and_slide()

@export var max_health := 100
var health := 100

func _ready():
    add_to_group("enemies")
    health = max_health
    
func take_damage(damage: int):
    health -= damage
    print("HP:", health)

    if health <= 0:
        die()

func die():
    queue_free()
