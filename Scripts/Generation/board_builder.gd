class_name BoardBuilder
extends RefCounted

const MahjongScene := preload("res://Scenes/Mahjong.tscn")


static func build(
	board_node: Node2D,
	layout_path: String,
	tile_ids: Array[String],
	_viewport_size: Vector2 = Vector2(720.0, 1080.0),
	_play_area: Rect2 = Rect2(),
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

	var origin := _compute_origin(cells, Vector2.ZERO)
	var tiles: Array[MahjongTile] = []

	for index in cells.size():
		var cell := cells[index]
		var tile: MahjongTile = MahjongScene.instantiate()
		tile.position = (
			GridConverter.grid_to_world_from_cell(cell, origin)
			+ GridConverter.layer_depth_offset(cell.layer)
		)
		tile.z_index = GridConverter.compute_z_index(cell)
		board_node.add_child(tile)
		tile.set_base_z_index(tile.z_index)
		tile.setup(tile_ids[index], cell.layer, cell)
		tiles.append(tile)

	return tiles


static func build_from_cells(
	board_node: Node2D,
	cells: Array[CellData],
	tile_ids: Array[String],
	_viewport_size: Vector2 = Vector2(720.0, 1080.0),
	_play_area: Rect2 = Rect2(),
) -> Array[MahjongTile]:
	if cells.is_empty():
		return []
	if cells.size() != tile_ids.size():
		push_error(
			"Cell count (%d) does not match tile id count (%d)"
			% [cells.size(), tile_ids.size()]
		)
		return []

	var origin := _compute_origin(cells, Vector2.ZERO)
	var tiles: Array[MahjongTile] = []

	for index in cells.size():
		var cell := cells[index]
		var tile: MahjongTile = MahjongScene.instantiate()
		var target_position := (
			GridConverter.grid_to_world_from_cell(cell, origin)
			+ GridConverter.layer_depth_offset(cell.layer)
		)
		tile.position = target_position
		tile.z_index = GridConverter.compute_z_index(cell)
		board_node.add_child(tile)
		tile.set_base_z_index(tile.z_index)
		tile.setup(tile_ids[index], cell.layer, cell)
		tile.set_meta("shuffle_target_pos", target_position)
		tiles.append(tile)

	return tiles


static func _compute_origin(cells: Array[CellData], center: Vector2) -> Vector2:
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var half_size := TileConstants.HALF_SIZE

	for cell in cells:
		var pos := GridConverter.grid_to_world_from_cell(cell)
		min_pos.x = minf(min_pos.x, pos.x - half_size.x)
		min_pos.y = minf(min_pos.y, pos.y - half_size.y)
		max_pos.x = maxf(max_pos.x, pos.x + half_size.x)
		max_pos.y = maxf(max_pos.y, pos.y + half_size.y)

	var board_center := (min_pos + max_pos) / 2.0
	return center - board_center
