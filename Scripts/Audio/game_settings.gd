extends Node

signal changed

const SAVE_PATH := "user://vita_settings.json"

var music_enabled: bool = true
var music_volume: float = 0.8


func _ready() -> void:
	_load_from_disk()
	call_deferred("apply_to_audio")


func set_music_enabled(enabled: bool) -> void:
	if music_enabled == enabled:
		return
	music_enabled = enabled
	_save()
	apply_to_audio()
	changed.emit()


func set_music_volume(volume: float) -> void:
	var clamped := clampf(volume, 0.0, 1.0)
	if is_equal_approx(music_volume, clamped):
		return
	music_volume = clamped
	_save()
	apply_to_audio()
	changed.emit()


func get_volume_db() -> float:
	if not music_enabled or music_volume <= 0.001:
		return -80.0
	return BgmConfig.DEFAULT_VOLUME_DB + linear_to_db(music_volume)


func apply_to_audio() -> void:
	if BgmManager.has_method("apply_settings"):
		BgmManager.apply_settings()


func _load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	music_enabled = bool(parsed.get("music_enabled", true))
	music_volume = clampf(float(parsed.get("music_volume", 0.8)), 0.0, 1.0)


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save settings")
		return

	file.store_string(JSON.stringify({
		"music_enabled": music_enabled,
		"music_volume": music_volume,
	}, "\t"))
