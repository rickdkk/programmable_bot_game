class_name LoopWidget
extends Control

signal loop_accepted(LoopWidget)
signal loop_declined

@export var loop_count: int = 1 :
	set = _set_loop_count
@export var max_loop_count: int = 5
@export var input_row_columns: int = 4
@export var empty_button_texture: AtlasTexture

@onready var loop_count_label: Label = $LoopCountRect/LoopCountLabel
@onready var up_button: TextureButton = $UpButton
@onready var down_button: TextureButton = $DownButton
@onready var accept_button: TextureButton = $AcceptButton
@onready var reject_button: TextureButton = $RejectButton
@onready var input_row: GridContainer = $InputRow
@onready var background_panel: Panel = $BackgroundPanel


func _ready() -> void:
	input_row.columns = input_row_columns
	_set_loop_count(loop_count)
	_add_input_row()
	_add_input_row()


func _add_input_row() -> void:
	for i in input_row_columns:
		var new_rect = TextureRect.new()
		new_rect.texture = empty_button_texture
		input_row.add_child(new_rect)

	accept_button.position.y += 194
	reject_button.position.y += 194
	background_panel.size.y += 194


func _on_up_button_pressed() -> void:
	loop_count = clamp(loop_count + 1, 1, max_loop_count)

	if loop_count == max_loop_count:
		up_button.disabled = true
	if loop_count > 1:
		down_button.disabled = false


func _on_down_button_pressed() -> void:
	loop_count = clamp(loop_count - 1, 1, max_loop_count)

	if loop_count != max_loop_count:
		up_button.disabled = false
	if loop_count == 1:
		down_button.disabled = true


func _on_reject_button_pressed() -> void:
	loop_declined.emit()
	self.queue_free()


func _on_accept_button_pressed() -> void:
	loop_accepted.emit(self)


func _set_loop_count(value: int):
	loop_count = value
	loop_count_label.text = "%d X" % loop_count
	if loop_count > 1:
		accept_button.disabled = false
	else:
		accept_button.disabled = true
