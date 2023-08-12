extends RigidBody2D

func _ready():
	$Timer.connect("timeout", _on_timer_finished);

func _on_timer_finished():
	var bodies = $ExplosionRadius.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(1)
	queue_free()

func _physics_process(delta):
	var time_left_percentage = $Timer.get_time_left() / $Timer.get_wait_time()
	$Sprite2D.modulate = Color(1 - time_left_percentage, time_left_percentage, time_left_percentage)
	$Sprite2D.scale = Vector2(1 - time_left_percentage + 1, 1 - time_left_percentage + 1)
