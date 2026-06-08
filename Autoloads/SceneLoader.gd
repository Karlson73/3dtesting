extends Node
## SceneLoader (Autoload)
## Load scene có loading screen, kèm progress.

signal scene_load_started(path: String)
signal scene_load_progress(progress: float) ## 0.0 → 1.0
signal scene_load_finished(path: String)

const LOADING_SCREEN_PATH := "res://Scenes/UI/LoadingScreen/loading_screen.tscn"

var _is_loading: bool = false

func load_scene(path: String) -> void:
	if _is_loading:
		push_warning("SceneLoader: already loading a scene.")
		return
	if not ResourceLoader.exists(path):
		push_error("SceneLoader: scene not found: %s" % path)
		return
	_is_loading = true
	scene_load_started.emit(path)
	_show_loading_screen()
	# Defer to next frame so loading screen has a chance to render
	call_deferred("_do_load", path)

func _do_load(path: String) -> void:
	# Use thread if available, otherwise use background load
	var use_subthreads := true
	var loader := ResourceLoader.load_threaded_request(path, "", use_subthreads)
	if loader == OK:
		_poll_threaded_load(path)
	else:
		# Fallback: synchronous load
		_perform_synchronous_load(path)

func _poll_threaded_load(path: String) -> void:
	var t := get_tree().create_timer(0.05, true, false, true)
	t.timeout.connect(func() -> void:
		var progress := []
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		scene_load_progress.emit(progress[0] if progress.size() > 0 else 0.0)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				_poll_threaded_load(path)
			ResourceLoader.THREAD_LOAD_LOADED:
				_finalize_load(path)
			_:
				push_error("SceneLoader: failed to load %s" % path)
				_is_loading = false
	)

func _perform_synchronous_load(path: String) -> void:
	var resource := load(path)
	scene_load_progress.emit(1.0)
	if resource is PackedScene:
		_apply_scene(resource, path)
	_is_loading = false

func _finalize_load(path: String) -> void:
	var resource := ResourceLoader.load_threaded_get(path)
	if resource is PackedScene:
		_apply_scene(resource, path)
	_is_loading = false

func _apply_scene(packed: PackedScene, path: String) -> void:
	get_tree().change_scene_to_packed(packed)
	scene_load_finished.emit(path)
	_hide_loading_screen()

func _show_loading_screen() -> void:
	if not ResourceLoader.exists(LOADING_SCREEN_PATH):
		return
	var loading_screen := load(LOADING_SCREEN_PATH) as PackedScene
	if loading_screen == null:
		return
	var inst := loading_screen.instantiate()
	var tree := get_tree()
	# Add to root so it survives the scene change
	if tree.current_scene:
		tree.root.add_child.call_deferred(inst)
	else:
		tree.root.add_child(inst)
	inst.set_meta("is_loading_screen", true)

func _hide_loading_screen() -> void:
	for child in get_tree().root.get_children():
		if child.has_meta("is_loading_screen"):
			child.queue_free()
