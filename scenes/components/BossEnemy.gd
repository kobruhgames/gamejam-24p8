extends Node2D

func _on_health_health_reached_zero():
	queue_free()
