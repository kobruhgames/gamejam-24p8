extends Node2D

@export var music : AudioStream

var p1_live = true
var p2_live = true

func _ready():
	var joysticks = Input.get_connected_joypads()
	if joysticks.size() == 0:
		$Player2.queue_free()
		p2_live = false


func _on_player_2_died():
	if p1_live == false:
		get_tree().quit()


func _on_player_1_died():
	if p2_live == false:
		get_tree().quit()

