extends Node3D

@onready var victory_sound := $VictorySound as AudioStreamPlayer
@onready var lose_sound := $LoseSound as AudioStreamPlayer
@onready var player := $Player as Player

enum MOVE_SET {FORWARD, BACK, LEFT, RIGHT}

var moves := {MOVE_SET.FORWARD: Vector3.FORWARD, MOVE_SET.BACK: Vector3.BACK,
			  MOVE_SET.LEFT: Vector3.LEFT, MOVE_SET.RIGHT: Vector3.RIGHT}


func _on_flag_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		victory_sound.play()
	await victory_sound.finished
	get_tree().reload_current_scene()


func _on_hud_go_button_pressed(current_actions: Array[MOVE_SET]) -> void:
	var move_sequence: Array[Vector3] = []
	for action in current_actions:
		move_sequence.append(moves[action])
	player.add_sequence(move_sequence)


func _on_player_sequence_finished() -> void:
	lose_sound.play()
	await lose_sound.finished
	get_tree().reload_current_scene()
	print("here")


func _on_player_player_died() -> void:
	lose_sound.play()
	await lose_sound.finished
	get_tree().reload_current_scene()
	print("there")
