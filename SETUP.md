# SETUP.md
# Инструкция по настройке сцены Player

## 📋 Требуемая структура сцены:

```
Player (CharacterBody2D) - Scripts/player.gd
├── PlayerMovement (CharacterBody2D) - Scripts/Player/player_movement.gd
│   ├── Radar (Area2D) - для поиска врагов и предметов
│   └── EnemyRadar (Area2D) - для поиска врагов для стрельбы
├── PlayerXP (Node) - Scripts/Player/player_xp.gd
├── PlayerHealth (Node) - Scripts/Player/player_health.gd
├── PlayerWeaponSystem (Node) - Scripts/Player/player_weapon_system.gd
│   └── Weapon (Node2D) - наследует Weapon базовый класс
│       └── AutomaticGun - Scripts/Weapons/automatic_gun.gd
└── [Визуальные компоненты: Sprite2D, CollisionShape2D и т.д.]
```

## 🔧 Шаги настройки:

### 1. Обновить главный скрипт Player
- Присвой скрипт `Scripts/player.gd` узлу Player (главному)

### 2. Добавить компоненты
- Создай узел PlayerMovement с скриптом `Scripts/Player/player_movement.gd`
- Создай узел PlayerXP с скриптом `Scripts/Player/player_xp.gd`
- Создай узел PlayerHealth с скриптом `Scripts/Player/player_health.gd`
- Создай узел PlayerWeaponSystem с скриптом `Scripts/Player/player_weapon_system.gd`

### 3. Настроить оружие
- Создай узел Weapon под PlayerWeaponSystem
- Присвой скрипт `Scripts/Weapons/automatic_gun.gd`
- Подключи сцену пули в переменную `bullet_scene`
- Добавь в группу "weapon"

### 4. Добавить LevelUpManager
- Создай CanvasLayer узел с именем LevelUpManager
- Присвой скрипт `Scripts/Managers/level_up_manager.gd`
- В поле upgrade_ui_scene подключи сцену UI (upgrade_ui.gd)

## ✅ Проверка:
- Игрок движется избегая врагов ✓
- Игрок стреляет по врагам ✓
- При получении урона HP уменьшается ✓
- При повышении уровня появляется меню выбора апгрейдов ✓

## 🚀 Сигналы для подключения:

### PlayerHealth
- `health_changed(current, max)` - при изменении HP
- `died()` - при смерти

### PlayerXP
- `xp_changed(current, max, level)` - при получении опыта
- `level_up(level)` - при повышении уровня

### PlayerWeaponSystem
- `weapon.fired()` - при выстреле

## 💡 Использование в коде:

```gdscript
# Взять урон
var player = get_tree().get_first_node_in_group("player")
player.take_damage(10)

# Получить опыт
player.add_experience(50)

# Применить апгрейд
player.apply_upgrade("damage", 1.5)  # +50% урона
```
