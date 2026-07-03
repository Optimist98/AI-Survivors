extends Area2D

@export var speed := 600.0
var direction := Vector2.RIGHT

func _process(delta):
    position += direction * speed * delta

@export var damage := 25
var crit_multiplier := 2.0



func _on_body_entered(body):
    if body.is_in_group("enemies"):

        var crit_chance = 1 - pow(0.95, Global.luck) #Забалансено
        var is_crit = randf() < crit_chance

        var final_damage = damage * (1.0 + Global.strength * 0.2)

        if is_crit:
            final_damage *= crit_multiplier
            print("CRIT!")

        body.take_damage(final_damage)
        queue_free()
        
    
