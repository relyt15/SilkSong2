extends CharacterBody2D

# Player stats
@export var speed: int = 130
@export var jump_velocity: int = -350
@export var health: int = 100
@export var max_health: int = 100
@export var damage: int = 25

# Attack system
var is_attacking: bool = false
var can_attack: bool = true

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hurtbox = $Hurtbox

func _ready():
	# Add player to group for enemy detection
	add_to_group("player")
	
	# Connect signals
	if attack_area:
		attack_area.add_to_group("player_attack")
		# Disable attack area initially - only active during attacks
		attack_area.monitoring = false
	
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle attack input
	if Input.is_action_just_pressed("attack") and can_attack and is_on_floor():
		attack()
		return  # Don't process movement during attack
	
	# Skip movement if attacking
	if is_attacking:
		velocity.x = 0  # Stop horizontal movement during attack
		move_and_slide()
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get the input direction and handle the movement/deceleration.
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

func attack():
	if not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	animated_sprite.play("attack")
	
	# Enable attack hitbox ONLY during attack
	if attack_area:
		attack_area.monitoring = true

func take_damage(amount: int):
	health -= amount
	print("Player took ", amount, " damage. Health: ", health)
	
	if health <= 0:
		die()
	else:
		# Play hurt animation
		# animated_sprite.play("hurt")
		pass

func die():
	print("Player died!")
	# Add death logic here
	# animated_sprite.play("die")
	# Could reload scene, show game over screen, etc.

# Get damage amount for enemy to reference
func get_damage() -> int:
	return damage

func _on_animation_finished():
	# Handle attack animation finishing
	if animated_sprite.animation == "attack":
		is_attacking = false
		can_attack = true
		# Disable attack area when attack ends
		if attack_area:
			attack_area.monitoring = false

func _on_hurtbox_area_entered(area):
	# Only take damage when enemy attack area is actively monitoring
	if area.is_in_group("enemy_attack") and area.monitoring:
		var enemy = area.get_parent()
		if enemy.has_method("get_damage"):
			take_damage(enemy.get_damage())
