class_name BoardRules
extends RefCounted

const TILE_GRID_WIDTH := 2
const TILE_GRID_HEIGHT := TileConstants.GRID_ROW_SPACING
const COVERAGE_GRID_HEIGHT := TileConstants.GRID_ROW_SPACING


static func is_slot_free(slot: TileSlot, slots: Array[TileSlot]) -> bool:
	var info := get_block_info(slot, slots)
	return not info.covered and not (info.left_blocked and info.right_blocked)


static func get_block_info(slot: TileSlot, slots: Array[TileSlot]) -> Dictionary:
	var info := {
		"covered": false,
		"left_blocked": false,
		"right_blocked": false,
	}
	if slot.cell == null:
		info.covered = true
		return info

	info.covered = _is_covered(slot, slots)
	var sides := _get_side_blocks(slot, slots)
	info.left_blocked = sides.x == 1
	info.right_blocked = sides.y == 1
	return info


static func get_free_slots(slots: Array[TileSlot]) -> Array[TileSlot]:
	var free_slots: Array[TileSlot] = []
	for slot in slots:
		if is_slot_free(slot, slots):
			free_slots.append(slot)
	return free_slots


static func _is_covered(slot: TileSlot, slots: Array[TileSlot]) -> bool:
	var slot_y := GridConverter.cell_grid_y(slot.cell)
	for other in slots:
		if other == slot or other.cell == null:
			continue
		if not _cells_overlap_for_coverage(slot.cell, other.cell):
			continue
		if other.cell.layer > slot.cell.layer:
			return true
		if other.cell.layer == slot.cell.layer:
			var other_y := GridConverter.cell_grid_y(other.cell)
			if other_y < slot_y:
				return true
	return false


static func _get_side_blocks(slot: TileSlot, slots: Array[TileSlot]) -> Vector2i:
	var left_blocked := false
	var right_blocked := false

	for other in slots:
		if other == slot or other.cell == null:
			continue
		if other.cell.layer != slot.cell.layer:
			continue
		if not _y_ranges_overlap(slot.cell, other.cell):
			continue
		if other.cell.x == slot.cell.x - TILE_GRID_WIDTH:
			left_blocked = true
		if other.cell.x == slot.cell.x + TILE_GRID_WIDTH:
			right_blocked = true

	return Vector2i(int(left_blocked), int(right_blocked))


static func _cells_overlap(a: CellData, b: CellData) -> bool:
	return (
		a.x < b.x + TILE_GRID_WIDTH
		and b.x < a.x + TILE_GRID_WIDTH
		and _cell_y_min(a) < _cell_y_max(b)
		and _cell_y_min(b) < _cell_y_max(a)
	)


static func _cells_overlap_for_coverage(a: CellData, b: CellData) -> bool:
	return (
		a.x < b.x + TILE_GRID_WIDTH
		and b.x < a.x + TILE_GRID_WIDTH
		and _cell_y_min(a) < _cell_y_max(b)
		and _cell_y_min(b) < _cell_y_max(a)
	)


static func _y_ranges_overlap(a: CellData, b: CellData) -> bool:
	return _cell_y_min(a) < _cell_y_max(b) and _cell_y_min(b) < _cell_y_max(a)


static func _cell_y_min(cell: CellData) -> int:
	return GridConverter.cell_grid_y(cell)


static func _cell_y_max(cell: CellData) -> int:
	return GridConverter.cell_grid_y(cell) + COVERAGE_GRID_HEIGHT
