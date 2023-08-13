extends CharacterBody2D


@export var jump_velocity = -1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var origin_y

func _ready():
	origin_y = position.y

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if position.y >= origin_y:
		velocity.y = jump_velocity

	move_and_slide()
