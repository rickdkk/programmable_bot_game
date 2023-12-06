extends CanvasLayer
class_name HUD

signal actions_changed(current_actions: Array[Player.MOVE_SET])
signal go_button_pressed(current_actions: Array[Player.MOVE_SET])

@onready var fps_label := $FPSLabel as Label
@onready var coin_label := $Coins as Label
@onready var actions_box := $ScrollContainer/ActionsVBox as VBoxContainer
@onready var button_box := $InputHBox as HBoxContainer
@onready var button_sound := $ButtonSound as AudioStreamPlayer
@onready var go_button := $InputHBox/GoButton as TextureButton
@onready var delete_button := $InputHBox/DeleteButton as TextureButton
@onready var scrolling_text_box: TextureRect = $ScrollingTextBox as ScrollingDialogBox
@onready var level_label: Label = $LevelLabel

const SPRITES = {Player.MOVE_SET.FORWARD: preload("res://gui/resources/up_arrow.tres"),
				 Player.MOVE_SET.LEFT: preload("res://gui/resources/left_arrow.tres"),
				 Player.MOVE_SET.RIGHT: preload("res://gui/resources/right_arrow.tres")}
var actions: Array[Player.MOVE_SET]


func _ready() -> void:
	SignalBus.score_changed.connect(_on_player_coin_collected)


func _process(_delta: float) -> void:
	fps_label.set_text("FPS %d" % Engine.get_frames_per_second())


func _on_player_coin_collected(coins: int) -> void:
	coin_label.text = str(coins)


func add_arrow(action: Player.MOVE_SET):
	var new_rect = TextureRect.new()
	new_rect.texture = SPRITES[action]
	new_rect.flip_h = action == Player.MOVE_SET.LEFT
	actions_box.add_child(new_rect)
	actions_box.move_child(new_rect, 0)

	actions.append(action)
	actions_changed.emit(actions)

	go_button.disabled = false
	delete_button.disabled = false
	button_sound.play()


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
		actions_changed.emit(actions)

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


func set_level_text(text: String) -> void:
	level_label.text = text
