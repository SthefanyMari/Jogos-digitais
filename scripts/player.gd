extends CharacterBody2D

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
