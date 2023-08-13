extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var alive = true
var settled = false

@export var target : CharacterBody2D

func receive_damage(_amount):
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.connect("animation_looped", _on_death_anim_end)
	$AnimatedSprite2D.play("death")
	alive = false

func _on_death_anim_end():
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.set_frame_and_progress(3, 1.0)

func _physics_process(delta):
	if settled || target == null:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if alive:
		var direction = sign(target.transform.origin.x - self.transform.origin.x)

		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction < 0

		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_on_floor():
		$CollisionShape2D.queue_free()
		settled = true
	move_and_slide()

func _on_hurt_timer_timeout():
	if alive:
		var bodies = $HurtBox.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("receive_enemy_damage"):
				body.receive_enemy_damage(1)

func _on_chase_area_body_entered(body):
	if body is CharacterBody2D:
		target = body

func _on_chase_area_body_exited(body):
	if body == target:
		target = null
