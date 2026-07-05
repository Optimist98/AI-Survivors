extends Node
## Глобальная шина сигналов для апгрейдов
## Добавить в Autoload как "PlayerUpgradeBus"

# === СИГНАЛЫ ===
signal apply_upgrade(upgrade_id: String)
signal upgrade_applied(upgrade_id: String, new_value: float)
