extends StaticBody2D

signal got_hit

func receive_damage(_value):
	print("got hit for ", _value)
	got_hit.emit(_value)
