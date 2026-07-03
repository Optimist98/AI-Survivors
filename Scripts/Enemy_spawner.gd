extends Timer

# Подключаем сцену врага (перетащи файл enemy.tscn из файловой системы прямо сюда в кавычки)
@export var enemy_scene: PackedScene 

func _ready():
    # Подключаем сигнал таймера к функции _on_timeout
    timeout.connect(_on_timeout)

func _on_timeout():
    spawn_enemy()

func spawn_enemy():
    var enemy = enemy_scene.instantiate()
    
    # Берем камеру игрока (предполагаем, что она у него есть)
    # Если камера одна на всю сцену, можно использовать get_viewport().get_camera_2d()
    var cam = get_viewport().get_camera_2d()
    if not cam: return # Если камеры нет, ничего не делаем
    
    # Центр камеры (видимая область)
    var cam_pos = cam.global_position
    var view_size = get_viewport().get_visible_rect().size / 2 # Половина экрана
    
    var spawn_pos = Vector2.ZERO
    var side = randi() % 4
    match side:
        0: # Верх
            spawn_pos = cam_pos + Vector2(randf_range(-view_size.x, view_size.x), -view_size.y - 100)
        1: # Низ
            spawn_pos = cam_pos + Vector2(randf_range(-view_size.x, view_size.x), view_size.y + 100)
        2: # Лево
            spawn_pos = cam_pos + Vector2(-view_size.x - 100, randf_range(-view_size.y, view_size.y))
        3: # Право
            spawn_pos = cam_pos + Vector2(view_size.x + 100, randf_range(-view_size.y, view_size.y))
    
    # Задаем границы карты (замени на реальные размеры твоей арены)
    var map_left = 20
    var map_right = 2980
    var map_top = 20
    var map_bottom = 2980
    
    # "Зажимаем" позицию спавна в пределах этих границ
    spawn_pos.x = clamp(spawn_pos.x, map_left, map_right)
    spawn_pos.y = clamp(spawn_pos.y, map_top, map_bottom)
    
    get_tree().current_scene.add_child(enemy)
    enemy.global_position = spawn_pos
