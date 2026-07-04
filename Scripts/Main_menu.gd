extends Control

@onready var coins_label = $CoinsLabel
@onready var start_button = $StartButton
@onready var skills_button = $SkillsButton



func _ready():
    update_coins()

func update_coins():
    coins_label.text = "Монеты: " + str(Global.coins)


func _on_start_button_pressed():
    get_tree().change_scene_to_file("res://Scene/Level1.tscn")


func _on_skills_button_pressed():
    get_tree().change_scene_to_file("res://Scene/Skill_Tree.tscn")

func _on_coin_button_pressed() -> void:
    Global.coins += 1
    update_coins()
