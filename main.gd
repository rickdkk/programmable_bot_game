extends Node

var levels := [preload("res://levels/level_01.tscn"),
			   preload("res://levels/level_02.tscn"),
			   preload("res://levels/level_03.tscn")]
var current_level: Level
var current_level_scene: PackedScene

@onready var intro_screen: CanvasLayer = $IntroScreen


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


func _on_intro_screen_play_button_pressed() -> void:
	intro_screen.hide()
	load_next_level()
