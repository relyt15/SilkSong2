extends Node

@onready var label = $CanvasLayer/CoinDisplay/CoinLabel
@onready var damage_label = $CanvasLayer/ItemDisplay/DamageCount
@onready var jump_label = $CanvasLayer/ItemDisplay/JumpCount

func _ready():
	add_to_group("UI")
	update_coin_count(GameData.collected_coins)
	update_damage_count(GameData.damage_items)
	update_jump_count(GameData.double_jump_items)

func update_coin_count(count: int):
	label.text = str(count)

func update_damage_count(count: int):
	damage_label.text = str(count) + "/3"

func update_jump_count(count: int):
	jump_label.text = str(count) + "/3"
