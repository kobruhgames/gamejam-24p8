extends HBoxContainer

@export var MaxHealth = 3;

var heart_full = preload("res://heart.png")
var heart_broken = preload("res://heart_broken.png")

func _on_player_body_health_lost(new_health):
	for child in get_children():
		remove_child(child)
	for i in range(MaxHealth):
		var heart = TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		if i < new_health:
			heart.texture = heart_full
		else:
			heart.texture = heart_broken
		add_child(heart)
