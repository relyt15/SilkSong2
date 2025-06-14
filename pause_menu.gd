extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_quit_pressed():
	get_tree().quit()
