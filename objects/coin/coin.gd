extends Area3D
class_name Coin

@onready var audio_player := $AudioStreamPlayer as AudioStreamPlayer

var time := 0.0


func _on_body_entered(body):
	if body.name == "Player":
		SignalBus.coin_collected.emit()
		self.visible = false
		audio_player.play()
		await audio_player.finished
		queue_free()


func _process(delta):
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * 5) * 0.5) * delta # Sine movement
	time += delta
