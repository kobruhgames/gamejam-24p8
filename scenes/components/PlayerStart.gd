extends Node2D


func _ready():
	var joysticks = Input.get_connected_joypads()
	if joysticks.size() == 0:
		$Player2.queue_free()
		print(joysticks)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
