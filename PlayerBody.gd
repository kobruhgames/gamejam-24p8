extends CharacterBody2D

var HealthNodeScene = preload("res://scenes/components/health.tscn")

var health_node : Node2D

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
	return health_node.is_alive()

func receive_enemy_damage(amount):
	receive_damage(amount)

func receive_damage(_amount):
	health_node.damage(_amount)
	health_lost.emit(health_node.current_health)
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
	health_node = HealthNodeScene.instantiate()
	add_child(health_node)
	health_node.connect("health_reached_zero", _on_health_reached_zero)

	$IdleAnimationTimer.connect("timeout", _on_idle_triggered)
	original_color = $AnimatedSprite2D.modulate

func _on_health_reached_zero():
	$AnimatedSprite2D.stop()
	$IdleAnimationTimer.stop()
	$AnimatedSprite2D.connect("animation_looped", queue_free)
	$AnimatedSprite2D.play("death")

func _physics_process(delta):
	_apply_gravity(delta)
	var input_horizontal_direction = _read_input_horizontal_direction()
	
	if health_node.is_alive():
		_update_animation(input_horizontal_direction, delta)
		if input_horizontal_direction == HORIZONTAL_DIR_STOP:
			_apply_stop_force()
		else:
			_apply_horizontal_force(input_horizontal_direction * speed)
		_handle_jump()
		_handle_bomb_throw()
	else:
		_apply_stop_force()
	move_and_slide()

func _apply_gravity(delta):
	velocity.y += gravity * delta

func _read_input_horizontal_direction():
	var new_direction = Input.get_axis("walk_left_p" + str(player), "walk_right_p" + str(player))
	if new_direction != HORIZONTAL_DIR_STOP:
		last_direction = new_direction
	return new_direction

func _update_animation(horizontal_direction, _delta):
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

func _on_idle_triggered():
	$IdleAnimationTimer.stop();
	$AnimatedSprite2D.play("sit_right");
