extends CanvasLayer

@onready var joystick = $Joystick
@onready var jump_button = $JumpButton
@onready var tip_visual = $Joystick/TipVisual

var joystick_radius: float
var touch_index = -1

signal on_joystick_move(vector)
signal on_jump_pressed

func _ready():
	joystick_radius = joystick.shape.radius * joystick.scale.x
	jump_button.pressed.connect(_on_jump_button_pressed)

func _input(event):
	if event is InputEventScreenTouch:
		var distance_to_joystick = joystick.global_position.distance_to(event.position)
		if distance_to_joystick < joystick_radius and touch_index == -1:
			touch_index = event.index
		elif event.is_released() and event.index == touch_index:
			touch_index = -1
			tip_visual.position = Vector2.ZERO
			emit_signal("on_joystick_move", Vector2.ZERO)
	
	if event is InputEventScreenDrag and event.index == touch_index:
		var vector_to_drag = event.position - joystick.global_position
		var clamped_vector = vector_to_drag.limit_length(joystick_radius)
		tip_visual.position = clamped_vector
		var output_vector = clamped_vector / joystick_radius
		emit_signal("on_joystick_move", output_vector)

func _on_jump_button_pressed():
	emit_signal("on_jump_pressed")