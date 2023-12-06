extends Node3D

@export_group("Properties")
@export var target: Player

@export_group("Zoom")
@export var zoom_minimum := 8.0
@export var zoom_maximum := 4.0
@export var zoom_speed := 20.0

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom = 6

@onready var camera = $Camera

func _ready():
	camera_rotation = rotation_degrees # Initial rotation


func _physics_process(delta):
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	handle_input(delta)


func handle_input(delta):
	# Rotation
	var input := Vector3.ZERO

	input.y = Input.get_axis("camera_left", "camera_right")
	input.x = Input.get_axis("camera_up", "camera_down")

	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, -10)

	# Zooming
	var zoom_direction = 0
	if Input.is_action_just_pressed("zoom_out"):
		zoom_direction = 1
	elif Input.is_action_just_pressed("zoom_in"):
		zoom_direction = -1
	zoom += zoom_direction * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)
