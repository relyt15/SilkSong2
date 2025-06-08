extends Node

@onready var label = $CanvasLayer/CoinDisplay/CoinLabel

func _ready():
	add_to_group("UI")

func update_coin_count(count: int):
	label.text = str(count)
