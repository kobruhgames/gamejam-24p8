extends RigidBody2D

func _ready():
	$Timer.connect("timeout", _on_timer_finished);

func _on_timer_finished():
	var bodies = $ExplosionRadius.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(1)
	queue_free()
