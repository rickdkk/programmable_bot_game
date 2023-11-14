extends CharacterBody3D
class_name Player

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed := 2.5
@export var angle_speed := 10.

const ROTATIONS := {Vector3.FORWARD: 0., Vector3.BACK: PI, Vector3.LEFT: 0.5 * PI, Vector3.RIGHT: 1.5 * PI, Vector3.ZERO: 0.}
var movement_velocity: Vector3
var rotation_direction: Vector3
var target_position: Vector3
var move_sequence: Array[Vector3]
var coins := 0

@onready var character_mesh := $Character as Node3D
@onready var particles_trail := $ParticlesTrail as CPUParticles3D
@onready var sound_footsteps := $SoundFootsteps as AudioStreamPlayer
@onready var animation := $Character/AnimationPlayer as AnimationPlayer
@onready var move_timer := $MoveDelayTimer as Timer


func _ready() -> void:
	move_sequence = [Vector3.FORWARD,
					 Vector3.FORWARD,
					 Vector3.FORWARD,
					 Vector3.LEFT,
					 Vector3.FORWARD,
					 Vector3.FORWARD,
					]
	target_position = Vector3.ZERO
	move_timer.start()


func _physics_process(delta):
	if not move_timer.is_stopped():
		return

	var delta_pos = position - target_position

	if delta_pos.length() <= 0.001 and move_sequence.size():
		rotation_direction = move_sequence.pop_front()
		target_position += rotation_direction
		move_timer.start()

	position = position.move_toward(target_position, movement_speed * delta)
	character_mesh.rotation.y = lerp_angle(character_mesh.rotation.y, ROTATIONS[rotation_direction], delta * angle_speed)

	handle_effects(delta_pos)


func handle_effects(delta_pos):
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
