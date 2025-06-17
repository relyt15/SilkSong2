extends Node

@onready var label = $CanvasLayer/CoinDisplay/CoinLabel

func _ready():
	add_to_group("UI")
	update_coin_count(GameData.collected_coins)

func update_coin_count(count: int):
	label.text = str(count)
