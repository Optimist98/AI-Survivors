extends Node
## Сигнальный мост для апгрейдов игрока
## Добавить в Autoload как "PlayerUpgradeBus"

signal apply_upgrade(upgrade_id: String)
signal upgrade_applied(upgrade_id: String)
