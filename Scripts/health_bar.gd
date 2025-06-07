extends TextureProgressBar

@export var player: NodePath

func _ready():
	var player_node = get_node(player)
	if player_node and player_node.has_signal("healthChange"):
		player_node.healthChange.connect(_on_health_changed)
		# Set initial value
		max_value = player_node.max_health
		value = player_node.health

func _on_health_changed():
	var player_node = get_node(player)
	value = player_node.health
