extends Node3D

@onready var victory_sound := $VictorySound as AudioStreamPlayer

func _on_flag_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		victory_sound.play()
	await victory_sound.finished
	get_tree().reload_current_scene()
