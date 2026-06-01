extends Node

@onready var player = $Player
@onready var touch_controls = $TouchControls

func _ready():
	touch_controls.on_joystick_move.connect(_on_joystick_move)
	touch_controls.on_jump_pressed.connect(_on_jump_pressed)

func _on_joystick_move(vector):
	player.joystick_vector = vector

func _on_jump_pressed():
	player.is_jump_pressed = true