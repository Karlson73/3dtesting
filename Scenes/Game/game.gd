extends Node

@onready var player = $Player
@onready var controls = $TouchControls

func _ready():
	controls.on_joystick_move.connect(func(v): player.joystick_vector = v)
	controls.on_jump_pressed.connect(func(): player.is_jump = true)
	controls.on_jump_released.connect(func(): player.is_jump = false)
