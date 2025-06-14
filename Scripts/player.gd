extends CharacterBody2D

# Player stats
@export var speed: int = 130
@export var jump_velocity: int = -350
@export var health: int = 100
@export var max_health: int = 100
var is_hurt: bool = false

#Damage Variables
@export var damage: int = 25
var damage_item_count: int = 0

signal HealthChanged

# Double jump variables
var collected_double_jump_count: int = 0
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
@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Timers
var attack_timer: Timer
var attack_cooldown_timer: Timer

func _ready():
	add_to_group("player")

	# Attack and hurtbox setup
	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = true
		attack_area.add_to_group("player_attack")
		attack_area.area_entered.connect(_on_attack_area_entered)

	if hurtbox:
		hurtbox.monitoring = true
		hurtbox.monitorable = true
		hurtbox.add_to_group("player_hurtbox")
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# Timers
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = 0.35  # Based on your attack animation length
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	add_child(attack_timer)

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.4
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(attack_cooldown_timer)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Reset jump count if on floor
	if is_on_floor():
		jump_count = 0

	max_jumps = 2 if can_double_jump else 1

	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

	# Attack
	if Input.is_action_just_pressed("attack") and can_attack and is_on_floor():
		attack()
		return

	var direction := Input.get_axis("move_left", "move_right")

	if is_attacking:
		velocity.x = 0
	else:
		velocity.x = direction * speed if direction else 0
		set_facing_direction(direction)

	move_and_slide()

	update_animation()

func set_facing_direction(new_direction: int):
	if new_direction == 0:
		return
	if facing_direction != new_direction:
		facing_direction = new_direction
		animated_sprite.flip_h = (facing_direction == -1)
		if attack_area:
			attack_area.scale.x = facing_direction

func add_damage_item():
	damage_item_count += 1
	if damage_item_count >= 3:
		damage += 25
		print("damage increased.")

func attack():
	if not can_attack:
		return

	is_attacking = true
	can_attack = false

	animated_sprite.play("attack")

	if attack_area:
		attack_area.monitoring = true
		await get_tree().process_frame
		_check_attack_overlaps()

	attack_timer.start()
	attack_cooldown_timer.start()

func _check_attack_overlaps():
	if not attack_area or not attack_area.monitoring:
		return

	var overlapping_areas = attack_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("enemy_hurtbox"):
			var enemy_node = area.get_parent()
			if enemy_node.has_method("take_damage"):
				print("Player hit enemy (frame check)")
				enemy_node.take_damage(damage)

func _on_attack_area_entered(area):
	if area.is_in_group("enemy_hurtbox") and attack_area.monitoring:
		var enemy_node = area.get_parent()
		if enemy_node.has_method("take_damage"):
			print("Player hit enemy (area entered)")
			enemy_node.take_damage(damage)

func _on_hurtbox_area_entered(area):
	if area == attack_area:
		return
	if area.is_in_group("enemy_attack") and area.monitoring:
		var enemy = area.get_parent()
		if enemy.has_method("get_damage"):
			take_damage(enemy.get_damage())

func take_damage(amount: int):
	if is_hurt or health <= 0:
		return

	health -= amount
	emit_signal("HealthChanged")
	is_hurt = true
	print("Playing animation take_damage")
	animated_sprite.play("take_damage")
	print("Player took damage, health:", health)

	if health <= 0:
		die()

func die():
	print("Player died!")
	animated_sprite.play("die")
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _on_attack_timer_timeout():
	is_attacking = false
	attack_area.monitoring = false
	update_animation()

func _on_attack_cooldown_timeout():
	can_attack = true

func update_animation():
	if is_hurt or is_attacking:
		return

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

# Optional: Coin update function
func update_coin_label():
	var ui = get_tree().get_first_node_in_group("UI")
	if ui:
		ui.update_coin_count(collected_item_count)

func _on_animation_finished():
	if animated_sprite.animation == "take_damage" or animated_sprite.animation == "attack":
		is_hurt = false
		print("do we even get here")
		update_animation()
