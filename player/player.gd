extends CharacterBody3D
class_name Player

signal coin_collected
signal sequence_finished

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed := 2.5
@export var angle_speed := 10.

@onready var character_mesh := $Character as Node3D
@onready var move_timer := $MoveDelayTimer as Timer
@onready var floor_detector := $FloorDetector as RayCast3D
@onready var particles_trail := $GPUParticlesTrail as GPUParticles3D
@onready var sound_footsteps := $SoundFootsteps as AudioStreamPlayer
@onready var animation := $Character/AnimationPlayer as AnimationPlayer
@onready var fall_animation_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer

enum MOVE_SET {FORWARD, LEFT, RIGHT}
const ROTATIONS := {Vector3.FORWARD: 0, Vector3.BACK: PI, Vector3.LEFT: 0.5 * PI, Vector3.RIGHT: 1.5 * PI}
const ROTATE_LEFT := {Vector3.FORWARD: Vector3.LEFT, Vector3.LEFT: Vector3.BACK, Vector3.BACK: Vector3.RIGHT, Vector3.RIGHT: Vector3.FORWARD}
const ROTATE_RIGHT := {Vector3.FORWARD: Vector3.RIGHT, Vector3.LEFT: Vector3.FORWARD, Vector3.BACK: Vector3.LEFT, Vector3.RIGHT: Vector3.BACK}

var movement_velocity: Vector3
var rotation_direction := Vector3.FORWARD
var target_position := Vector3.ZERO
var _move_sequence: Array[MOVE_SET]
var coins := 0
var dead := false
var received_moves := false


func _process(delta: float) -> void:
	if not move_timer.is_stopped() or not received_moves:  # This creates the feel of step-by-step movement
		animation.play("idle")
		return

	if not floor_detector.is_colliding() and not dead: # TODO
		_handle_falling()
		return

	# Move the player
	var delta_pos = position - target_position
	var delta_rot = abs(angle_difference(character_mesh.rotation.y, ROTATIONS[rotation_direction]))
	if delta_pos.length() <= 0.001 and delta_rot <= 0.1 and _move_sequence.size():
		_select_new_position()
		return
	elif delta_pos.length() <= 0.001 and delta_rot <= 0.1 and received_moves:  # sequence ran out
		received_moves = false
		if not dead:
			sequence_finished.emit()

	position = position.move_toward(target_position, movement_speed * delta)
	character_mesh.rotation.y = lerp_angle(character_mesh.rotation.y, ROTATIONS[rotation_direction], delta * angle_speed)

	_handle_effects(position - target_position)


func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))


func _select_new_position():
	var next_move = _move_sequence.pop_front()
	if next_move == MOVE_SET.FORWARD:
		move_timer.start()
		target_position += rotation_direction
	elif next_move == MOVE_SET.LEFT:
		move_timer.start(0.2)
		rotation_direction = ROTATE_LEFT[rotation_direction]
	elif next_move == MOVE_SET.RIGHT:
		move_timer.start(0.2)
		rotation_direction = ROTATE_RIGHT[rotation_direction]
	await move_timer.timeout
	SignalBus.player_selected_move.emit()


func _handle_falling():
	dead = true
	_move_sequence.clear()
	fall_animation_player.play("falling")
	SignalBus.player_died.emit()


func _handle_effects(delta_pos):
	if abs(delta_pos.x) > 0.01 or abs(delta_pos.z) > 0.01:
		animation.play("walk", 0.5)
		particles_trail.emitting = true
		sound_footsteps.stream_paused = false
	else:
		animation.play("idle", 0.5)
		particles_trail.emitting = false
		sound_footsteps.stream_paused = true


func add_sequence(new_sequence: Array[MOVE_SET]):
	_move_sequence = new_sequence
	received_moves = true
