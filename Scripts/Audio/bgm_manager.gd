extends Node

var _player: AudioStreamPlayer
var _current_key: String = ""
var _chain_running_after_start: bool = false


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = &"Master"
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.finished.connect(_on_player_finished)
	add_child(_player)
	call_deferred("apply_settings")


func play_home() -> void:
	if not _is_music_enabled():
		return
	_chain_running_after_start = false
	_play_track("home", BgmConfig.HOME_TRACK, true)


func play_level_start() -> void:
	if not _is_music_enabled():
		return
	_chain_running_after_start = true
	_play_track("start", BgmConfig.START_TRACK, false)


func play_running() -> void:
	if not _is_music_enabled():
		return
	_chain_running_after_start = false
	_play_track("running", BgmConfig.RUNNING_TRACK, true)


func play_win() -> void:
	if not _is_music_enabled():
		return
	_chain_running_after_start = false
	_play_track("win", BgmConfig.WIN_TRACK, false)


func stop() -> void:
	_chain_running_after_start = false
	_current_key = ""
	if _player.playing:
		_player.stop()


func apply_settings() -> void:
	_player.volume_db = GameSettings.get_volume_db()
	if not GameSettings.music_enabled:
		stop()


func set_volume_db(value: float) -> void:
	_player.volume_db = value


func _on_player_finished() -> void:
	if _current_key == "start" and _chain_running_after_start:
		play_running()


func _play_track(key: String, path: String, loop: bool) -> void:
	if _current_key == key and _player.playing:
		return

	var stream := _load_stream(path, loop)
	if stream == null:
		if key == "start" and _chain_running_after_start:
			_chain_running_after_start = false
			play_running()
		else:
			stop()
		return

	_current_key = key
	_player.stream = stream
	_player.volume_db = GameSettings.get_volume_db()
	_player.play()


func _is_music_enabled() -> bool:
	return GameSettings.music_enabled and GameSettings.music_volume > 0.001


func _load_stream(path: String, loop: bool) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("BgmManager: 未找到 BGM 文件 %s" % path)
		return null

	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("BgmManager: 无法加载 BGM %s" % path)
		return null

	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = (
			AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		)

	return stream
