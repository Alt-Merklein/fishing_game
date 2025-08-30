extends CharacterBody2D

const SPEED = 130.0

@onready var sprite = $Sprite2D # or $AnimatedSprite2D, adjust the path to your sprite node

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Flip sprite depending on direction
		if direction > 0:
			sprite.flip_h = false  # facing right
		elif direction < 0:
			sprite.flip_h = true   # facing left
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
