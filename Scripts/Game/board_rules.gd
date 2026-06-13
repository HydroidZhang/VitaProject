class_name BoardRules
extends RefCounted

const TILE_GRID_WIDTH := 2
const TILE_GRID_HEIGHT := 3


static func is_slot_free(slot: TileSlot, slots: Array[TileSlot]) -> bool:
	if slot.cell == null:
		return false
	if _is_covered(slot, slots):
		return false
	return not _is_blocked_both_sides(slot, slots)


static func get_free_slots(slots: Array[TileSlot]) -> Array[TileSlot]:
	var free_slots: Array[TileSlot] = []
	for slot in slots:
		if is_slot_free(slot, slots):
			free_slots.append(slot)
	return free_slots


static func _is_covered(slot: TileSlot, slots: Array[TileSlot]) -> bool:
	for other in slots:
		if other == slot or other.cell == null:
			continue
		if other.cell.layer <= slot.cell.layer:
			continue
		if _cells_overlap(slot.cell, other.cell):
			return true
	return false


static func _is_blocked_both_sides(slot: TileSlot, slots: Array[TileSlot]) -> bool:
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

	return left_blocked and right_blocked


static func _cells_overlap(a: CellData, b: CellData) -> bool:
	return (
		a.x < b.x + TILE_GRID_WIDTH
		and b.x < a.x + TILE_GRID_WIDTH
		and a.y < b.y + TILE_GRID_HEIGHT
		and b.y < a.y + TILE_GRID_HEIGHT
	)


static func _y_ranges_overlap(a: CellData, b: CellData) -> bool:
	return a.y < b.y + TILE_GRID_HEIGHT and b.y < a.y + TILE_GRID_HEIGHT
