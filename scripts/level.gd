extends Node2D

@export var map_width: int = 1536
@export var map_height: int = 432
@export var spawn_position: Vector2 = Vector2(64, 160)

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var spawn_marker: StringName = GameState.consume_spawn()
	if spawn_marker != &"" and has_node(NodePath(spawn_marker)):
		player.position = get_node(NodePath(spawn_marker)).position
	else:
		player.position = spawn_position

	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_width
	camera.limit_bottom = map_height
