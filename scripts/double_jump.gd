extends Area2D

@export var item_name: String = "double_jump_item"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		body.add_jump_item()
		animation_player.play("doublejumppickup")
		#queue_free()
		
