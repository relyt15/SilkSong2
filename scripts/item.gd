extends Area2D

@export var item_name: String = "double_jump_item"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		# no implementation to this variable
		body.collected_coin_count += 1
		# this function does not exist in the player API
		body.add_coin()
		queue_free()
