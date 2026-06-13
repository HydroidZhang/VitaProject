class_name TileRegistry
extends RefCounted

const _DEFINITIONS: Array[Dictionary] = [
	{"id": "wan_1", "display_name": "一万", "category": TileType.Category.WAN},
	{"id": "wan_2", "display_name": "二万", "category": TileType.Category.WAN},
	{"id": "wan_3", "display_name": "三万", "category": TileType.Category.WAN},
	{"id": "wan_4", "display_name": "四万", "category": TileType.Category.WAN},
	{"id": "wan_5", "display_name": "五万", "category": TileType.Category.WAN},
	{"id": "wan_6", "display_name": "六万", "category": TileType.Category.WAN},
	{"id": "wan_7", "display_name": "七万", "category": TileType.Category.WAN},
	{"id": "wan_8", "display_name": "八万", "category": TileType.Category.WAN},
	{"id": "wan_9", "display_name": "九万", "category": TileType.Category.WAN},
	{"id": "tiao_1", "display_name": "一条", "category": TileType.Category.TIAO},
	{"id": "tiao_2", "display_name": "二条", "category": TileType.Category.TIAO},
	{"id": "tiao_3", "display_name": "三条", "category": TileType.Category.TIAO},
	{"id": "tiao_4", "display_name": "四条", "category": TileType.Category.TIAO},
	{"id": "tiao_5", "display_name": "五条", "category": TileType.Category.TIAO},
	{"id": "tiao_6", "display_name": "六条", "category": TileType.Category.TIAO},
	{"id": "tiao_7", "display_name": "七条", "category": TileType.Category.TIAO},
	{"id": "tiao_8", "display_name": "八条", "category": TileType.Category.TIAO},
	{"id": "tiao_9", "display_name": "九条", "category": TileType.Category.TIAO},
	{"id": "bing_1", "display_name": "一饼", "category": TileType.Category.BING},
	{"id": "bing_2", "display_name": "二饼", "category": TileType.Category.BING},
	{"id": "bing_3", "display_name": "三饼", "category": TileType.Category.BING},
	{"id": "bing_4", "display_name": "四饼", "category": TileType.Category.BING},
	{"id": "bing_5", "display_name": "五饼", "category": TileType.Category.BING},
	{"id": "bing_6", "display_name": "六饼", "category": TileType.Category.BING},
	{"id": "bing_7", "display_name": "七饼", "category": TileType.Category.BING},
	{"id": "bing_8", "display_name": "八饼", "category": TileType.Category.BING},
	{"id": "bing_9", "display_name": "九饼", "category": TileType.Category.BING},
	{"id": "wind_east", "display_name": "东", "category": TileType.Category.WIND},
	{"id": "wind_south", "display_name": "南", "category": TileType.Category.WIND},
	{"id": "wind_west", "display_name": "西", "category": TileType.Category.WIND},
	{"id": "wind_north", "display_name": "北", "category": TileType.Category.WIND},
	{"id": "dragon_red", "display_name": "中", "category": TileType.Category.DRAGON},
	{"id": "dragon_green", "display_name": "发", "category": TileType.Category.DRAGON},
	{"id": "dragon_white", "display_name": "白", "category": TileType.Category.DRAGON},
]

static var _cache: Dictionary = {}


static func get_tile(tile_id: String) -> TileType:
	if _cache.has(tile_id):
		return _cache[tile_id]

	for definition in _DEFINITIONS:
		if definition.id == tile_id:
			var tile_type := TileType.new()
			tile_type.id = definition.id
			tile_type.display_name = definition.display_name
			tile_type.category = definition.category
			_cache[tile_id] = tile_type
			return tile_type

	push_warning("Unknown tile id: %s" % tile_id)
	return null


static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for definition in _DEFINITIONS:
		ids.append(definition.id)
	return ids
