class_name LevelData
extends RefCounted

var id: int = 0
var name: String = ""
var layout_path: String = ""
var tile_pool: Array[String] = []
var difficulty: int = 1


static func from_dict(data: Dictionary) -> LevelData:
	var level := LevelData.new()
	level.id = int(data.get("id", 0))
	level.name = str(data.get("name", ""))
	level.layout_path = str(data.get("layout_path", ""))

	var pool: Variant = data.get("tile_pool", [])
	if typeof(pool) == TYPE_ARRAY:
		for item in pool:
			level.tile_pool.append(str(item))

	level.difficulty = int(data.get("difficulty", 1))
	return level
