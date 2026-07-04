extends CharacterBody2D

var xp = 0
var level = 1
var xp_to_next_level = 100 # Сколько нужно опыта для повышения

@export var speed: float = 150.0

signal xp_changed(new_xp) # Объявляем сигнал

func add_experience(amount):
    xp += amount
    # Проверка на повышение уровня
    while xp >= xp_to_next_level:
        xp -= xp_to_next_level
        level += 1
        xp_to_next_level += 50 # Увеличиваем сложность на 50 с каждым уровнем
        print("Уровень повышен! Новый уровень: ", level)
    
    # Отправляем данные в интерфейс (текущий опыт, макс опыт, уровень)
    xp_changed.emit(xp, xp_to_next_level, level)
    
var directions = [
 Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
 Vector2.UP + Vector2.LEFT, Vector2.UP + Vector2.RIGHT,
 Vector2.DOWN + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT
]

var danger = [0, 0, 0, 0, 0, 0, 0, 0]
var interest = [0, 0, 0, 0, 0, 0, 0, 0]

@onready var radar = $Radar
@onready var enemy_radar = $EnemyRadar

func _ready():
    speed = Global.speed
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
    var gems = get_tree().get_nodes_in_group("gems")
    
    if gems.size() > 0:
        var closest_gem = null
        var min_dist = 999999
        for g in gems:
            var dist = global_position.distance_to(g.global_position)
            if dist < min_dist:
                min_dist = dist
                closest_gem = g
        
        if closest_gem:
            var dir_to_gem = (closest_gem.global_position - global_position).normalized()
            for i in range(directions.size()):
                var dot = directions[i].dot(dir_to_gem)
                if dot > 0:
                    interest[i] = dot * 1.5

@export var bullet_scene: PackedScene  # 👈 ВОТ ЭТО ОБЯЗАТЕЛЬНО
#Стрельба
var enemies: Array = []
@export var bullet: PackedScene
@export var shoot_interval := 0.5

var can_shoot := true

func _process(delta):
    if Global.hp < Global.max_hp:
        Global.hp += Global.regeneration * delta
        Global.hp = min(Global.hp, Global.max_hp)
    auto_shoot()
    #автострельба
func auto_shoot():
    if !can_shoot:
        return

    var enemy = get_nearest_enemy()
    if enemy == null:
        return

    shoot(enemy)

    can_shoot = false
    await get_tree().create_timer(shoot_interval).timeout
    can_shoot = true
    #Выстрел
func shoot(enemy):
    var bullet = bullet_scene.instantiate()

    bullet.global_position = global_position

    var dir = (enemy.global_position - global_position).normalized()
    bullet.direction = dir

    get_tree().current_scene.add_child(bullet)

#Радар противников
func _on_enemy_radar_body_entered(body):
    if body.is_in_group("enemies"):
        enemies.append(body)

func _on_enemy_radar_body_exited(body):
    enemies.erase(body)
    
    #Поиск ближайшего в радаре противника
func get_nearest_enemy():
    var nearest = null
    var min_dist = INF

    for body in enemy_radar.get_overlapping_bodies():
        if body.is_in_group("enemies"):
            var dist = global_position.distance_to(body.global_position)
            if dist < min_dist:
                min_dist = dist
                nearest = body

    return nearest
    
    
