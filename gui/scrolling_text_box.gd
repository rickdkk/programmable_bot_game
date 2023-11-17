extends TextureRect
class_name ScrollingDialogBox

@onready var _text_label := $RichTextLabel as RichTextLabel
@onready var next_sprite := $NextSprite as Sprite2D

var text_buffer: Array[String] = []


func _process(delta: float) -> void:
	if _text_label.visible_ratio == 1.0:
		next_sprite.show()
	else:
		next_sprite.hide()

	if Input.is_action_just_pressed("ui_accept"):
		if not text_buffer:
			self.hide()
		else:
			_display_next_text()


func add_new_text(text: String):
	text_buffer.append(text)

	if not self.visible:
		_display_next_text()
		self.show()


func _display_next_text():
	var next_text: String = text_buffer.pop_front()
	_text_label.text = next_text
	_text_label.visible_ratio = 0
	var tween = create_tween()
	tween.tween_property(_text_label, "visible_ratio", 1.0, 1.5)
