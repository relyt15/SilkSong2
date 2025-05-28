extends CharacterBody2D

# Player stats
@export var speed: int = 130
@export var jump_velocity: int = -350
@export var health: int = 100
@export var max_health: int = 100
@export var damage: int = 25

#Variables for double_jump
var collected_item_count: int = 0
var can_double_jump: bool = false
var jump_count: int = 0
var max_jumps: int = 1

# Attack system
var is_attacking: bool = false
var can_attack: bool = true

# Direction tracking
var facing_direction: int = 1  # 1 for right, -1 for left

# Node references
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hurtbox = $HurtBox

func _ready():
	# Player collision layers
	if attack_area:
		attack_area.collision_layer = 1  # Player attack on layer 1
		attack_area.collision_mask = 4   # Detect enemy hurtboxes on layer 4
		attack_area.monitoring = true
		attack_area.monitorable = true
		print("Player Attack area collision_layer: ", attack_area.collision_layer, " collision_mask: ", attack_area.collision_mask)

	if hurtbox:
		hurtbox.collision_layer = 2      # Player hurtbox on layer 2
		hurtbox.collision_mask = 3       # Detect enemy attacks on layer 3
		hurtbox.monitoring = true
		hurtbox.monitorable = true
		print("Player Hurtbox collision_layer: ", hurtbox.collision_layer, " collision_mask: ", hurtbox.collision_mask)
	
	add_to_group("player")
	
	if attack_area:
		attack_area.add_to_group("player_attack")
		attack_area.monitoring = false
		# Connect the area_entered signal for immediate detection
		attack_area.area_entered.connect(_on_attack_area_entered)
	
	if hurtbox:
		hurtbox.add_to_group("player_hurtbox")
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
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
	
	if Input.is_action_just_pressed("attack") and can_attack and is_on_floor():
		attack()
		return
	
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = 0

	# Update facing direction and flip sprite + attack area
	if direction == 1:
		set_facing_direction(1)
	elif direction == -1:
		set_facing_direction(-1)

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif direction:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	move_and_slide()

func set_facing_direction(new_direction: int):
	if facing_direction != new_direction:
		facing_direction = new_direction
		
		# Flip sprite
		animated_sprite.flip_h = (facing_direction == -1)
		
		# Flip attack area
		if attack_area:
			attack_area.scale.x = facing_direction

func attack():
	if not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	animated_sprite.play("attack")
	
	if attack_area:
		attack_area.monitoring = true
		# Wait one frame before checking overlaps
		await get_tree().process_frame
		_check_attack_overlaps()

# Check for overlapping areas when attack starts
func _check_attack_overlaps():
	if not attack_area or not attack_area.monitoring:
		return
	
	var overlapping_areas = attack_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.is_in_group("enemy_hurtbox"):
			var enemy_node = area.get_parent()
			if enemy_node.has_method("take_damage"):
				enemy_node.take_damage(damage)

# This will catch enemies that enter the attack area while it's active
func _on_attack_area_entered(area):
	if area.is_in_group("enemy_hurtbox") and attack_area.monitoring:
		var enemy_node = area.get_parent()
		if enemy_node.has_method("take_damage"):
			enemy_node.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	print(health)
	if health <= 0:
		die()

func die():
	print("Player died!")

func get_damage() -> int:
	return damage

func _on_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		can_attack = true
		if attack_area:
			attack_area.monitoring = false

func _on_hurtbox_area_entered(area):
	# Don't detect our own attack area
	if area == attack_area:
		print("Player ignoring own attack area")
		return
		
	if area.is_in_group("enemy_attack") and area.monitoring:
		var enemy = area.get_parent()
		if enemy.has_method("get_damage"):
			take_damage(enemy.get_damage())
