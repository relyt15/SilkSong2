extends CharacterBody2D

# All possible enemy states
enum State {
	IDLE,
	CHASE,
	ATTACK,
	HURT,
	DEAD
}

# Enemy stats
# @export allows adjustment in inspector
@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 10
@export var attack_range: float = 50.0
@export var detection_range: float = 200.0
@export var attack_cooldown: float = 1.0

# Initial state variables
var current_state: State = State.IDLE
var player = null
var can_attack: bool = true
var direction: int = 1  # 1 for right, -1 for left

# CollisionShape references
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var hitbox = $Hitbox

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
	if direction_to_player.x > 0:
		direction = 1
		animated_sprite.flip_h = false
	else:
		direction = -1
		animated_sprite.flip_h = true
	
	# Check if in attack range
	if global_position.distance_to(player.global_position) <= attack_range and can_attack:
		change_state(State.ATTACK)

func process_attack_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("attack")
	
	# Attack logic will be handled by animation finished signal
	# We'll connect this after defining the function

func process_hurt_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("take_damage")
	
	# State change will be handled by animation finished signal

func process_dead_state(_delta):
	velocity = Vector2.ZERO
	# Animation will play from take_damage function

func change_state(new_state: State):
	current_state = new_state
