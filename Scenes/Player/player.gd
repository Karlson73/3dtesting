extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

# Tách riêng gia tốc và ma sát để kiểm soát tốt hơn
const ACCELERATION = 8.0
const FRICTION = 10.0

@onready var pivot = $Pivot

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var touch_index = -1
var joystick_vector = Vector2()
var is_jump_pressed = false

func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Không cần thiết cho mobile
	pass

func _input(event):
	# Xoay camera bằng cách vuốt màn hình
	if event is InputEventScreenTouch and event.pressed:
		# Chỉ xử lý khi vuốt ở nửa bên phải màn hình
		if touch_index == -1 and event.position.x > get_viewport().get_visible_rect().size.x / 2:
			touch_index = event.index
	elif event is InputEventScreenTouch and not event.pressed and event.index == touch_index:
		touch_index = -1
	
	if event is InputEventScreenDrag and event.index == touch_index:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Xử lý nhảy từ nút ảo
	if is_jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jump_pressed = false # Reset sau khi nhảy

	# Lấy hướng di chuyển từ joystick ảo
	var input_dir = joystick_vector
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)

	
	move_and_slide()