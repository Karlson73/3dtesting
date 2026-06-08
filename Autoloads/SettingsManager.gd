extends Node
## SettingsManager (Autoload)
## Lưu/load cài đặt người chơi (volume, sensitivity, ...).

const SAVE_PATH := "user://settings.cfg"

signal setting_changed(key: String, value: Variant)

# Default values
var settings: Dictionary = {
	"music_volume_db": 0.0,
	"sfx_volume_db": 0.0,
	"mouse_sensitivity": 0.002,
	"fullscreen": false,
	"vsync": true,
}

func _ready() -> void:
	load_settings()
	_apply_to_audio()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	for key in settings.keys():
		cfg.set_value("audio" if "volume" in key else "gameplay", key, settings[key])
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("SettingsManager: failed to save settings: %d" % err)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if not cfg.load(SAVE_PATH) == OK:
		return # keep defaults
	for section in cfg.get_sections():
		for key in cfg.get_section_keys(section):
			settings[key] = cfg.get_value(section, key)
	_apply_to_audio()

func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	setting_changed.emit(key, value)
	_apply_to_audio()
	save_settings()

func get_setting(key: String, default: Variant = null) -> Variant:
	return settings.get(key, default)

func _apply_to_audio() -> void:
	var am := get_node_or_null("/root/AudioManager")
	if am == null:
		return
	if "set_music_volume" in am:
		am.set_music_volume(settings.get("music_volume_db", 0.0))
	if "set_sfx_volume" in am:
		am.set_sfx_volume(settings.get("sfx_volume_db", 0.0))
