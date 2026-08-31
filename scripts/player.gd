extends CharacterBody2D

<<<<<<< HEAD
const SPEED: float = 125.0
const JUMP_SPEED: float = -430.0
const GRAVITY: float = 900.0

const IDLE: Texture2D = preload("res://assets/player/idle.png")
const RUN: Texture2D = preload("res://assets/player/run.png")
const JUMP: Texture2D = preload("res://assets/player/jump.png")
const FALL: Texture2D = preload("res://assets/player/fall.png")

@onready var sprite: Sprite2D = $Sprite2D
var anim_time: float = 0.0
var current_anim: String = ""

func _ready() -> void:
	add_to_group("player")
	_set_animation("idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_SPEED
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0
	direction = clampf(direction, -1.0, 1.0)
	velocity.x = direction * SPEED if direction != 0.0 else move_toward(velocity.x, 0.0, SPEED * 5.0 * delta)
	if direction != 0.0:
		sprite.flip_h = direction < 0.0
	move_and_slide()
	if not is_on_floor():
		_set_animation("jump" if velocity.y < 0.0 else "fall")
	elif abs(velocity.x) > 1.0:
		_set_animation("run")
	else:
		_set_animation("idle")
	_animate(delta)
	if global_position.y > 900.0:
		get_tree().reload_current_scene()

func _set_animation(anim_name: String) -> void:
	if current_anim == anim_name:
		return
	current_anim = anim_name
	anim_time = 0.0
	match anim_name:
		"idle":
			sprite.texture = IDLE
			sprite.hframes = 5
		"run":
			sprite.texture = RUN
			sprite.hframes = 6
		"jump":
			sprite.texture = JUMP
			sprite.hframes = 1
		"fall":
			sprite.texture = FALL
			sprite.hframes = 2
	sprite.frame = 0

func _animate(delta: float) -> void:
	anim_time += delta
	var fps: float = 9.0 if current_anim == "run" else 6.0
	var count: int = maxi(sprite.hframes, 1)
	sprite.frame = int(anim_time * fps) % count
=======
const SPEED: float = 80.0
const JUMP_VELOCITY: float = -300.0
const LIMITE_QUEDA: float = 350.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ponto_de_retorno: Vector2


func _ready() -> void:
	ponto_de_retorno = global_position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	_atualizar_animacao(direction)
	move_and_slide()

	if global_position.y > LIMITE_QUEDA:
		reiniciar()


func _atualizar_animacao(direction: float) -> void:
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0.0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func reiniciar() -> void:
	global_position = ponto_de_retorno
	velocity = Vector2.ZERO
>>>>>>> 8cbeb044b4992e46cc9a24c86627522d8a0a78a6
