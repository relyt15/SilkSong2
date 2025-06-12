extends TextureProgressBar

# CHECK IF WORKS IN OTHER ROOMS OR NEEDS TO BE INSTANTIATED EACH ROOM

@export var player_path: NodePath  # Set in the inspector

func _ready():
	var player_node = get_node(player_path)
	if player_node and player_node.has_signal("HealthChanged"):
		player_node.HealthChanged.connect(_on_health_changed)
		max_value = player_node.max_health
		value = player_node.health

func _on_health_changed():
	var player_node = get_node(player_path)
	value = player_node.health
