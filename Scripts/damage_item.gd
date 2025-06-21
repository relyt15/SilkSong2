extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player":
		body.add_damage_item()
		animation_player.play("pickupDamageItem")
		#queue_free()
		
