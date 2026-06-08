extends Node
## AudioManager (Autoload)
## Quản lý music & SFX thông qua Audio bus.

const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

var _current_music: AudioStreamPlayer = null
var _music_volume_db: float = 0.0
var _sfx_volume_db: float = 0.0

func _ready() -> void:
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_apply_volumes()

func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _apply_volumes() -> void:
	_set_bus_volume(MUSIC_BUS, _music_volume_db)
	_set_bus_volume(SFX_BUS, _sfx_volume_db)

func _set_bus_volume(bus_name: StringName, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)

func set_music_volume(db: float) -> void:
	_music_volume_db = clamp(db, -60.0, 0.0)
	_set_bus_volume(MUSIC_BUS, _music_volume_db)

func set_sfx_volume(db: float) -> void:
	_sfx_volume_db = clamp(db, -60.0, 0.0)
	_set_bus_volume(SFX_BUS, _sfx_volume_db)

func play_music(path: String, fade_time: float = 1.0) -> void:
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: music not found: %s" % path)
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	var new_player := AudioStreamPlayer.new()
	new_player.stream = stream
	new_player.bus = MUSIC_BUS
	new_player.volume_db = -80.0
	add_child(new_player)
	new_player.play()
	_fade_in(new_player, fade_time)
	if _current_music:
		_fade_out_and_free(_current_music, fade_time)
	_current_music = new_player

func play_sfx(path: String, volume_db: float = 0.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = SFX_BUS
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

func stop_music(fade_time: float = 1.0) -> void:
	if _current_music:
		_fade_out_and_free(_current_music, fade_time)
		_current_music = null

func _fade_in(player: AudioStreamPlayer, t: float) -> void:
	if t <= 0.0:
		player.volume_db = 0.0
		return
	var tw := create_tween()
	tw.tween_property(player, "volume_db", 0.0, t)

func _fade_out_and_free(player: AudioStreamPlayer, t: float) -> void:
	if not is_instance_valid(player):
		return
	if t <= 0.0:
		player.queue_free()
		return
	var tw := create_tween()
	tw.tween_property(player, "volume_db", -80.0, t)
	tw.tween_callback(Callable(player, "queue_free"))
