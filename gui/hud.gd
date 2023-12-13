extends CanvasLayer
class_name HUD

signal go_button_pressed(current_actions: Array[Player.MOVE_SET])

@onready var coin_label := $Coins as Label
@onready var fps_label := $FPSLabel as Label
@onready var level_label := $LevelLabel as Label
@onready var message_label := $MessageLabel as Label
@onready var button_box := $InputHBox as HBoxContainer
@onready var go_button := $InputHBox/GoButton as TextureButton
@onready var button_sound := $ButtonSound as AudioStreamPlayer
@onready var message_timer := $MessageLabel/MessageTimer as Timer
@onready var delete_button := $InputHBox/DeleteButton as TextureButton
@onready var actions_box := $ScrollContainer/ActionsVBox as VBoxContainer
@onready var scrolling_text_box := $ScrollingTextBox as ScrollingDialogBox

const SPRITES = {Player.MOVE_SET.FORWARD: preload("res://gui/resources/up_arrow.tres"),
				 Player.MOVE_SET.LEFT: preload("res://gui/resources/left_arrow.tres"),
				 Player.MOVE_SET.RIGHT: preload("res://gui/resources/right_arrow.tres")}
var actions: Array[Player.MOVE_SET]
var current_action := -1


func _ready() -> void:
	SignalBus.score_changed.connect(_on_player_coin_collected)
	SignalBus.player_selected_move.connect(_flash_current_action)
	message_timer.timeout.connect(_clear_message)


func _process(_delta: float) -> void:
	fps_label.set_text("FPS %d" % Engine.get_frames_per_second())


func _on_player_coin_collected(coins: int) -> void:
	coin_label.text = str(coins)


func add_arrow(action: Player.MOVE_SET):
	button_sound.play()
	var new_rect = TextureRect.new()
	new_rect.texture = SPRITES[action]
	new_rect.flip_h = action == Player.MOVE_SET.LEFT
	actions_box.add_child(new_rect)
	actions_box.move_child(new_rect, 0)
	actions.append(action)

	go_button.disabled = false
	delete_button.disabled = false


func disable_input():
	for button in button_box.get_children():
		button.disabled = true


func enable_input():
	for button in button_box.get_children():
		button.disabled = false

#region Handle button presses
func _on_delete_button_pressed() -> void:
	if actions_box.get_child_count():
		actions_box.get_child(0).queue_free()
		actions.pop_back()

	if not actions.size():
		go_button.disabled = true
		delete_button.disabled = true


func _on_left_button_pressed() -> void:
	add_arrow(Player.MOVE_SET.LEFT)


func _on_right_button_pressed() -> void:
	add_arrow(Player.MOVE_SET.RIGHT)


func _on_up_button_pressed() -> void:
	add_arrow(Player.MOVE_SET.FORWARD)


func _on_go_button_pressed() -> void:
	disable_input()
	go_button_pressed.emit(actions)
#endregion

func display_text(text_buffer: Array[String]) -> void:
	disable_input()
	for text in text_buffer:
		scrolling_text_box.add_new_text(text)
	scrolling_text_box.show()
	scrolling_text_box.display_next_text()


func display_message(text: String, duration: float = 2.0) -> void:
	message_label.text = text
	message_timer.start(duration)


func _clear_message() -> void:
	message_label.text = ""


func set_level_text(text: String) -> void:
	level_label.text = text


func flash_ui_element(element, n_flashes := 2) -> void:
	var tween = get_tree().create_tween()
	for _idx in n_flashes:
		tween.tween_property(element, "modulate:a", 0, 0.1)
		tween.tween_property(element, "modulate:a", 1, 0.1)
	tween.play()


func _flash_current_action() -> void:
	var target = actions_box.get_child(current_action)
	flash_ui_element(target)
	current_action -= 1


func _on_scrolling_text_box_buffer_empty() -> void:
	enable_input()
