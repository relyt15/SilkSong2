extends Area2D

@export var item_name: String = "double_jump_item"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		# no implementation to this variable
		body.collected_item_count += 1
		# this function does not exist in the player API
		body.update_coin_label()
		animation_player.play("pickup")
