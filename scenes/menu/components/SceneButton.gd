extends Button

@export var NextScene : PackedScene
@export var ExitsGame = false

func _on_pressed():
	if ExitsGame:
		get_tree().quit()
	else:
		get_tree().change_scene_to_packed(NextScene)
