extends Control

#Link containers with new variables
@onready var play_button = $CenterContainer/VBoxContainer/ButtonControlContainer/VBoxContainer/Play
@onready var exit_button = $CenterContainer/VBoxContainer/ButtonControlContainer/VBoxContainer/Quit

func _ready():
	#Connect variables with actions/functions
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	GameData.collected_coins = 0
	GameData.double_jump_items = 0
	GameData.damage_items = 0
	GameData.can_double_jump = false
	get_tree().change_scene_to_file("res://scenes/starting_room.tscn")

func _on_exit_pressed():
	get_tree().quit()
