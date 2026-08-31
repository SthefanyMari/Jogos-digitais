extends Area2D

@export_file("*.tscn") var destination_scene: String
@export var destination_spawn: StringName = &""
@export var door_texture: Texture2D
var changing: bool = false

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	$Door.texture = door_texture
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if changing or not body.is_in_group("player") or destination_scene.is_empty():
		return
	changing = true
	GameState.set_next_spawn(destination_spawn)
	get_tree().change_scene_to_file(destination_scene)
