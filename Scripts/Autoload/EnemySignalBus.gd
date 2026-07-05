extends Node
## Глобальная шина сигналов для врагов
## Добавить в Autoload как "EnemySignalBus"

# === СИГНАЛЫ ===
signal enemy_died(enemy: Node2D, position: Vector2)
signal enemy_spawned(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, damage: int)
