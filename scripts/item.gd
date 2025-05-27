extends Area2D

@export var item_name: String = "double_jump_item"

func _ready():
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(body):
	if body.name == "Player":
		body.collected_item_count += 1
		if body.collected_item_count >= 3 and !body.can_double_jump:
			body.can_double_jump = true
		queue_free()
