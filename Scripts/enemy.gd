extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	HURT,
	DEAD,
	COOLDOWN
}

@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 25
@export var attack_range: float = 35.0
@export var attack_cooldown: float = 1.0

var current_state: State = State.IDLE
var player = null
var can_attack: bool = true
var direction: int = 1
var cooldown_timer: Timer
var gravity = 980.0
var hit_registered_this_attack: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var hurtbox = $HurtBox
@onready var attack_area = $AttackArea
@onready var healthbar = $health_bar

func _ready():
	healthbar.init_health(health)

	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = true

	if hurtbox:
		hurtbox.monitoring = true
		hurtbox.monitorable = true

	hurtbox.add_to_group("enemy_hurtbox")
	attack_area.add_to_group("enemy_attack")
	attack_area.monitoring = false

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_animation_frame_changed)

	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(cooldown_timer)

	change_state(State.IDLE)

func _physics_process(delta):
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

	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y < 0:
		velocity.y = 0

	move_and_slide()

func process_idle_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("idle")

	if player != null:
		change_state(State.CHASE)

func process_chase_state(_delta):
	if player == null:
		change_state(State.IDLE)
		return

	animated_sprite.play("run")
	var direction_to_player = global_position.direction_to(player.global_position)
	velocity = direction_to_player * speed

	if direction_to_player.x > 0.01:
		set_facing_direction(1)
	elif direction_to_player.x < -0.01:
		set_facing_direction(-1)

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and can_attack:
		change_state(State.ATTACK)

func process_attack_state(_delta):
	velocity = Vector2.ZERO

	if animated_sprite.animation != "attack":
		animated_sprite.play("attack")
		attack_area.monitoring = true
		hit_registered_this_attack = false

func process_cooldown_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("idle")

	if player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		if direction_to_player.x > 0.01:
			set_facing_direction(1)
		elif direction_to_player.x < -0.01:
			set_facing_direction(-1)

func process_hurt_state(_delta):
	velocity = Vector2.ZERO
	animated_sprite.play("take_damage")

func process_dead_state(_delta):
	velocity = Vector2.ZERO

func set_facing_direction(new_direction: int):
	if direction != new_direction:
		direction = new_direction
		animated_sprite.flip_h = (direction == -1)
		if attack_area:
			attack_area.scale.x = direction

func change_state(new_state: State):
	if current_state == new_state:
		return

	current_state = new_state

func take_damage(amount: int):
	if current_state == State.DEAD:
		return

	health -= amount
	
	healthbar.health = health
	
	if health <= 0:
		change_state(State.DEAD)
		animated_sprite.play("die")
	else:
		change_state(State.HURT)

func get_damage() -> int:
	return damage

func _check_attack_overlaps():
	if not attack_area or not attack_area.monitoring:
		return

	var overlapping_areas = attack_area.get_overlapping_areas()

	for area in overlapping_areas:
		if area.is_in_group("player_hurtbox"):
			var player_node = area.get_parent()
			if player_node.has_method("take_damage"):
				player_node.take_damage(damage)

func _on_animation_frame_changed():
	if animated_sprite.animation == "attack" and animated_sprite.frame == 8:
		if not hit_registered_this_attack:
			_check_attack_overlaps()
			hit_registered_this_attack = true

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		if current_state == State.IDLE:
			change_state(State.CHASE)

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null
		if current_state == State.CHASE:
			change_state(State.IDLE)

func _on_hurtbox_area_entered(area):
	if area == attack_area:
		return

func _on_attack_cooldown_timeout():
	can_attack = true

	if player != null and current_state != State.HURT and current_state != State.DEAD:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= attack_range:
			change_state(State.ATTACK)
		else:
			change_state(State.CHASE)
	elif current_state != State.HURT and current_state != State.DEAD:
		change_state(State.IDLE)

func _on_animation_finished():
	match current_state:
		State.ATTACK:
			attack_area.monitoring = false
			can_attack = false
			cooldown_timer.wait_time = attack_cooldown
			cooldown_timer.start()
			change_state(State.COOLDOWN)
		State.HURT:
			if player != null:
				change_state(State.CHASE)
			else:
				change_state(State.IDLE)
		State.DEAD:
			queue_free()
