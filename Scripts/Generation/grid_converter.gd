class_name GridConverter
extends RefCounted

## 坐标规则（牌高 H=102，半高 u=51）：
##   世界 y = grid_y * u
##   L0 第0行 grid_y=0 → y=0（最顶，上层不得超过此行）
##   L1/L2 在 L0 某行上：grid_y = row*2+1 → 半格下压叠在底层上
##   L0 第1行 grid_y=2 → y=102 …（行距 2u = 整牌高）
##   世界 x = grid_x * (牌宽/2)


static func cell_grid_y(cell: CellData) -> int:
	match cell.layer:
		0:
			return cell.y * TileConstants.GRID_ROW_SPACING
		1, 2:
			return cell.y * TileConstants.GRID_ROW_SPACING + 1
		_:
			return cell.y


static func grid_to_world_from_cell(
	cell: CellData,
	origin: Vector2 = Vector2.ZERO,
) -> Vector2:
	var grid_y := cell_grid_y(cell)
	return origin + Vector2(
		float(cell.x) * TileConstants.TILE_SIZE.x * 0.5,
		float(grid_y) * TileConstants.GRID_Y_STEP,
	)


static func grid_to_world(
	grid_x: int,
	grid_y: int,
	origin: Vector2 = Vector2.ZERO,
) -> Vector2:
	return origin + Vector2(
		float(grid_x) * TileConstants.TILE_SIZE.x * 0.5,
		float(grid_y) * TileConstants.GRID_Y_STEP,
	)


static func layer_depth_offset(layer: int) -> Vector2:
	return TileConstants.LAYER_OFFSET * float(layer)


static func compute_z_index(cell: CellData) -> int:
	var grid_y := cell_grid_y(cell)
	return cell.layer * 1000 + (100 - grid_y)
