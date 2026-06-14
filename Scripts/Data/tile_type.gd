class_name TileType
extends RefCounted

enum Category { WAN, TIAO, BING, WIND, DRAGON, FLOWER, SEASON }

var id: String = ""
var display_name: String = ""
var category: Category = Category.WAN


static func get_category_color(tile_category: Category) -> Color:
	match tile_category:
		Category.WAN:
			return Color(0.86, 0.32, 0.32)
		Category.TIAO:
			return Color(0.28, 0.68, 0.38)
		Category.BING:
			return Color(0.28, 0.52, 0.86)
		Category.WIND:
			return Color(0.58, 0.42, 0.78)
		Category.DRAGON:
			return Color(0.9, 0.62, 0.2)
		Category.FLOWER:
			return Color(0.9, 0.45, 0.72)
		Category.SEASON:
			return Color(0.42, 0.72, 0.82)
		_:
			return Color(0.5, 0.5, 0.5)
