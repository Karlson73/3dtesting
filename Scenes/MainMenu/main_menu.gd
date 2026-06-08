extends Control
## MainMenu scene: menu chính của game.
## Có panel Settings với 2 slider tăng/giảm âm lượng (Music & SFX).

# Main panel references
@onready var main_panel: Control = $MainPanel
@onready var start_button: Button = $MainPanel/StartButton
@onready var settings_button: Button = $MainPanel/SettingsButton
@onready var quit_button: Button = $MainPanel/QuitButton
@onready var title_label: Label = $MainPanel/TitleLabel

# Settings panel references
@onready var settings_panel: Control = $SettingsPanel
@onready var music_slider: HSlider = $SettingsPanel/SettingsBox/VBox/MusicRow/MusicSlider
@onready var music_value_label: Label = $SettingsPanel/SettingsBox/VBox/MusicRow/MusicValueLabel
@onready var sfx_slider: HSlider = $SettingsPanel/SettingsBox/VBox/SfxRow/SfxSlider
@onready var sfx_value_label: Label = $SettingsPanel/SettingsBox/VBox/SfxRow/SfxValueLabel
@onready var back_button: Button = $SettingsPanel/SettingsBox/VBox/BackButton

# Ánh xạ phần trăm (0–100) sang dB (−60 → 0) và ngược lại.
const DB_MIN: float = -60.0
const DB_MAX: float = 0.0

func _ready() -> void:
	# Main buttons
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	title_label.text = "3D Test"

	# Settings panel
	back_button.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	# Khởi tạo slider từ SettingsManager (nếu có) hoặc giá trị mặc định
	_init_sliders_from_settings()
	settings_panel.hide()

# ============ Main buttons ============

func _on_start_pressed() -> void:
	if get_node_or_null("/root/AudioManager") != null:
		AudioManager.play_sfx("res://Assets/Audio/SFX/click.ogg")
	SceneLoader.load_scene("res://Scenes/Game/game.tscn")

func _on_settings_pressed() -> void:
	if get_node_or_null("/root/AudioManager") != null:
		AudioManager.play_sfx("res://Assets/Audio/SFX/click.ogg")
	_open_settings_panel()

func _on_quit_pressed() -> void:
	get_tree().quit()

# ============ Settings panel ============

func _open_settings_panel() -> void:
	# Refresh sliders mỗi lần mở (đề phòng SettingsManager thay đổi từ nơi khác)
	_init_sliders_from_settings()
	main_panel.hide()
	settings_panel.show()

func _on_back_pressed() -> void:
	if get_node_or_null("/root/AudioManager") != null:
		AudioManager.play_sfx("res://Assets/Audio/SFX/click.ogg")
	settings_panel.hide()
	main_panel.show()

func _on_music_slider_changed(value: float) -> void:
	var db := _pct_to_db(value)
	music_value_label.text = "%d%%" % int(value)
	if get_node_or_null("/root/AudioManager") != null:
		AudioManager.set_music_volume(db)
	if get_node_or_null("/root/SettingsManager") != null:
		SettingsManager.set_setting("music_volume_db", db)

func _on_sfx_slider_changed(value: float) -> void:
	var db := _pct_to_db(value)
	sfx_value_label.text = "%d%%" % int(value)
	if get_node_or_null("/root/AudioManager") != null:
		AudioManager.set_sfx_volume(db)
	if get_node_or_null("/root/SettingsManager") != null:
		SettingsManager.set_setting("sfx_volume_db", db)

# ============ Helpers ============

func _init_sliders_from_settings() -> void:
	var music_db: float = 0.0
	var sfx_db: float = 0.0
	if get_node_or_null("/root/SettingsManager") != null:
		music_db = float(SettingsManager.get_setting("music_volume_db", 0.0))
		sfx_db = float(SettingsManager.get_setting("sfx_volume_db", 0.0))
	var music_pct: float = _db_to_pct(music_db)
	var sfx_pct: float = _db_to_pct(sfx_db)
	# Tạm thời ngắt signal để không emit value_changed khi gán giá trị khởi đầu
	music_slider.value_changed.disconnect(_on_music_slider_changed)
	sfx_slider.value_changed.disconnect(_on_sfx_slider_changed)
	music_slider.value = music_pct
	sfx_slider.value = sfx_pct
	music_value_label.text = "%d%%" % int(music_pct)
	sfx_value_label.text = "%d%%" % int(sfx_pct)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _pct_to_db(pct: float) -> float:
	# Ánh xạ tuyến tính: 0% -> DB_MIN, 100% -> DB_MAX
	var t: float = clamp(pct, 0.0, 100.0) / 100.0
	return lerp(DB_MIN, DB_MAX, t)

func _db_to_pct(db: float) -> float:
	var clamped: float = clamp(db, DB_MIN, DB_MAX)
	var t: float = (clamped - DB_MIN) / (DB_MAX - DB_MIN)
	return clamp(t * 100.0, 0.0, 100.0)
