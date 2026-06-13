class_name BoardSolver
extends RefCounted

const MAX_NODES := 50000


static func is_solvable(cells: Array[CellData], tile_ids: Array[String]) -> bool:
	if cells.size() != tile_ids.size():
		return false
	if cells.is_empty():
		return true
	if cells.size() % 2 != 0:
		return false

	var slots := _build_slots(cells, tile_ids)
	return _solve(slots, 0)


static func _build_slots(cells: Array[CellData], tile_ids: Array[String]) -> Array[TileSlot]:
	var slots: Array[TileSlot] = []
	for index in cells.size():
		slots.append(TileSlot.from_parts(cells[index], tile_ids[index]))
	return slots


static func _solve(slots: Array[TileSlot], visited_nodes: int) -> bool:
	if slots.is_empty():
		return true
	if visited_nodes > MAX_NODES:
		return false

	var free_slots := BoardRules.get_free_slots(slots)
	for first_index in free_slots.size():
		for second_index in range(first_index + 1, free_slots.size()):
			var first := free_slots[first_index]
			var second := free_slots[second_index]
			if first.tile_id != second.tile_id:
				continue

			var next_slots := _remove_pair(slots, first, second)
			if _solve(next_slots, visited_nodes + 1):
				return true

	return false


static func _remove_pair(
	slots: Array[TileSlot],
	first: TileSlot,
	second: TileSlot,
) -> Array[TileSlot]:
	var next_slots: Array[TileSlot] = []
	for slot in slots:
		if slot == first or slot == second:
			continue
		next_slots.append(slot)
	return next_slots
