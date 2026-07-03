extends Node

var coins = 0
var strength = 0
var strength_cost = 5

const SAVE_PATH = "user://save.json"

func load_game():
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())

        coins = data["coins"]
        strength = data["strength"]
        strength_cost = data["strength_cost"]
        
func save_game():
    var data = {
        "coins": coins,
        "strength": strength,
        "strength_cost": strength_cost 
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
    
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
    
    
    
    
