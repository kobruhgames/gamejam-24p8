extends RigidBody2D

func _ready():
	$Timer.connect("timeout", _on_timer_finished);
	var force_direction = Vector2.RIGHT  # Change this to the direction you want
	var force_amount = 300  # Change this to the amount of force you want
	apply_central_impulse(force_direction.normalized() * force_amount)

func _on_timer_finished():
	var bodies = $ExplosionRadius.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(10)
	queue_free()
	print("boom");
