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
