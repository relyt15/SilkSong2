extends Control

#Link containers with new variables
@onready var play_button = $ButtonControlContainer/VBoxContainer/Play
@onready var exit_button = $ButtonControlContainer/VBoxContainer/Quit

func _ready():
	#Connect variables with actions/functions
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Replace the scene link with next game scene
	get_tree().change_scene_to_file("res://scenes/starting_room.tscn")

func _on_exit_pressed():
	get_tree().quit()
