extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

#Variables for double_jump
var collected_item_count: int = 0
var can_double_jump: bool = false
var jump_count: int = 0
var max_jumps: int = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
#resets jumps when grounded
	if is_on_floor():
		jump_count = 0
#allows for double jumping when items are collected
	max_jumps = 2 if can_double_jump else 1

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	var direction := Input.get_axis("ui_left", "ui_right")
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
