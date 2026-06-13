class_name GridConverter
extends RefCounted

static func grid_to_world(grid_x: int, grid_y: int, origin: Vector2 = Vector2.ZERO) -> Vector2:
	return origin + Vector2(
		grid_x * TileConstants.TILE_SIZE.x / 2.0,
		grid_y * TileConstants.GRID_Y_STEP,
	)


static func layer_depth_offset(layer: int) -> Vector2:
	return TileConstants.LAYER_OFFSET * float(layer)


static func compute_z_index(layer: int, grid_y: int) -> int:
	return layer * 1000 + grid_y
