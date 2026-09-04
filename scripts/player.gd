extends CharacterBody2D


enum PlayerState {
	idle,
	walk,
	jump,
	duck
}


@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


const SPEED: float = 125.0
const JUMP_VELOCITY: float = -430.0
const GRAVITY: float = 900.0

var direction: float = 0.0

var jump_count: int = 0
var max_jump_count: int = 2

var status: PlayerState

var normal_collider_size: Vector2
var normal_collider_position: Vector2


func _ready() -> void:
	add_to_group("player")

	var shape := collision_shape.shape as RectangleShape2D
	normal_collider_size = shape.size
	normal_collider_position = collision_shape.position

	go_to_idle_state()


func go_to_idle_state() -> void:
	status = PlayerState.idle
	anim.play("idle")


func go_to_walk_state() -> void:
	status = PlayerState.walk
	anim.play("walk")


func go_to_jump_state(make_jump: bool = true) -> void:
	status = PlayerState.jump

	anim.scale = Vector2.ONE
	restore_collider()

	if make_jump:
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	anim.play("jump")


func go_to_duck_state() -> void:
	status = PlayerState.duck

	velocity.x = 0.0

	anim.play("duck")

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


func exit_duck_state() -> void:
	restore_collider()
	anim.scale = Vector2.ONE


func idle_state() -> void:
	move()

	if Input.is_action_pressed("ui_down"):
		go_to_duck_state()
		return

	if Input.is_action_just_pressed("ui_accept"):
		go_to_jump_state()
		return

	if direction != 0.0:
		go_to_walk_state()
		return


func walk_state() -> void:
	move()

	if Input.is_action_pressed("ui_down"):
		go_to_duck_state()
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


func jump_state() -> void:
	move()

	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jump_count:
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0

		if direction == 0.0:
			go_to_idle_state()
			return
		else:
			go_to_walk_state()
			return


	if velocity.y < 0.0:
		anim.play("jump")
	else:
		anim.play("fall")


func duck_state() -> void:
	update_direction()

	velocity.x = 0.0


	if not Input.is_action_pressed("ui_down"):
		exit_duck_state()
		go_to_idle_state()
		return


func move() -> void:
	update_direction()

	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			SPEED
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
	elif direction < 0.0:
		anim.flip_h = true


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

		PlayerState.idle:
			idle_state()

		PlayerState.walk:
			walk_state()

		PlayerState.jump:
			jump_state()

		PlayerState.duck:
			duck_state()

	move_and_slide()

	if global_position.y > 900.0:
		get_tree().reload_current_scene()
