class_name BoardBuilder
extends RefCounted

const MahjongScene := preload("res://Scenes/Mahjong.tscn")


static func build(
	board_node: Node2D,
	layout_path: String,
	tile_ids: Array[String],
	viewport_size: Vector2 = Vector2(720.0, 1080.0),
	play_area: Rect2 = Rect2(),
) -> Array[MahjongTile]:
	var cells := LayoutLoader.load(layout_path)
	if cells.is_empty():
		return []

	if cells.size() != tile_ids.size():
		push_error(
			"Cell count (%d) does not match tile id count (%d)"
			% [cells.size(), tile_ids.size()]
		)
		return []

	var area := play_area if play_area.size != Vector2.ZERO else Rect2(Vector2.ZERO, viewport_size)
	var origin := _compute_origin(cells, area.size) + area.position
	var tiles: Array[MahjongTile] = []

	for index in cells.size():
		var cell := cells[index]
		var tile: MahjongTile = MahjongScene.instantiate()
		tile.position = (
			GridConverter.grid_to_world(cell.x, cell.y, origin)
			+ GridConverter.layer_depth_offset(cell.layer)
		)
		tile.z_index = GridConverter.compute_z_index(cell.layer, cell.y)
		board_node.add_child(tile)
		tile.set_base_z_index(tile.z_index)
		tile.setup(tile_ids[index], cell.layer, cell)
		tiles.append(tile)

	return tiles


static func _compute_origin(cells: Array[CellData], viewport_size: Vector2) -> Vector2:
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var half_size := TileConstants.HALF_SIZE

	for cell in cells:
		var center := GridConverter.grid_to_world(cell.x, cell.y)
		min_pos.x = minf(min_pos.x, center.x - half_size.x)
		min_pos.y = minf(min_pos.y, center.y - half_size.y)
		max_pos.x = maxf(max_pos.x, center.x + half_size.x)
		max_pos.y = maxf(max_pos.y, center.y + half_size.y)

	var board_center := (min_pos + max_pos) / 2.0
	return viewport_size / 2.0 - board_center
