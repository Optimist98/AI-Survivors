extends Control

@onready var strength_label = $StrengthLabel
@onready var cost_label = $CostLabel

func _ready():
    update_ui()

func update_ui():
    strength_label.text = "Strength: " + str(Global.strength)
    cost_label.text = "Cost: " + str(Global.strength_cost) + " coins"


func _on_upgrade_button_pressed():
    if Global.upgrade_strength():
        update_ui()


func _on_apply_button_pressed():
    print("Strength applied:", Global.strength)

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://Scene/Main_Menu.tscn")
