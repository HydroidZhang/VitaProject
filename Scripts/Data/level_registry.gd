class_name LevelRegistry
extends RefCounted

const LEVELS_PATH := "res://Data/Levels/levels.json"


static func load_all() -> Array[LevelData]:
	var levels := _load_from_json()
	if levels.is_empty():
		return LevelCatalog.build_all()
	return levels


static func get_by_id(level_id: int) -> LevelData:
	for level in load_all():
		if level.id == level_id:
			return level
	return null


static func _load_from_json() -> Array[LevelData]:
	if not FileAccess.file_exists(LEVELS_PATH):
		push_error("Levels file not found: %s" % LEVELS_PATH)
		return []

	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open levels file: %s" % LEVELS_PATH)
		return []

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid levels JSON")
		return []

	var data: Dictionary = parsed
	if not data.has("levels") or typeof(data["levels"]) != TYPE_ARRAY:
		push_error("Levels JSON missing 'levels' array")
		return []

	var levels: Array[LevelData] = []
	for index in data["levels"].size():
		var raw: Variant = data["levels"][index]
		if typeof(raw) != TYPE_DICTIONARY:
			push_error("Level %d is not an object" % index)
			continue

		var level := LevelData.from_dict(raw)
		if level.id <= 0:
			push_error("Level %d has invalid id" % index)
			continue

		if level.tile_pool.is_empty():
			level.tile_pool = LevelCatalog.tile_pool_for(level.id)

		levels.append(level)

	levels.sort_custom(func(a: LevelData, b: LevelData) -> bool:
		return a.id < b.id
	)
	return levels
