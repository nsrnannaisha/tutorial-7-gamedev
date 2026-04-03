extends CharacterBody3D

@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3
@export var sprint_speed: float = 18.0
@export var crouch_speed: float = 4.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var state_label: Label = $CanvasLayer/HUD/StateLabel

var camera_x_rotation: float = 0.0
var is_crouching: bool = false
var normal_height: float = 2.0
var crouch_height: float = 1.0
var normal_head_y: float = 0.9
var crouch_head_y: float = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	var current_speed = speed

	if Input.is_action_pressed("sprint") and not is_crouching:
		current_speed = sprint_speed

	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
		collision.shape.height = crouch_height
		head.position.y = crouch_head_y

	if Input.is_action_just_released("crouch"):
		is_crouching = false
		collision.shape.height = normal_height
		head.position.y = normal_head_y
		
	var movement_vector = Vector3.ZERO

	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()

	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_power
	
	if Input.is_action_pressed("sprint") and not is_crouching:
		state_label.text = "SPRINT"
	elif is_crouching:
		state_label.text = "CROUCH"
	else:
		state_label.text = ""
		
	move_and_slide()
