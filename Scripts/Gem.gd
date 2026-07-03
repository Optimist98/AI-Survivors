extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_body_entered(body):
    # Если body - это Hitbox, а не сам Player,
    # мы попробуем найти родителя, который является игроком
    var player = body if body.is_in_group("player") else body.get_parent()

    if player and player.is_in_group("player"):
        player.add_experience(10)
        queue_free()
