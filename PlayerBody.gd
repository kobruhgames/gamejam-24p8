extends CharacterBody2D

@export var health = 4
@export var bombs = 3
@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000
@export_range(0.0, 1.0) var friction = 0.25
@export_range(0.0 , 1.0) var acceleration = 0.18
@export var player = 1

const BOMB_OFFSET = Vector2(50, 0)
const BOMB_IMPULSE = 350
const HORIZONTAL_DIR_STOP = 0
const PEAK_FRAME_DURATION = 100

const Bomb = preload("res://scenes/bomb.tscn")
var last_direction = 0;
var original_color;

signal health_lost;
signal bomb_count_changed;

# =============================
# PUBLIC
# =============================
func is_alive():
	return health > 0

func receive_enemy_damage(amount):
	if health > 0:
		receive_damage(amount)

func receive_damage(amount):
	health -= amount
	health_lost.emit(health)
	if health <= 0:
		$AnimatedSprite2D.stop()
		$IdleAnimationTimer.stop()
		$AnimatedSprite2D.connect("animation_looped", queue_free)
		$AnimatedSprite2D.play("death")
	else:
		var tween = get_tree().create_tween()
		tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 0, 0, 0.5), 0.1)
		tween.tween_property($AnimatedSprite2D, "modulate", original_color, 0.1).set_delay(0.1)

func add_bombs(amount):
	bombs += amount
	bomb_count_changed.emit(bombs)

# =============================
# PRIVATE
# =============================
func _ready():
	$IdleAnimationTimer.connect("timeout", _on_idle_triggered)
	original_color = $AnimatedSprite2D.modulate
	default_scale = $AnimatedSprite2D.scale

func _physics_process(delta):
	_apply_gravity(delta)
	var input_horizontal_direction = _read_input_horizontal_direction()
	
	if health > 0:
		_update_animation(input_horizontal_direction, delta)
		if input_horizontal_direction == HORIZONTAL_DIR_STOP:
			_apply_stop_force()
		else:
			_apply_horizontal_force(input_horizontal_direction * speed)
		_handle_jump()
		_handle_bomb_throw()
		_handle_look()
	else:
		_apply_stop_force()
	move_and_slide()

func _apply_gravity(delta):
	velocity.y += gravity * delta

func _read_input_horizontal_direction():
	var new_direction = Input.get_axis("walk_left_p" + str(player), "walk_right_p" + str(player))
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
	if Input.is_action_just_pressed("jump_p" + str(player)) and is_on_floor():
		velocity.y = jump_speed

func _handle_bomb_throw():
	if Input.is_action_just_pressed("spawn_bomb_p" + str(player)) && bombs > 0:
		bombs -= 1
		bomb_count_changed.emit(bombs)
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

func _handle_look():
	var look_axis = Input.get_axis("look_up_p" + str(player), "look_down_p" + str(player))
	stretch_or_squish(look_axis)

var default_scale

func stretch_or_squish(look_axis: float) -> void:
	var stretch_scale: Vector2 = default_scale

	var default_scale_y: float = default_scale.y
	var squish_scale_multiplier: float = 0.2  # Adjust these values to decrease/increase the squishing
	var stretch_scale_multiplier: float = 0.2  # Adjust these values to decrease/increase stretching

	# Looking up, should stretch
	if look_axis < 0:
		stretch_scale.y = default_scale_y - look_axis * stretch_scale_multiplier
	# Looking down, should squish
	elif look_axis > 0:
		stretch_scale.y = default_scale_y - look_axis * squish_scale_multiplier
	else:
		stretch_scale.y = default_scale_y

	$AnimatedSprite2D.scale = stretch_scale

func _on_idle_triggered():
	$IdleAnimationTimer.stop();
	$AnimatedSprite2D.play("sit_right");
