extends CharacterBody2D

var speed = 80.0
var player = null

func _physics_process(_delta):
    if not player:
        player = get_tree().get_first_node_in_group("player")
    
    if player:
        velocity = (player.global_position - global_position).normalized() * speed
        move_and_slide()
