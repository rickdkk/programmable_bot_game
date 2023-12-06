extends Node

var levels := [preload("res://levels/level_01.tscn"),
			   preload("res://levels/level_02.tscn"),
			   preload("res://levels/level_03.tscn")]
var current_level: Level
var current_level_scene: PackedScene
var coins: int

@onready var intro_screen: IntroScreen = $IntroScreen as IntroScreen


func _ready() -> void:
	SignalBus.coin_collected.connect(_on_coin_collected)


func _process(_delta: float) -> void:
	if not OS.is_debug_build():
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if is_instance_valid(intro_screen):  # check if intro_screen exists
			intro_screen.queue_free()
		load_next_level()


func load_next_level():
	if not levels.size():
		return
	if current_level:
		remove_child(current_level)

	current_level_scene = levels.pop_front()
	load_level(current_level_scene)


func reload_level():
	remove_child(current_level)
	load_level(current_level_scene)


func load_level(scene: PackedScene):
	current_level = scene.instantiate()
	current_level.finished.connect(load_next_level)
	current_level.player_died.connect(reload_level)
	add_child(current_level)
	SignalBus.score_changed.emit(coins)


func _on_intro_screen_play_button_pressed() -> void:
	intro_screen.queue_free()
	load_next_level()


func _on_coin_collected():
	coins += 1
	SignalBus.score_changed.emit(coins)
