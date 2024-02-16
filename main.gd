extends Node

@export var levels: Array[PackedScene]

@onready var intro_screen := $IntroScreen as IntroScreen

var current_level: Level
var current_level_score := 0
var current_level_scene: PackedScene
var coins: int

func _ready() -> void:
	SignalBus.coin_collected.connect(_on_coin_collected)


func _process(_delta: float) -> void:
	if not OS.is_debug_build():
		return

	# Action that allows you to skip levels during debugging...
	if Input.is_action_just_pressed("ui_cancel"):
		if is_instance_valid(intro_screen):  # check if intro_screen exists
			intro_screen.queue_free()
		load_next_level()


func load_next_level():
	if not levels.size():
		return
	if current_level:
		current_level.queue_free()

	current_level_score = 0
	current_level_scene = levels.pop_front()
	load_level(current_level_scene)


func reload_level():
	coins -= current_level_score
	current_level_score = 0
	current_level.queue_free()
	load_level(current_level_scene)


func load_level(scene: PackedScene):
	current_level = scene.instantiate() as Level
	current_level.finished.connect(load_next_level)
	current_level.player_death_finished.connect(reload_level)
	add_child(current_level)
	SignalBus.score_changed.emit(coins)


func _on_intro_screen_play_button_pressed() -> void:
	intro_screen.queue_free()
	load_next_level()


func _on_coin_collected():
	coins += 1
	current_level_score += 1
	SignalBus.score_changed.emit(coins)
