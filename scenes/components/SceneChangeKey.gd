extends Node2D

@export var NextScene : PackedScene
@export var ExitsGame = false

func _on_area_2d_body_entered(body):
	if body.has_method("receive_enemy_damage"):
		if ExitsGame:
			get_tree().quit()
		else:
			get_tree().change_scene_to_packed(NextScene)
