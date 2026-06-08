extends Node
## Boot scene: chạy đầu tiên khi game launch.
## Tại đây có thể load ConfigFile, splash logo, sau đó chuyển sang MainMenu.

@onready var _timer: Timer = Timer.new()

func _ready() -> void:
	# Đợi 1 frame để các autoload khởi tạo xong
	# Sau đó chuyển sang MainMenu (dùng SceneLoader nếu có, hoặc change_scene trực tiếp)
	call_deferred("_go_to_main_menu")

func _go_to_main_menu() -> void:
	var target := "res://Scenes/MainMenu/main_menu.tscn"
	if Engine.has_singleton("SceneLoader") and get_node_or_null("/root/SceneLoader") != null:
		SceneLoader.load_scene(target)
	else:
		get_tree().change_scene_to_file(target)
