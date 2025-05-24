extends Area2D

@export var item_name: String = "Collectable"

func _ready():
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(body):
	if body.name == "Player":
		queue_free()
