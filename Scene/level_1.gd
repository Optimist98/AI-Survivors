extends Node2D

@onready var hp_bar = $UI/HPBar
# Called when the node enters the scene tree for the first time.
func _ready():
    hp_bar.max_value = Global.max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    hp_bar.value = Global.hp
