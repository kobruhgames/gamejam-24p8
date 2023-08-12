extends CharacterBody2D

@export var health = 3
@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.18

const BOMB_OFFSET = Vector2(50, 0)
const BOMB_IMPULSE = 350
const HORIZONTAL_DIR_STOP = 0
const PEAK_FRAME_DURATION = 100

const Bomb = preload("res://bomb.tscn")
var last_direction = 0;

signal health_lost;

# =============================
# PUBLIC
# =============================
func receive_damage(amount):
	health -= amount
	health_lost.emit(health)
	if health <= 0:
		queue_free();

# =============================
# PRIVATE
# =============================
func _ready():
	$IdleAnimationTimer.connect("timeout", _on_idle_triggered);

func _physics_process(delta):
	_apply_gravity(delta)
	var input_horizontal_direction = _read_input_horizontal_direction()
	_update_animation(input_horizontal_direction, delta)
	if input_horizontal_direction == HORIZONTAL_DIR_STOP:
		_apply_stop_force()
	else:
		_apply_horizontal_force(input_horizontal_direction * speed)
	_handle_jump()
	_handle_bomb_throw()
	move_and_slide()

func _apply_gravity(delta):
	velocity.y += gravity * delta

func _read_input_horizontal_direction():
	var new_direction = Input.get_axis("walk_left", "walk_right")
	last_direction = new_direction if new_direction != HORIZONTAL_DIR_STOP else last_direction 
	return new_direction

func _update_animation(horizontal_direction, delta):
	var non_g_velocity = velocity.y - gravity * delta;
	if is_on_floor() == false && velocity.y < -PEAK_FRAME_DURATION:
		$AnimatedSprite2D.play("jump_up_right")
	elif is_on_floor() == false && velocity.y > PEAK_FRAME_DURATION:
		$AnimatedSprite2D.play("jump_down_right")
	elif is_on_floor() == false && velocity.y > -PEAK_FRAME_DURATION && velocity.y < PEAK_FRAME_DURATION:
		$AnimatedSprite2D.play("jump_peak_right")
	else:
		if horizontal_direction == HORIZONTAL_DIR_STOP:
			if $IdleAnimationTimer.is_stopped() == false:
				$AnimatedSprite2D.play("walk_right")
				$AnimatedSprite2D.stop() # animation stop
		else:
			$IdleAnimationTimer.stop()
			$IdleAnimationTimer.start()
			$AnimatedSprite2D.play("walk_right")
			$AnimatedSprite2D.flip_h = horizontal_direction < HORIZONTAL_DIR_STOP

func _apply_stop_force():
	velocity.x = lerp(velocity.x, 0.0, friction)

func _apply_horizontal_force(horizontal_force):
	velocity.x = lerp(velocity.x, horizontal_force, acceleration)

func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

func _handle_bomb_throw():
	if Input.is_action_just_pressed("spawn_bomb"):
		var bomb = Bomb.instantiate()
		var direction 
		if last_direction > 0:  # player is looking to the right
			bomb.position = self.position + BOMB_OFFSET
			direction = Vector2.RIGHT
		else:  # player is looking to the left
			bomb.position = self.position - BOMB_OFFSET
			direction = Vector2.LEFT
		get_parent().add_child(bomb)
		bomb.apply_central_impulse(direction * BOMB_IMPULSE)

func _on_idle_triggered():
	$IdleAnimationTimer.stop();
	$AnimatedSprite2D.play("sit_right");
