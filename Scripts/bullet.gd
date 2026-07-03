extends Area2D

@export var speed := 600.0
var direction := Vector2.RIGHT

func _process(delta):
    position += direction * speed * delta
