class_name TileTextureAtlas
extends RefCounted

const TILES_DIR := "res://Assets/Mahjong/"

const TEXTURE_MAP: Dictionary = {
	"wan_1": "tile_00_01_wan_1.png",
	"wan_2": "tile_01_02_wan_2.png",
	"wan_3": "tile_02_03_wan_3.png",
	"wan_4": "tile_03_04_wan_4.png",
	"wan_5": "tile_04_05_wan_5.png",
	"wan_6": "tile_05_06_wan_6.png",
	"wan_7": "tile_06_07_wan_7.png",
	"wan_8": "tile_07_08_wan_8.png",
	"wan_9": "tile_08_09_wan_9.png",
	"bing_1": "tile_09_10_tong_1.png",
	"bing_2": "tile_10_11_tong_2.png",
	"bing_3": "tile_11_12_tong_3.png",
	"bing_4": "tile_12_13_tong_4.png",
	"bing_5": "tile_13_14_tong_5.png",
	"bing_6": "tile_14_15_tong_6.png",
	"bing_7": "tile_15_16_tong_7.png",
	"bing_8": "tile_16_17_tong_8.png",
	"bing_9": "tile_17_18_tong_9.png",
	"tiao_1": "tile_18_19_tiao_1.png",
	"tiao_2": "tile_19_20_tiao_2.png",
	"tiao_3": "tile_20_21_tiao_3.png",
	"tiao_4": "tile_21_22_tiao_4.png",
	"tiao_5": "tile_22_23_tiao_5.png",
	"tiao_6": "tile_23_24_tiao_6.png",
	"tiao_7": "tile_24_25_tiao_7.png",
	"tiao_8": "tile_25_26_tiao_8.png",
	"tiao_9": "tile_26_27_tiao_9.png",
	"wind_east": "tile_27_28_dong.png",
	"wind_south": "tile_nanan.png",
	"wind_west": "tile_xixix_1.png",
	"wind_north": "tile_30_31_bei.png",
	"dragon_red": "tile_00_01_eewan_1.png",
	"dragon_green": "tile_fafafa_wan_1.png",
	"dragon_white": "tile_33_34_bai.png",
}

const FACE_SIZE := Vector2i(65, 94)
const IVORY := Color(0.96, 0.93, 0.86)
const BORDER := Color(0.72, 0.66, 0.56)

static var _cache: Dictionary = {}


static func clear_cache() -> void:
	_cache.clear()


static func uses_file_texture(tile_type: TileType) -> bool:
	if tile_type == null:
		return false
	return TEXTURE_MAP.has(tile_type.id) and ResourceLoader.exists(_path_for(tile_type.id))


static func get_face_texture(tile_type: TileType) -> Texture2D:
	if tile_type == null:
		return _get_fallback_texture()

	if _cache.has(tile_type.id):
		return _cache[tile_type.id]

	var file_texture := _load_file_texture(tile_type.id)
	if file_texture != null:
		_cache[tile_type.id] = file_texture
		return file_texture

	var procedural := _build_procedural_texture(tile_type)
	_cache[tile_type.id] = procedural
	return procedural


static func get_sprite_scale(texture: Texture2D) -> Vector2:
	if texture == null:
		return Vector2.ONE
	return Vector2(
		TileConstants.TILE_SIZE.x / float(texture.get_width()),
		TileConstants.TILE_SIZE.y / float(texture.get_height()),
	)


static func _load_file_texture(tile_id: String) -> Texture2D:
	var path := _path_for(tile_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	return texture


static func _path_for(tile_id: String) -> String:
	if not TEXTURE_MAP.has(tile_id):
		return ""
	return TILES_DIR + TEXTURE_MAP[tile_id]


static func _get_fallback_texture() -> Texture2D:
	if _cache.has("_fallback"):
		return _cache["_fallback"]

	var image := Image.create(FACE_SIZE.x, FACE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.55, 0.55, 0.55))
	var texture := ImageTexture.create_from_image(image)
	_cache["_fallback"] = texture
	return texture


