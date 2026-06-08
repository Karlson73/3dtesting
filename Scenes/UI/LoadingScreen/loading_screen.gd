extends CanvasLayer
## LoadingScreen: hiển thị khi SceneLoader đang load scene.

@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var status_label: Label = $Control/StatusLabel

func _ready() -> void:
	if get_node_or_null("/root/SceneLoader") != null:
		SceneLoader.scene_load_progress.connect(_on_progress)
		SceneLoader.scene_load_started.connect(_on_started)
		SceneLoader.scene_load_finished.connect(_on_finished)
	# Ẩn ngay từ đầu nếu không phải do SceneLoader gọi
	progress_bar.value = 0.0

func _on_progress(p: float) -> void:
	progress_bar.value = p * 100.0

func _on_started(path: String) -> void:
	status_label.text = "Loading: %s" % path.get_file()
	progress_bar.value = 0.0

func _on_finished(_path: String) -> void:
	progress_bar.value = 100.0
