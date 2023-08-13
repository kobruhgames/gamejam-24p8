extends Area2D

@export var number_of_hearts = 2

signal on_picked_up

func _on_area_entered(area):
	if area.has_method("add_health"):
		area.add_health(number_of_hearts)
		on_picked_up.emit()
		queue_free()
