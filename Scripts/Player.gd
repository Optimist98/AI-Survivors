extends CharacterBody2D

@export var speed: float = 150.0

var directions = [
 Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
 Vector2.UP + Vector2.LEFT, Vector2.UP + Vector2.RIGHT,
 Vector2.DOWN + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT
]

var danger = [0, 0, 0, 0, 0, 0, 0, 0]
var interest = [0, 0, 0, 0, 0, 0, 0, 0]

@onready var radar = $Radar

func _ready():
 for i in range(directions.size()):
  directions[i] = directions[i].normalized()

func _physics_process(_delta):
 get_danger_weights()
 get_interest_weights()
 
 var chosen_direction = Vector2.ZERO
 for i in range(directions.size()):
  var result_weight = interest[i] - danger[i]
  chosen_direction += directions[i] * result_weight
 
 if chosen_direction != Vector2.ZERO:
  velocity = chosen_direction.normalized() * speed
 else:
  velocity = Vector2.ZERO
  
 move_and_slide()

func get_danger_weights():
 danger = [0, 0, 0, 0, 0, 0, 0, 0]
 var overlapping_bodies = radar.get_overlapping_bodies()
 
 for body in overlapping_bodies:
  if body.is_in_group("enemies"): 
   var direction_to_enemy = (body.global_position - global_position).normalized()
   var distance = global_position.distance_to(body.global_position)
   var panic_factor = 1.0 - (distance / 300.0) 
   panic_factor = clamp(panic_factor, 0.0, 1.0)

   for i in range(directions.size()):
    var dot = directions[i].dot(direction_to_enemy)
    if dot > 0: 
     danger[i] = max(danger[i], dot * panic_factor)

func get_interest_weights():
 interest = [0, 0, 0, 0, 0, 0, 0, 0]
 
 var center_of_map = Vector2(576, 324) 
 var direction_to_center = (center_of_map - global_position).normalized()
 
 for i in range(directions.size()):
  var dot = directions[i].dot(direction_to_center)
  if dot > 0:
   interest[i] = dot * 1.0

@export var bullet_scene: PackedScene  # 👈 ВОТ ЭТО ОБЯЗАТЕЛЬНО

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        shoot()

func shoot():
    var bullet = bullet_scene.instantiate()
    bullet.global_position = global_position
    get_tree().current_scene.add_child(bullet)
    print("shoot")
