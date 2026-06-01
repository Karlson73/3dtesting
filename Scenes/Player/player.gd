extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ACCELERATION = 8.0
const FRICTION = 10.0
const MOUSE_SENSITIVITY = 0.002

@onready var pivot = $Pivot

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var cam_touch = -1
var joystick_vector = Vector2()
var is_jump = false

func _input(e):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		cam_touch = -2 if e.pressed and e.position.x > get_viewport().get_visible_rect().size.x / 2 else -1 if not e.pressed and cam_touch == -2 else cam_touch
	elif e is InputEventMouseMotion and cam_touch == -2:
		_cam_rotate(e.relative)
	elif e is InputEventScreenTouch:
		cam_touch = e.index if e.pressed and e.position.x > get_viewport().get_visible_rect().size.x / 2 else -1 if not e.pressed and e.index == cam_touch else cam_touch
	elif e is InputEventScreenDrag and e.index == cam_touch:
		_cam_rotate(e.relative)

func _cam_rotate(r):
	rotate_y(-r.x * MOUSE_SENSITIVITY)
	pivot.rotate_x(-r.y * MOUSE_SENSITIVITY)
	pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var d = (transform.basis * Vector3(joystick_vector.x, 0, joystick_vector.y)).normalized()
	if d:
		velocity.x = lerp(velocity.x, d.x * SPEED, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, d.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)
	move_and_slide()
