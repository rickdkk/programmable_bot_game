extends CanvasLayer
class_name IntroScreen

signal play_button_pressed

@onready var scrolling_text_box: ScrollingDialogBox = $ScrollingTextBox as ScrollingDialogBox
@onready var play_button: TextureButton = $PlayButton as TextureButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("start_game")
	await animation_player.animation_finished

	scrolling_text_box.buffer_empty.connect(_on_instruction_finished)
	scrolling_text_box.add_new_text("Hallo allemaal!

In dit spel gaan we jullie iets vertellen over program-meren en kunstmatige intelligentie.", true)
	scrolling_text_box.add_new_text("Het is tegenwoordig erg druk in de zorg! Er zijn heel veel patiënten, maar niet zo veel dokters.

We willen zo veel mogelijk mensen helpen..")
	scrolling_text_box.add_new_text("In dit spel gaan we een robot maken die de dokters kan helpen. De robot is alleen nog niet zo slim...

Hier hebben we jullie hulp voor nodig!")
	scrolling_text_box.add_new_text("Jullie gaan de robot helpen om zijn weg door het ziekenhuis te vinden. Je kan met de muis op de knoppen drukken. Vraag de
docent voor hulp als je vast zit!")
	scrolling_text_box.add_new_text("Aan de slag!")


func _on_instruction_finished():
	play_button.disabled = false


func _on_play_button_pressed() -> void:
	play_button_pressed.emit()  # delegate up
