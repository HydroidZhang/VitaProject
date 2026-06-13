class_name DemoLevel
extends RefCounted

const LAYOUT_PATH := "res://Data/Layouts/demo_12.json"
const EMPTY_TILE_IDS: Array[String] = []

const TILE_POOL: Array[String] = [
	"wan_1",
	"wan_9",
	"tiao_3",
	"tiao_7",
	"bing_5",
	"bing_8",
	"wind_east",
	"wind_south",
	"dragon_red",
	"dragon_green",
	"wan_5",
	"wan_6",
]


static func generate_tile_ids() -> Array[String]:
	var cells := LayoutLoader.load(LAYOUT_PATH)
	if cells.is_empty():
		return []
	return TileAssigner.assign_solvable(cells, TILE_POOL)
