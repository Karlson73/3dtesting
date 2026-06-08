extends Node
## GameManager (Autoload)
## Quản lý trạng thái toàn cục của game: pause, score, scene state, save/load.

signal game_paused
signal game_resumed
signal score_changed(new_score: int)
signal level_changed(new_level: int)

var is_paused: bool = false
var current_level: int = 1
var current_score: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game() -> void:
	if is_paused:
		return
	is_paused = true
	get_tree().paused = true
	game_paused.emit()

func resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	game_resumed.emit()

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func add_score(amount: int) -> void:
	current_score += amount
	score_changed.emit(current_score)

func set_level(level: int) -> void:
	current_level = level
	level_changed.emit(current_level)

func reset() -> void:
	current_score = 0
	current_level = 1
	is_paused = false
	get_tree().paused = false
