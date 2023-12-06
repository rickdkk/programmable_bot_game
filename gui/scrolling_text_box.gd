extends TextureRect
class_name ScrollingDialogBox

signal buffer_empty

@onready var _text_label := $RichTextLabel as RichTextLabel
@onready var next_sprite := $NextSprite as Sprite2D
@onready var typing_sound: AudioStreamPlayer = $TypingSound

var text_buffer: Array[String] = []


func _process(_delta: float) -> void:
	if not visible:
		return

	if _text_label.visible_ratio == 1.0:
		next_sprite.show()
	else:
		next_sprite.hide()

	if Input.is_action_just_pressed("ui_accept") and _text_label.visible_ratio == 1.0:
		if not text_buffer:
			self.hide()
			buffer_empty.emit()
		else:
			_display_next_text()


func add_new_text(text: String, display_next: bool = false):
	text_buffer.append(text)

	if display_next:
		_display_next_text()
		self.show()


func _display_next_text():
	var next_text: String = text_buffer.pop_front()
	_text_label.text = next_text
	_text_label.visible_ratio = 0
	typing_sound.play()
	var tween = create_tween()
	tween.tween_property(_text_label, "visible_ratio", 1.0, 1.5)
	typing_sound.stop()
