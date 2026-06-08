extends CanvasLayer

@onready var up_btn = $Up
@onready var down_btn = $Down
@onready var left_btn = $Left
@onready var right_btn = $Right
@onready var jump_btn = $Jump

signal on_joystick_move(vector)
signal on_jump_pressed
signal on_jump_released

var up := false
var down := false
var left := false
var right := false
var jumping := false

func _ready():
	_resize()
	get_tree().root.size_changed.connect(_resize)

func _resize():
	var vp = get_viewport().get_visible_rect().size
	var s = min(vp.x, vp.y) / 480.0
	var d = vp.y * 0.11

	var cx = d * 2.5
	var cy = vp.y * 0.55

	up_btn.position = Vector2(cx, cy - d * 1.1)
	down_btn.position = Vector2(cx, cy + d * 1.1)
	left_btn.position = Vector2(cx - d * 1.0, cy)
	right_btn.position = Vector2(cx + d * 1.0, cy)
	jump_btn.position = Vector2(vp.x - d * 1.2, vp.y * 0.55)

	up_btn.scale = Vector2(s, s)
	down_btn.scale = Vector2(s, s)
	left_btn.scale = Vector2(s, s)
	right_btn.scale = Vector2(s, s)
	jump_btn.scale = Vector2(s * 1.3, s * 1.3)

func _input(e):
	if e is InputEventMouseButton or e is InputEventScreenTouch:
		_on_press(e.pressed, e.position)
	if e is InputEventMouseMotion or e is InputEventScreenDrag:
		if e is InputEventMouseMotion and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return
		_on_drag(e.position)

func _on_press(pressed, pos):
	if _hit(jump_btn, pos):
		if pressed and not jumping:
			jumping = true
			emit_signal("on_jump_pressed")
		elif not pressed and jumping:
			jumping = false
			emit_signal("on_jump_released")
		return
	if pressed:
		if _hit(up_btn, pos): up = true
		if _hit(down_btn, pos): down = true
		if _hit(left_btn, pos): left = true
		if _hit(right_btn, pos): right = true
	else:
		if _hit(up_btn, pos): up = false
		if _hit(down_btn, pos): down = false
		if _hit(left_btn, pos): left = false
		if _hit(right_btn, pos): right = false
	_move()

func _on_drag(pos):
	up = _hit(up_btn, pos)
	down = _hit(down_btn, pos)
	left = _hit(left_btn, pos)
	right = _hit(right_btn, pos)
	_move()

func _hit(btn, pos) -> bool:
	var r = btn.shape.radius * btn.scale.x
	return btn.global_position.distance_to(pos) <= r

func _move():
	var v := Vector2()
	if right: v.x += 1
	if left: v.x -= 1
	if down: v.y += 1
	if up: v.y -= 1
	emit_signal("on_joystick_move", v.normalized())
