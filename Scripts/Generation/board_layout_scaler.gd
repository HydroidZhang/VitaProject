class_name BoardLayoutScaler
extends RefCounted

## 按 5×7 底层槽位估算棋盘占地，自动放大到对局区内（约红框大小）。
const FILL_WIDTH := 0.88
const FILL_HEIGHT := 0.82
const MIN_SCALE := 1.0
const MAX_SCALE := 2.0


static func compute_scale(play_area: Rect2) -> float:
	var bounds := _reference_l0_bounds()
	if bounds.size.x < 1.0 or bounds.size.y < 1.0:
		return 1.0

	var target_w := play_area.size.x * FILL_WIDTH
	var target_h := play_area.size.y * FILL_HEIGHT
	var scale_x := target_w / bounds.size.x
	var scale_y := target_h / bounds.size.y
	return clampf(minf(scale_x, scale_y), MIN_SCALE, MAX_SCALE)


static func apply_layer(layer: Node2D, play_area: Rect2) -> float:
	var scale := compute_scale(play_area)
	layer.scale = Vector2(scale, scale)
	layer.position = play_area.position + play_area.size * 0.5
	return scale


static func _reference_l0_bounds() -> Rect2:
	var cells: Array[CellData] = []
	for row in GridSlots.L0_ROWS:
		for col in GridSlots.L0_COLS:
			var cell := CellData.new()
			cell.x = col * 2
			cell.y = row
			cell.layer = 0
			cells.append(cell)
	return _cells_bounds(cells)


static func _cells_bounds(cells: Array[CellData]) -> Rect2:
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var half_size := TileConstants.HALF_SIZE

	for cell in cells:
		var center := GridConverter.grid_to_world_from_cell(cell)
		min_pos.x = minf(min_pos.x, center.x - half_size.x)
		min_pos.y = minf(min_pos.y, center.y - half_size.y)
		max_pos.x = maxf(max_pos.x, center.x + half_size.x)
		max_pos.y = maxf(max_pos.y, center.y + half_size.y)

	return Rect2(min_pos, max_pos - min_pos)
