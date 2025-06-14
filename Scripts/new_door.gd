extends Area2D

#export(PackedScene) var target_scene
@export var target_scene: String

func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if target_scene == null: # is null
			print("no scene in this door")
			return
		if get_overlapping_bodies().size() > 0:
			next_level()

func next_level():
	var ERR = get_tree().change_scene_to_file(target_scene)
	
	if ERR != OK:
		print("something failed in the new_door scene")
