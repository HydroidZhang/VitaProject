class_name LevelCatalog
extends RefCounted

const LEVEL_NAMES: Array[String] = [
	"初出茅庐",
	"小试牛刀",
	"渐入佳境",
	"稳步前行",
	"双层进阶",
	"叠层挑战",
	"双层精通",
	"塔影成双",
	"步步为营",
	"双层大师",
	"三层起步",
	"层峦渐起",
	"高塔三重",
	"叠影重重",
	"深塔探秘",
	"迷宫三层",
	"大师前奏",
	"巅峰预备",
	"终极试炼",
	"麻将宗师",
]


static func build_level(id: int) -> LevelData:
	var level := LevelData.new()
	level.id = id
	level.name = LEVEL_NAMES[id - 1] if id >= 1 and id <= LEVEL_NAMES.size() else "关卡 %d" % id
	level.layout_path = ""
	level.difficulty = mini(5, 1 + (id - 1) / 4)
	level.tile_pool = tile_pool_for(id)
	return level


static func build_all() -> Array[LevelData]:
	var levels: Array[LevelData] = []
	for id in range(1, 21):
		levels.append(build_level(id))
	return levels


static func tile_pool_for(level_id: int) -> Array[String]:
	var all_ids := TileRegistry.get_all_ids()
	var pair_count := LayoutGenerator.tile_count_for_level(level_id) / 2
	var pool_size := mini(all_ids.size(), maxi(pair_count + 4, 8))
	all_ids.shuffle()
	return all_ids.slice(0, pool_size)
