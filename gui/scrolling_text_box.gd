extends TextureRect
class_name ScrollingDialogBox

signal buffer_empty

## Scrolling speed in characters per second
@export var scrolling_speed := 40.0
@export var minimum_duration := 0.8

@onready var _text_label := $RichTextLabel as RichTextLabel
@onready var next_sprite := $NextSprite as Sprite2D
@onready var typing_sound := $TypingSound as AudioStreamPlayer

var text_buffer: Array[String] = []


func _input(event: InputEvent) -> void:
	var button_pressed = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			button_pressed = true
	elif event.is_action_pressed("ui_accept"):
		button_pressed = true

	if  button_pressed and _text_label.visible_ratio == 1.0:
		if not text_buffer:
			self.hide()
			buffer_empty.emit()
		else:
			display_next_text()


func add_new_text(text: String, display_next: bool = false):
	text_buffer.append(text)

	if display_next:
		display_next_text()
		self.show()


func display_next_text():
	next_sprite.hide()
	typing_sound.play()

	var next_text: String = text_buffer.pop_front()
	_text_label.text = next_text
	_text_label.visible_ratio = 0

	var duration = max(minimum_duration, len(next_text) / scrolling_speed)
	var tween = create_tween()
	tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
	await tween.finished

	next_sprite.show()
	typing_sound.stop()
