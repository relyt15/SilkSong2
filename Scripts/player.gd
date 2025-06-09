extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	HURT,
	DEAD
}

@export var speed: int = 130
@export var jump_velocity: int = -350
@export var max_health: int = 100
@export var damage: int = 25
@export var collected_double_jump_count: int = 0
@export var collected_item_count: int = 0

signal HealthChanged

const ATTACK_HIT_FRAME = 8

var health: int
var current_state: State = State.IDLE
var facing_direction: int = 1
var can_attack: bool = true
var can_double_jump: bool = false
var jump_count: int = 0
var max_jumps: int = 1
var spawn_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $HurtBox
@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var death_timer: Timer  # Added death timer

func update_coin_label():
	pass

func _ready():
	spawn_position = global_position
	health = max_health
	change_state(State.IDLE)

	# Setup attack and hurt areas
	attack_area.collision_layer = 1
	attack_area.collision_mask = 4
	attack_area.monitoring = false
	attack_area.add_to_group("player_attack")

	hurtbox.collision_layer = 2
	hurtbox.collision_mask = 3
	hurtbox.monitoring = true
	hurtbox.add_to_group("player_hurtbox")

	# Signal connections
	
	if not attack_area.area_entered.is_connected(_on_attack_area_entered):
		attack_area.area_entered.connect(_on_attack_area_entered)

	if not hurtbox.area_entered.is_connected(_on_hurtbox_area_entered):
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)

	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

	# Death timer
	death_timer = Timer.new()
	death_timer.wait_time = 1.0  # Adjust to match length of "die" animation
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(death_timer)

	add_to_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	match current_state:
		State.IDLE: _process_idle()
		State.RUN: _process_run()
		State.JUMP: _process_jump()
		State.FALL: _process_fall()
		State.ATTACK: _process_attack()
		State.HURT: _process_hurt()
		State.DEAD: _process_dead()

	move_and_slide()

func change_state(new_state: State):
	if current_state == new_state:
		return

	current_state = new_state

	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
			velocity.x = 0
		State.RUN:
			animated_sprite.play("run")
		State.JUMP:
			animated_sprite.play("jump")
		State.FALL:
			animated_sprite.play("fall")
		State.ATTACK:
			pass
		State.HURT:
			animated_sprite.play("take_damage")
			velocity.x = 0
		State.DEAD:
			animated_sprite.play("die")
			velocity = Vector2.ZERO

func _process_idle():
	_handle_input()

func _process_run():
	var dir = Input.get_axis("move_left", "move_right")
	if dir == 0:
		change_state(State.IDLE)
		return

	velocity.x = dir * speed
	set_facing_direction(dir)
	_handle_input()

func _process_jump():
	if velocity.y >= 0:
		change_state(State.FALL)

func _process_fall():
	if is_on_floor():
		change_state(State.IDLE)

func _process_attack():
	velocity.x = 0
	if animated_sprite.animation != "attack":
		animated_sprite.play("attack")
		attack_area.monitoring = true
		await get_tree().process_frame
		_check_attack_overlaps()

func _process_hurt():
	pass

func _process_dead():
	pass

func _handle_input():
	if Input.is_action_just_pressed("jump"):
		_do_jump()
	elif Input.is_action_just_pressed("attack") and can_attack:
		change_state(State.ATTACK)
	else:
		var dir = Input.get_axis("move_left", "move_right")
		if dir != 0:
			change_state(State.RUN)

func _do_jump():
	if can_double_jump:
		max_jumps = 2
	else:
		max_jumps = 1
	if jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1
		change_state(State.JUMP)

func set_facing_direction(new_dir: int):
	if facing_direction != new_dir:
		facing_direction = new_dir
		animated_sprite.flip_h = (facing_direction == -1)
		attack_area.scale.x = facing_direction

func take_damage(amount: int):
	if current_state == State.DEAD:
		return

	health -= amount
	emit_signal("HealthChanged")

	if health <= 0:
		change_state(State.DEAD)
	else:
		change_state(State.HURT)

func get_damage() -> int:
	return damage

func reset_player():
	health = max_health
	can_attack = true
	can_double_jump = false
	jump_count = 0
	max_jumps = 1
	velocity = Vector2.ZERO
	global_position = spawn_position
	collision_shape.disabled = false
	set_facing_direction(1)
	change_state(State.IDLE)
	emit_signal("HealthChanged")

func _check_attack_overlaps():
	var areas = attack_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemy_hurtbox"):
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

func _on_attack_area_entered(area):
	if area.is_in_group("enemy_hurtbox") and attack_area.monitoring:
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

func _on_hurtbox_area_entered(area):
	if area == attack_area:
		return
	if area.is_in_group("enemy_attack") and area.monitoring:
		var enemy = area.get_parent()
		if enemy.has_method("get_damage"):
			take_damage(enemy.get_damage())

func _on_animation_finished():
	match current_state:
		State.ATTACK:
			attack_area.monitoring = false
			can_attack = false
			timer.start()
			change_state(State.IDLE)
		State.HURT:
			change_state(State.IDLE)
		State.DEAD:
			death_timer.start()

func _on_timer_timeout():
	can_attack = true

func _on_death_timer_timeout():
	reset_player()
