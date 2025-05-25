extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -350.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	var direction := Input.get_axis("move_left", "move_right")
	# Horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	# Flip sprite
	if direction == 1:
		$AnimatedSprite2D.flip_h = false
	elif direction == -1:
		$AnimatedSprite2D.flip_h = true

# Animation state logic
	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")  # Going up
		else:
			$AnimatedSprite2D.play("fall")  # Falling down
	elif direction:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
