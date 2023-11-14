extends Area3D
class_name Coin

var time := 0.0


func _on_body_entered(body):
	if body.has_method("collect_coin"):
		body.collect_coin()
		Audio.play("res://sounds/coin.ogg") # Play sound

		call_deferred("queue_free")


func _process(delta):
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * 5) * 1) * delta # Sine movement

	time += delta
