extends Node
## Сигнальный мост для врагов (декаплинг)
## Добавить в Autoload как "EnemySignalBus"

signal enemy_died(enemy: Node2D, death_position: Vector2)
signal enemy_spawned(enemy: Node2D)
