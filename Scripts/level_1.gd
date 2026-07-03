extends Node2D

@onready var hp_bar = $UI/HPBar

func _ready():
    hp_bar.max_value = Global.max_hp
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.xp_changed.connect(_on_player_xp_changed)

    update_ui(0, 100, 1)

func update_ui(xp, max_xp, level):
    $UI/XpBar.max_value = max_xp
    $UI/XpBar.value = xp
    $UI/LevelLabel.text = "Уровень: " + str(level)

func _on_player_xp_changed(current_xp, max_xp, current_level):
    update_ui(current_xp, max_xp, current_level)

func _process(_delta):
    hp_bar.value = Global.hp
