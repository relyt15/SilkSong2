extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player":
		body.add_damage_item()
		queue_free()
		
