extends CanvasLayer
class_name IntroScreen

signal play_button_pressed

@export var intro_dialog: DialogResource

@onready var scrolling_text_box := $ScrollingTextBox as ScrollingDialogBox
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var play_button := $PlayButton as TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scrolling_text_box.set_process_input(false)
	animation_player.play("start_game")
	await animation_player.animation_finished

	scrolling_text_box.buffer_empty.connect(_on_instruction_finished)
	scrolling_text_box.add_new_text(intro_dialog.start_dialog[0], true)
	for text in intro_dialog.start_dialog.slice(1):
		scrolling_text_box.add_new_text(text)
	scrolling_text_box.set_process_input(true)


func _on_instruction_finished():
	play_button.disabled = false


func _on_play_button_pressed() -> void:
	play_button_pressed.emit()  # delegate up
	queue_free()
