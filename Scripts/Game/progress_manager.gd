class_name ProgressManager
extends RefCounted

const SAVE_PATH := "user://vita_progress.json"

var highest_unlocked: int = 1


static func load() -> ProgressManager:
	var manager := ProgressManager.new()
	if not FileAccess.file_exists(SAVE_PATH):
		return manager

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return manager

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		return manager

	manager.highest_unlocked = maxi(1, int(parsed.get("highest_unlocked", 1)))
	return manager


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save progress")
		return

	file.store_string(JSON.stringify({"highest_unlocked": highest_unlocked}))


func is_unlocked(level_id: int) -> bool:
	return level_id <= highest_unlocked


func unlock_next_after(level_id: int, max_level_id: int) -> bool:
	if level_id >= max_level_id:
		return false
	var next_id := level_id + 1
	if next_id > highest_unlocked:
		highest_unlocked = next_id
		save()
		return true
	return false
