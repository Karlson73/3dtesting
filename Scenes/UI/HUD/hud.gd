extends CanvasLayer
## HUD: hiển thị score, FPS, nút pause.

@onready var score_label: Label = $Control/TopBar/ScoreLabel
@onready var fps_label: Label = $Control/TopBar/FpsLabel
@onready var pause_button: Button = $Control/TopBar/PauseButton

var _fps_update_acc: float = 0.0

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	if get_node_or_null("/root/GameManager") != null:
		GameManager.score_changed.connect(_on_score_changed)
		score_label.text = "Score: 0"

func _process(delta: float) -> void:
	_fps_update_acc += delta
	if _fps_update_acc >= 0.5:
		_fps_update_acc = 0.0
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_pause_pressed() -> void:
	if get_node_or_null("/root/GameManager") != null:
		GameManager.toggle_pause()
