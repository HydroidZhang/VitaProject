class_name BoardSolver
extends RefCounted

const MAX_NODES := 50000
const RUNTIME_MAX_NODES := 10000


static func is_solvable(
	cells: Array[CellData],
	tile_ids: Array[String],
	max_nodes: int = MAX_NODES,
) -> bool:
	if cells.size() != tile_ids.size():
		return false
	if cells.is_empty():
		return true
	if cells.size() % 2 != 0:
		return false

	var slots := _build_slots(cells, tile_ids)
	var removed: Array[bool] = []
	removed.resize(slots.size())
	return _solve(slots, removed, 0, max_nodes)


static func _build_slots(cells: Array[CellData], tile_ids: Array[String]) -> Array[TileSlot]:
	var slots: Array[TileSlot] = []
	for index in cells.size():
		slots.append(TileSlot.from_parts(cells[index], tile_ids[index]))
	return slots


static func _solve(
	slots: Array[TileSlot],
	removed: Array[bool],
	visited_nodes: int,
	max_nodes: int,
) -> bool:
	if _remaining_count(removed) == 0:
		return true
	if visited_nodes > max_nodes:
		return false

	var active := _active_slots(slots, removed)
	var free_indices := _get_free_indices(slots, removed, active)
	for first_i in free_indices.size():
		var first_idx: int = free_indices[first_i]
		for second_i in range(first_i + 1, free_indices.size()):
			var second_idx: int = free_indices[second_i]
			if slots[first_idx].tile_id != slots[second_idx].tile_id:
				continue

			removed[first_idx] = true
			removed[second_idx] = true
			if _solve(slots, removed, visited_nodes + 1, max_nodes):
				return true
			removed[first_idx] = false
			removed[second_idx] = false

	return false


static func _remaining_count(removed: Array[bool]) -> int:
	var count := 0
	for flag in removed:
		if not flag:
			count += 1
	return count


static func _active_slots(
	slots: Array[TileSlot],
	removed: Array[bool],
) -> Array[TileSlot]:
	var active: Array[TileSlot] = []
	for index in slots.size():
		if not removed[index]:
			active.append(slots[index])
	return active


static func _get_free_indices(
	slots: Array[TileSlot],
	removed: Array[bool],
	active: Array[TileSlot],
) -> Array[int]:
	var free_indices: Array[int] = []
	for index in slots.size():
		if removed[index]:
			continue
		if BoardRules.is_slot_free(slots[index], active):
			free_indices.append(index)
	return free_indices
