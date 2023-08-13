extends Node2D

signal health_changed
signal health_reached_zero

@export var max_health = 4
@export var current_health = 4

func _ready():
	assert(current_health <= max_health, "Current Health is larger than Max Health")

func damage(value):
	current_health = clamp(current_health - value, 0, max_health)
	health_changed.emit(current_health, value)
	if current_health == 0:
		health_reached_zero.emit()

func heal(value):
	damage(-value)

func is_alive():
	return current_health > 0
