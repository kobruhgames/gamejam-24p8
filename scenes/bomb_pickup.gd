extends Area2D

@export var number_of_bombs = 1

signal on_picked_up

func _on_area_entered(area):
	if area.has_method("add_bombs"):
		area.add_bombs(number_of_bombs)
		on_picked_up.emit()
		queue_free()
