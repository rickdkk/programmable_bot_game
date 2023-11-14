extends Area3D
class_name Coin

var time := 0.0

@onready var audio_player := $AudioStreamPlayer as AudioStreamPlayer

func _on_body_entered(body):
	if body.has_method("collect_coin"):
		body.collect_coin()
		audio_player.play()
		self.visible = false

		await audio_player.finished
		call_deferred("queue_free")


func _process(delta):
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * 5) * 0.5) * delta # Sine movement

	time += delta
