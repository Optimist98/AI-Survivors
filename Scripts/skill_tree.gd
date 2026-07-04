extends Control

@onready var strength_label = $StrengthLabel
@onready var strength_cost_label = $StrengthCostLabel

@onready var speed_label = $SpeedLabel
@onready var speed_cost_label = $SpeedCostLabel

@onready var luck_label = $LuckLabel
@onready var luck_cost_label = $LuckCostLabel

@onready var max_hp_label = $MaxHpLabel
@onready var max_hp_cost_label = $MaxHpCostLabel

@onready var regen_label = $RegenLabel
@onready var regen_cost_label = $RegenCostLabel

func _ready():
    update_ui()

func update_ui():
    strength_label.text = "Strength: " + str(Global.strength)
    strength_cost_label.text = "Cost: " + str(Global.strength_cost)

    speed_label.text = "Speed: " + str(Global.speed)
    speed_cost_label.text = "Cost: " + str(Global.speed_cost)

    luck_label.text = "Luck: " + str(Global.luck)
    luck_cost_label.text = "Cost: " + str(Global.luck_cost)

    max_hp_label.text = "Max HP: " + str(Global.max_hp)
    max_hp_cost_label.text = "Cost: " + str(Global.max_hp_cost)

    regen_label.text = "Regeneration: " + str(Global.regeneration)
    regen_cost_label.text = "Cost: " + str(Global.regeneration_cost)


func _on_upgrade_button_pressed():
    if Global.upgrade_strength():
        update_ui()

func _on_apply_button_pressed():
    print("Strength applied:", Global.strength)

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://Scene/Main_Menu.tscn")


func _on_speed_button_pressed() -> void:
    if Global.upgrade_speed():
        update_ui()


func _on_luck_button_pressed() -> void:
    if Global.upgrade_luck():
        update_ui()


func _on_regen_button_pressed() -> void:
    if Global.upgrade_regeneration():
        update_ui()


func _on_max_hp_button_pressed() -> void:
   if Global.upgrade_max_hp():
        update_ui()
