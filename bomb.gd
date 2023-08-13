extends RigidBody2D

func _ready():
	$Timer.connect("timeout", _on_timer_finished);

func _on_timer_finished():
	$Particles.emitting = true
	var bodies = $ExplosionRadius.get_overlapping_bodies()
	print(bodies)
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(1)
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _physics_process(_delta):
	var time_left_percentage = $Timer.get_time_left() / $Timer.get_wait_time()
	$Sprite2D.modulate = Color(1, lerp(0.6, 1.0, time_left_percentage), lerp(0.6, 1.0, time_left_percentage))
