extends Node

var coins = 0

var strength = 0
var strength_cost = 5

var speed = 200
var speed_cost = 5

var luck = 0
var luck_cost = 5

var max_hp = 100
var max_hp_cost = 10
var hp = 100



var regeneration := 5
var regeneration_cost = 10

var regen_timer := 0.0


func _process(delta):
    if hp <= 0:
        return
    regen_timer += delta
    if regen_timer >= 0.25:
        regen_timer = 0
        hp += regeneration
        hp = min(hp, max_hp)

func take_damage(amount):
    hp -= amount
    hp = max(hp, 0)

    if hp <= 0:
        die()

func reset_player():
    hp = max_hp
    regen_timer = 0
    
func die():
    reset_player()
    get_tree().reload_current_scene()
    
        
const SAVE_PATH = "user://save.json"

func load_game():
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())

        coins = data.get("coins", 0)

        strength = data.get("strength", 0)
        strength_cost = data.get("strength_cost", 5)

        speed = data.get("speed", 200)
        speed_cost = data.get("speed_cost", 5)

        luck = data.get("luck", 0)
        luck_cost = data.get("luck_cost", 5)

        max_hp = data.get("max_hp", 100)
        max_hp_cost = data.get("max_hp_cost", 10)

        regeneration = data.get("regeneration", 0)
        regeneration_cost = data.get("regeneration_cost", 10)
        
func save_game():
    var data = {
        "coins": coins,
        "strength": strength,
        "strength_cost": strength_cost, 
        "speed": speed,
        "speed_cost": speed_cost,
        "luck": luck,
        "luck_cost": luck_cost,
        "max_hp": max_hp,
        "max_hp_cost": max_hp_cost,
        "regeneration": regeneration,
        "regeneration_cost": regeneration_cost,
    }
    print("SAVING:", coins, strength, strength_cost)

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    
func _ready():
    print("LOADING GAME")
    load_game()  

func upgrade_strength():
    if coins >= strength_cost:
        coins -= strength_cost
        strength += 1
        strength_cost += 5
        return true
    return false
    
func upgrade_speed():
    if coins >= speed_cost:
        coins -= speed_cost
        speed += 10
        speed_cost += 5
        return true
    return false
    
func upgrade_regeneration():
    if coins >= regeneration_cost:
        coins -= regeneration_cost
        regeneration += 1
        regeneration_cost += 10
        return true
    return false
    
func upgrade_luck():
    if coins >= luck_cost:
        coins -= luck_cost
        luck += 1
        luck_cost += 5
        return true
    return false
    
func upgrade_max_hp():
    if coins >= max_hp_cost:
        coins -= max_hp_cost
        max_hp += 10
        hp = max_hp
        max_hp_cost += 10
        return true
    return false
    
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
   
    
