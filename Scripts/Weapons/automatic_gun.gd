# automatic_gun.gd
# Автоматическое оружие с пулями
class_name AutomaticGun
extends Weapon

@export var bullet_scene: PackedScene

func _ready() -> void:
    super._ready()
    if not bullet_scene:
        push_error("Bullet scene not assigned in AutomaticGun!")

func _do_fire(direction: Vector2) -> void:
    if not bullet_scene:
        return
    
    var bullet = bullet_scene.instantiate()
    bullet.global_position = player.global_position
    bullet.direction = direction
    bullet.speed = bullet_speed
    bullet.damage = damage
    
    get_tree().current_scene.add_child(bullet)
