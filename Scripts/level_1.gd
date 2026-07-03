extends Node2D

func _ready():
    # Находим игрока и подписываемся на его сигнал
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.xp_changed.connect(_on_player_xp_changed)
        
    # ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ ПРИ СТАРТЕ
    # Передаем начальные значения (0 опыта, 100 для след. уровня, 1 уровень)
    update_ui(0, 100, 1)
    

func update_ui(xp, max_xp, level):
    $UI/ProgressBar.max_value = max_xp
    $UI/ProgressBar.value = xp
    $UI/LevelLabel.text = "Уровень: " + str(level)

func _on_player_xp_changed(current_xp, max_xp, current_level):
    # Обновляем прогресс-бар
    $UI/ProgressBar.max_value = max_xp
    $UI/ProgressBar.value = current_xp
    
    # Обновляем текст уровня
    $UI/LevelLabel.text = "Уровень: " + str(current_level)
    update_ui(current_xp, max_xp, current_level)
