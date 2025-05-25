extends CharacterBody2D

# Player stats
@export var speed: int = 130
@export var jump_velocity: int = -350
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 25

# Attack system
var is_attacking: bool = false
var can_attack: bool = true

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hurtbox = $Hurtbox

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	var direction := Input.get_axis("move_left", "move_right")
	# Horizontal movement
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = 0

	# Flip sprite
	if direction == 1:
		animated_sprite.flip_h = false
	elif direction == -1:
		animated_sprite.flip_h = true

# Animation state logic
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")  # Going up
		else:
			animated_sprite.play("fall")  # Falling down
	elif direction:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	move_and_slide()
