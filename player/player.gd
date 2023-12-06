extends CharacterBody3D
class_name Player

signal coin_collected
signal sequence_finished
signal player_died

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed := 2.5
@export var angle_speed := 10.

@onready var character_mesh := $Character as Node3D
@onready var particles_trail := $GPUParticlesTrail as GPUParticles3D
@onready var sound_footsteps := $SoundFootsteps as AudioStreamPlayer
@onready var animation := $Character/AnimationPlayer as AnimationPlayer
@onready var move_timer := $MoveDelayTimer as Timer
@onready var floor_detector := $FloorDetector as RayCast3D

const ROTATIONS := {Vector3.FORWARD: 0., Vector3.BACK: PI, Vector3.LEFT: 0.5 * PI, Vector3.RIGHT: 1.5 * PI, Vector3.ZERO: 0.}
var movement_velocity: Vector3
var rotation_direction := Vector3.FORWARD
var target_position := Vector3.ZERO
var _move_sequence: Array[Vector3]
var coins := 0
var moving := false
var dead := false


func _physics_process(delta):
	if not move_timer.is_stopped():  # This creates the feel of step-by-step movement
		return

	if not floor_detector.is_colliding() and not dead: # TODO
		_handle_falling()
		return

	# Move the player
	var delta_pos = position - target_position
	_select_new_position(delta_pos)
	position = position.move_toward(target_position, movement_speed * delta)
	character_mesh.rotation.y = lerp_angle(character_mesh.rotation.y, ROTATIONS[rotation_direction], delta * angle_speed)

	_handle_effects(delta_pos)


func _select_new_position(delta_pos: Vector3):
	if delta_pos.length() <= 0.001 and _move_sequence.size():
		rotation_direction = _move_sequence.pop_front()
		target_position += rotation_direction
		move_timer.start()
	elif delta_pos.length() <= 0.001 and moving == true:
		moving = false
		if not dead:
			sequence_finished.emit()


func _handle_falling():
	dead = true
	_move_sequence.clear()
	player_died.emit()
	animation.play("jump")


func _handle_effects(delta_pos):
	if abs(delta_pos.x) > 0.01 or abs(delta_pos.z) > 0.01:
		animation.play("walk", 0.5)
		particles_trail.emitting = true
		sound_footsteps.stream_paused = false
	else:
		animation.play("idle", 0.5)
		particles_trail.emitting = false
		sound_footsteps.stream_paused = true


func collect_coin():
	coins += 1
	coin_collected.emit(coins)


func add_sequence(new_sequence: Array[Vector3]):
	_move_sequence = new_sequence
	moving = true
