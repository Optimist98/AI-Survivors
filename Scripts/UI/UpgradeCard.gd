extends PanelContainer
class_name UpgradeCard

# === СИГНАЛЫ ===
signal upgrade_selected(upgrade_id: String)

# === УЗЛЫ ===
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var icon_texture: TextureRect = $VBoxContainer/IconTexture
@onready var button: Button = $VBoxContainer/SelectButton

# === СОСТОЯНИЕ ===
var upgrade_data: Dictionary = {}

# --- ИНИЦИАЛИЗАЦИЯ ---
func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func setup(data: Dictionary) -> void:
	upgrade_data = data
	
	name_label.text = data.get("name", "Неизвестно")
	description_label.text = data.get("description", "")
	
	if data.has("icon"):
		icon_texture.texture = data["icon"]
	
	button.text = "Выбрать"

# --- ОБРАБОТЧИК КЛИКА ---
func _on_button_pressed() -> void:
	upgrade_selected.emit(upgrade_data.get("id", ""))
	
	# Визуальный фидбек
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
