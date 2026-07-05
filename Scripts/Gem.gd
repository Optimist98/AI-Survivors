extends Area2D
class_name Gem

# === ПАРАМЕТРЫ ===
@export var gem_type: String = "xp"  # "xp" или "coin"
@export var value: int = 10
@export var magnet_range: float = 100.0
@export var magnet_speed: float = 300.0

# === СОСТОЯНИЕ ===
var is_attracted: bool = false
var player: Node2D = null

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	add_to_group("gems")
	body_entered.connect(_on_body_entered)
	
	# Автоматически находим игрока для магнита
	player = get_tree().get_first_node_in_group("player")

# --- МАГНИТ ЛУТА ---
func _process(delta: float) -> void:
	if not player:
		return
	
	var distance_to_player: float = global_position.distance_to(player.global_position)
	
	# Если в пределах магнита или уже притягиваемся
	if distance_to_player < magnet_range or is_attracted:
		is_attracted = true
		var direction: Vector2 = (player.global_position - global_position).normalized()
		global_position += direction * magnet_speed * delta
		
		# Если достигли игрока - подбираем
		if distance_to_player < 20.0:
			collect()

# --- СБОР ЛУТА ---
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect()

func collect() -> void:
	match gem_type:
		"xp":
			ProgressionManager.add_exp(value)
		"coin":
			ProgressionManager.add_coins(value)
	
	queue_free()
