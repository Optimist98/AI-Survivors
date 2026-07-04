extends CharacterBody2D

# Скрипт врага (Enemy.gd)
var speed = 80.0
@onready var player = get_tree().get_first_node_in_group("player") # Не забудь добавить игрока в группу "player"
@onready var health_bar = $ProgressBar
@onready var sprite = $Polygon2D
@export var gem_scene: PackedScene = preload("res://Scene/Gem.tscn")

var can_damage = true
var knockback_velocity := Vector2.ZERO

func hit_flash():
    sprite.modulate = Color(1, 0.3, 0.3)  # красный оттенок
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color(1, 1, 1)

func _physics_process(_delta):
    if player:
        var dir = (player.global_position - global_position).normalized() * speed
        velocity = dir + knockback_velocity
        move_and_slide()
        knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * _delta)

@export var max_health := 100
var health := 100

func _ready():
    add_to_group("enemies")
    health = max_health
    health_bar.max_value = max_health
    health_bar.value = health
    health_bar.visible = false

func take_damage(damage: int):
    hit_flash()
    health -= damage
    if health <= 0:
        die()
        return
    var dir = (global_position - get_tree().get_first_node_in_group("player").global_position).normalized()
    knockback_velocity += dir * 150
    health_bar.visible = true
    health_bar.value = health

func die():
    if gem_scene:
        call_deferred("spawn_gem")
    call_deferred("queue_free")

func spawn_gem():
    var gem = gem_scene.instantiate()
    get_parent().add_child(gem)
    gem.global_position = global_position

func _on_area_2d_body_entered(body):
    if body.is_in_group("player"):
        Global.take_damage(10)
