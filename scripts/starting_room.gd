extends Node2D

@onready var pause_menu = $UIController/CanvasLayer/VBoxContainer/PauseMenu

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	pause_menu.visible = !is_paused
