extends Node3D
class_name Level

signal finished
signal player_died

@export var dialog_resource: DialogResource  ## Start and end dialog that should be played in the scrolling text box
@export var level_name: String  ## Name you want to appear in the HUD

@onready var victory_sound := $VictorySound as AudioStreamPlayer
@onready var lose_sound := $LoseSound as AudioStreamPlayer
@onready var player := $Player as Player
@onready var hud: HUD = $HUD

var level_finished := false


func _ready() -> void:
	hud.set_level_text(level_name if level_name else str(name))


func _on_flag_body_entered(body: Node3D) -> void:
	level_finished = true
	if body.name == "Player":
		victory_sound.play()
	await victory_sound.finished
	finished.emit()


func _on_hud_go_button_pressed(current_actions: Array[Player.MOVE_SET]) -> void:
	player.add_sequence(current_actions)


func _on_player_sequence_finished() -> void:
	if not level_finished:
		_lose()


func _on_player_player_died() -> void:
	if not level_finished:
		_lose()


func _lose() -> void:
	if level_finished:
		return
	lose_sound.play()
	await lose_sound.finished
	player_died.emit()