static func _build_procedural_texture(tile_type: TileType) -> Texture2D:
	var image := Image.create(FACE_SIZE.x, FACE_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(IVORY)
	_draw_border(image)
	_draw_header(image, tile_type)
	_draw_suit_art(image, tile_type)
	return ImageTexture.create_from_image(image)


static func _draw_border(image: Image) -> void:
	for x in FACE_SIZE.x:
		image.set_pixel(x, 0, BORDER)
		image.set_pixel(x, FACE_SIZE.y - 1, BORDER)
	for y in FACE_SIZE.y:
		image.set_pixel(0, y, BORDER)
		image.set_pixel(FACE_SIZE.x - 1, y, BORDER)


static func _draw_header(image: Image, tile_type: TileType) -> void:
	var accent := TileType.get_category_color(tile_type.category)
	for y in range(1, 11):
		for x in range(1, FACE_SIZE.x - 1):
			image.set_pixel(x, y, accent)


static func _draw_suit_art(image: Image, tile_type: TileType) -> void:
	var parts := tile_type.id.split("_")
	if parts.size() < 2:
		return

	var suit: String = parts[0]
	var accent := TileType.get_category_color(tile_type.category)
	var center := Vector2(FACE_SIZE) / 2.0 + Vector2(0, 8)

	match suit:
		"wan", "tiao", "bing":
			var count := int(parts[1])
			_draw_pips(image, count, suit, accent, center)
		"wind", "dragon":
			_draw_honor_mark(image, accent, center)


static func _draw_pips(
	image: Image,
	count: int,
	suit: String,
	color: Color,
	center: Vector2,
) -> void:
	if suit == "bing":
		_draw_dot_grid(image, count, color, center, 5)
	elif suit == "tiao":
		_draw_bamboo_grid(image, count, color, center)
	else:
		_draw_wan_grid(image, count, color, center)


static func _draw_dot_grid(
	image: Image,
	count: int,
	color: Color,
	center: Vector2,
	radius: int,
) -> void:
	var positions := _pip_positions(count)
	for pos in positions:
		_fill_circle(image, center + pos * 11.0, radius, color)


static func _draw_bamboo_grid(
	image: Image,
	count: int,
	color: Color,
	center: Vector2,
) -> void:
	var positions := _pip_positions(count)
	for pos in positions:
		_fill_capsule(image, center + pos * 11.0, Vector2(4, 10), color)


static func _draw_wan_grid(
	image: Image,
	count: int,
	color: Color,
	center: Vector2,
) -> void:
	_draw_dot_grid(image, count, color.darkened(0.1), center, 4)
	for pos in _pip_positions(count):
		_fill_rect(image, center + pos * 11.0 + Vector2(-5, -2), Vector2(10, 4), color)


static func _draw_honor_mark(image: Image, color: Color, center: Vector2) -> void:
	_fill_circle(image, center, 14, color.lightened(0.15))
	_fill_circle(image, center, 9, IVORY)


static func _pip_positions(count: int) -> Array[Vector2]:
	match count:
		1:
			return [Vector2.ZERO]
		2:
			return [Vector2(-0.8, 0), Vector2(0.8, 0)]
		3:
			return [Vector2(-0.9, -0.7), Vector2.ZERO, Vector2(0.9, 0.7)]
		4:
			return [
				Vector2(-0.8, -0.8), Vector2(0.8, -0.8),
				Vector2(-0.8, 0.8), Vector2(0.8, 0.8),
			]
		5:
			return [
				Vector2(-0.9, -0.9), Vector2(0.9, -0.9), Vector2.ZERO,
				Vector2(-0.9, 0.9), Vector2(0.9, 0.9),
			]
		6:
			return [
				Vector2(-0.9, -0.9), Vector2.ZERO, Vector2(0.9, -0.9),
				Vector2(-0.9, 0.9), Vector2.ZERO, Vector2(0.9, 0.9),
			]
		7:
			return [
				Vector2(-1.0, -1.0), Vector2(0, -1.0), Vector2(1.0, -1.0),
				Vector2(-0.5, 0), Vector2(0.5, 0),
				Vector2(-1.0, 1.0), Vector2(1.0, 1.0),
			]
		8:
			return [
				Vector2(-1.0, -1.0), Vector2(0, -1.0), Vector2(1.0, -1.0),
				Vector2(-1.0, -0.2), Vector2(1.0, -0.2),
				Vector2(-1.0, 0.8), Vector2(0, 0.8), Vector2(1.0, 0.8),
			]
		9:
			return [
				Vector2(-1.0, -1.0), Vector2(0, -1.0), Vector2(1.0, -1.0),
				Vector2(-1.0, 0), Vector2(0, 0), Vector2(1.0, 0),
				Vector2(-1.0, 1.0), Vector2(0, 1.0), Vector2(1.0, 1.0),
			]
		_:
			return [Vector2.ZERO]


static func _fill_circle(image: Image, center: Vector2, radius: int, color: Color) -> void:
	var r2 := radius * radius
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y > r2:
				continue
			var px := int(center.x) + x
			var py := int(center.y) + y
			if _in_bounds(px, py):
				image.set_pixel(px, py, color)


static func _fill_capsule(
	image: Image,
	center: Vector2,
	size: Vector2,
	color: Color,
) -> void:
	_fill_rect(image, center - size / 2.0, size, color)
	_fill_circle(image, center + Vector2(0, -size.y / 2.0 + 1), int(size.x / 2.0), color)
	_fill_circle(image, center + Vector2(0, size.y / 2.0 - 1), int(size.x / 2.0), color)


static func _fill_rect(image: Image, origin: Vector2, size: Vector2, color: Color) -> void:
	var start_x := int(origin.x)
	var start_y := int(origin.y)
	var end_x := int(origin.x + size.x)
	var end_y := int(origin.y + size.y)
	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			if _in_bounds(x, y):
				image.set_pixel(x, y, color)


static func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < FACE_SIZE.x and y < FACE_SIZE.y
