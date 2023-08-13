extends HBoxContainer

@export var MaxHealth = 4;

var heart_full = preload("res://heart_atlas_texture.tres")
var heart_broken = preload("res://heart_empty_atlas_texture.tres")

func _ready():
	_on_player_body_health_lost(MaxHealth)

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
