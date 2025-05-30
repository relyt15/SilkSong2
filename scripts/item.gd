extends Area2D

@export var item_name: String = "double_jump_item"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		queue_free()
