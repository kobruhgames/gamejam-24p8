extends CharacterBody2D

@export var health = 100
@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25

const Bomb = preload("res://bomb.tscn")
var lastDir = 0;

signal health_lost;

func _physics_process(delta):
	velocity.y += gravity * delta
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		lastDir = dir
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	if Input.is_action_just_pressed("spawn_bomb"):
		var bomb = Bomb.instantiate()
		var direction 
		if lastDir > 0:  # player is looking to the right
			bomb.position = self.position + Vector2(50, 0)
			direction = Vector2(1, 0)
		else:  # player is looking to the left
			bomb.position = self.position - Vector2(50, 0)
			direction = Vector2(-1, 0)
		get_parent().add_child(bomb)
		bomb.apply_central_impulse(direction * 350)

func receive_damage(amount):
	health -= amount
	print(health)
	health_lost.emit(health)
	if health < 0:
		queue_free();
