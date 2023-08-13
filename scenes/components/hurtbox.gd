extends Area2D

@export var damage_dealt = 1

func _on_timeout():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(damage_dealt)
