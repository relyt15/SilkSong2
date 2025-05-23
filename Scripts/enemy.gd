extends CharacterBody2D

# All possible enemy states
enum State {
	IDLE,
	CHASE,
	ATTACK,
	HURT,
	DEAD,
	COOLDOWN
}

# Enemy stats
# @export allows adjustment in inspector
@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 10
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.0

# Initial state variables
var current_state: State = State.IDLE
var player = null
var can_attack: bool = true
var direction: int = 1  # 1 for right, -1 for left
var cooldown_timer: Timer

# CollisionShape references
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var hitbox = $Hitbox

# Godot callback func (called when a node and its children have entered the scene tree and are ready)
func _ready():
	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# Create a cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(cooldown_timer)
	
	# Start in idle state
	change_state(State.IDLE)

# Godot callback func (called every physics frame)
func _physics_process(delta):
	# Handle state logic (match is a switch statement)
	match current_state:
		State.IDLE:
			process_idle_state(delta)
		State.CHASE:
			process_chase_state(delta)
		State.ATTACK:
			process_attack_state(delta)
		State.COOLDOWN:
			process_cooldown_state(delta)
		State.HURT:
			process_hurt_state(delta)
		State.DEAD:
			process_dead_state(delta)
	
	# Apply movement
	move_and_slide()

func process_idle_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("idle")
		
	# If player is detected, switch to chase
	if player != null:
		change_state(State.CHASE)

func process_chase_state(_delta):
	if player == null:
		change_state(State.IDLE)
		return
	
	animated_sprite.play("run")
	
	# Calculate direction to player
	var direction_to_player = global_position.direction_to(player.global_position)
	velocity = direction_to_player * speed
	
	# Update facing direction
	if direction_to_player.x > 0.01:
		direction = 1
		animated_sprite.flip_h = false
	elif direction_to_player.x < -0.01:
		direction = -1
		animated_sprite.flip_h = true
	
	# Check if in attack range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and can_attack:
		change_state(State.ATTACK)

func process_attack_state(_delta):
	velocity = Vector2.ZERO
	if animated_sprite.animation != "attack":
		animated_sprite.play("attack")

func process_cooldown_state(_delta):
	# Stay in place during cooldown but face the player
	velocity = Vector2.ZERO
	animated_sprite.play("idle")  # Play idle animation during cooldown
	
	# Update facing direction if player exists
	if player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		if direction_to_player.x > 0.01:
			direction = 1
			animated_sprite.flip_h = false
		elif direction_to_player.x < -0.01:
			direction = -1
			animated_sprite.flip_h = true

func process_hurt_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("take_damage")

func process_dead_state(_delta):
	velocity = Vector2.ZERO
	# Animation will play from take_damage function

func change_state(new_state: State):
	# Prevent changing to the currently set state
	if current_state == new_state:
		return
		
	current_state = new_state

func take_damage(amount: int):
	if current_state == State.DEAD:
		return
	
	health -= amount
	if health <= 0:
		change_state(State.DEAD)
		animated_sprite.play("die")
	else:
		change_state(State.HURT)
		# Knockback could be added here later

func _on_detection_area_body_entered(body):
	# Detect if player entered the detection area
	if body.is_in_group("player"):
		player = body
		if current_state == State.IDLE:
			change_state(State.CHASE)

func _on_detection_area_body_exited(body):
	# Detect if player exited the detection area
	if body.is_in_group("player"):
		player = null
		if current_state == State.CHASE:
			change_state(State.IDLE)

func _on_hitbox_area_entered(area):
	# Check if the player's attack hit this enemy
	if area.is_in_group("player_attack"):
		take_damage(area.get_damage())  # Will need to add get_damage method to player attack area script

func _on_attack_cooldown_timeout():
	can_attack = true
	
	# Check player status and position to determine next state
	if player != null and current_state != State.HURT and current_state != State.DEAD:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= attack_range:
			change_state(State.ATTACK)
		else:
			change_state(State.CHASE)
	elif current_state != State.HURT and current_state != State.DEAD:
		change_state(State.IDLE)

func _on_animation_finished():
	# Handle what happens when animations finish
	match current_state:
		State.ATTACK:
			# Attack finished, start cooldown timer and enter cooldown state
			can_attack = false
			cooldown_timer.wait_time = attack_cooldown
			cooldown_timer.start()
			change_state(State.COOLDOWN)
		State.HURT:
			# After hurt animation, go back to chase if player still in range
			if player != null:
				change_state(State.CHASE)
			else:
				change_state(State.IDLE)
		State.DEAD:
			queue_free()  # Remove enemy from scene
