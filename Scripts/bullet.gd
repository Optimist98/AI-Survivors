extends Area2D

@export var speed := 600.0
var direction := Vector2.RIGHT

func _process(delta):
    position += direction * speed * delta

@export var damage := 25

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        body.take_damage(damage)
        queue_free()
