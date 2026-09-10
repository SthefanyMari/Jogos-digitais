extends CharacterBody2D

@export var vida_maxima: int = 5
var vida: int

enum PlayerState {
	idle,
	walk,
	run,
	jump,
	hurt,
	attack
}

var status: PlayerState

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_golpe: Area2D = $AreaGolpe

@export var dano_do_golpe: int = 2
@export var quadro_do_golpe: int = 3
@export var tempo_hurt: float = 0.4

const SPEED: float = 150.0
const SPEED_RUN: float = 200.0
const JUMP_VELOCITY: float = -430.0
const GRAVITY: float = 900.0

var direction: float = 0.0
var jump_count: int = 0
var max_jump_count: int = 2
var golpe_aplicado: bool = false
var tempo_no_hurt: float = 0.0

var normal_collider_size: Vector2
var normal_collider_position: Vector2


func _ready() -> void:
	vida = vida_maxima

	var shape := collision_shape.shape as RectangleShape2D

	normal_collider_size = shape.size
	normal_collider_position = collision_shape.position

	area_golpe.monitoring = false

	if anim.sprite_frames.has_animation("walk"):
		anim.sprite_frames.set_animation_speed("walk", 8.0)

	if anim.sprite_frames.has_animation("run"):
		anim.sprite_frames.set_animation_speed("run", 11.0)

	go_to_idle_state()


func levar_dano(quantidade: int) -> void:
	if status == PlayerState.hurt:
		return

	vida -= quantidade
	print("Vida: ", vida)

	if vida <= 0:
		morrer()
		return

	go_to_hurt_state()


func morrer() -> void:
	status = PlayerState.hurt
	anim.play("death")
	velocity.x = 0
	area_golpe.monitoring = false
	set_physics_process(false)


func go_to_idle_state() -> void:
	status = PlayerState.idle
	anim.play("idle")
	anim.modulate = Color(1, 1, 1)
	anim.scale = Vector2.ONE
	restore_collider()


func idle_state() -> void:
	move()

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if direction != 0.0:
		if Input.is_action_pressed("run"):
			go_to_run_state()
		else:
			go_to_walk_state()

		return


func go_to_walk_state() -> void:
	status = PlayerState.walk
	anim.play("walk")


func walk_state() -> void:
	move()

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if direction == 0.0:
		go_to_idle_state()
		return

	if not is_on_floor():
		go_to_jump_state(false)
		return

	if Input.is_action_pressed("run"):
		go_to_run_state()
		return


func go_to_run_state() -> void:
	status = PlayerState.run
	anim.play("run")


func run_state() -> void:
	move(SPEED_RUN)

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if direction == 0.0:
		go_to_idle_state()
		return

	if not Input.is_action_pressed("run"):
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if not is_on_floor():
		go_to_jump_state(false)
		return


func go_to_jump_state(make_jump: bool = true) -> void:
	status = PlayerState.jump
	anim.scale = Vector2.ONE
	restore_collider()

	if make_jump:
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	anim.play("jump")


func jump_state() -> void:
	move()

	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jump_count:
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if is_on_floor():
		jump_count = 0

		if direction == 0.0:
			go_to_idle_state()
			return

		if Input.is_action_pressed("run"):
			go_to_run_state()
			return

		go_to_walk_state()
		return

	if anim.animation != "jump":
		anim.play("jump")


func go_to_hurt_state() -> void:
	status = PlayerState.hurt
	anim.play("hurt")
	tempo_no_hurt = 0.0
	velocity.x = 0
	anim.modulate = Color(1, 0.4, 0.4)
	area_golpe.monitoring = false

	var shape := collision_shape.shape as RectangleShape2D

	shape.size = Vector2(
		normal_collider_size.x,
		normal_collider_size.y * 0.55
	)

	collision_shape.position = Vector2(
		normal_collider_position.x,
		normal_collider_position.y + normal_collider_size.y * 0.225
	)

	anim.scale = Vector2(1.0, 0.65)


func hurt_state() -> void:
	tempo_no_hurt += get_physics_process_delta_time()

	if tempo_no_hurt >= tempo_hurt:
		go_to_idle_state()
		return


func go_to_attack_state() -> void:
	status = PlayerState.attack
	anim.play("attack")
	velocity.x = 0
	golpe_aplicado = false
	area_golpe.monitoring = true


func attack_state() -> void:
	if not golpe_aplicado and anim.frame >= quadro_do_golpe:
		golpe_aplicado = true

		for corpo in area_golpe.get_overlapping_bodies():
			if corpo != self and corpo.has_method("levar_dano"):
				corpo.levar_dano(dano_do_golpe)

	if not anim.is_playing():
		area_golpe.monitoring = false
		go_to_idle_state()
		return


func move(vel: float = SPEED) -> void:
	update_direction()

	if direction != 0.0:
		velocity.x = direction * vel
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			vel
		)


func update_direction() -> void:
	direction = Input.get_axis("ui_left", "ui_right")

	if Input.is_key_pressed(KEY_A):
		direction -= 1.0

	if Input.is_key_pressed(KEY_D):
		direction += 1.0

	direction = clampf(direction, -1.0, 1.0)

	if direction > 0.0:
		anim.flip_h = false
		area_golpe.position.x = abs(area_golpe.position.x)

	elif direction < 0.0:
		anim.flip_h = true
		area_golpe.position.x = -abs(area_golpe.position.x)


func restore_collider() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	shape.size = normal_collider_size
	collision_shape.position = normal_collider_position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_on_floor():
		jump_count = 0

	match status:
		PlayerState.hurt:
			hurt_state()

		PlayerState.idle:
			idle_state()

		PlayerState.walk:
			walk_state()

		PlayerState.run:
			run_state()

		PlayerState.jump:
			jump_state()

		PlayerState.attack:
			attack_state()

	move_and_slide()

	if global_position.y > 900.0:
		get_tree().reload_current_scene()
