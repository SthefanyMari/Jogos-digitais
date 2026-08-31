extends Node

var next_spawn: StringName = &""

func set_next_spawn(marker_name: StringName) -> void:
	next_spawn = marker_name

func consume_spawn() -> StringName:
	var marker_name: StringName = next_spawn
	next_spawn = &""
	return marker_name
