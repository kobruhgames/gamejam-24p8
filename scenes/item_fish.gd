extends Node2D

func _on_area_health_on_picked_up():
	queue_free()
