class_name TilePicker
extends RefCounted

const HIT_HALF := TileConstants.HALF_SIZE
const HIT_CENTER_OFFSET := Vector2(-3.5, -4.0)


static func pick_tile_at(tiles: Array[MahjongTile], canvas_pos: Vector2) -> MahjongTile:
	var best_tile: MahjongTile = null

	for tile in tiles:
		if not _is_pickable(tile):
			continue
		if not contains_canvas_point(tile, canvas_pos):
			continue
		if best_tile == null or _should_prefer(tile, best_tile):
			best_tile = tile

	return best_tile


static func contains_canvas_point(tile: MahjongTile, canvas_pos: Vector2) -> bool:
	var local := tile.get_global_transform_with_canvas().affine_inverse() * canvas_pos
	local -= HIT_CENTER_OFFSET
	return abs(local.x) <= HIT_HALF.x and abs(local.y) <= HIT_HALF.y


static func _should_prefer(candidate: MahjongTile, current: MahjongTile) -> bool:
	if candidate.z_index != current.z_index:
		return candidate.z_index > current.z_index
	if candidate.layer != current.layer:
		return candidate.layer > current.layer
	if candidate.cell != null and current.cell != null:
		return GridConverter.cell_grid_y(candidate.cell) < GridConverter.cell_grid_y(current.cell)
	return false


static func _is_pickable(tile: MahjongTile) -> bool:
	return is_instance_valid(tile) and tile.can_receive_pointer()
