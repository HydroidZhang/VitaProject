class_name TileAssigner
extends RefCounted

const DEFAULT_MAX_ATTEMPTS := 200
const RUNTIME_MAX_ATTEMPTS := 128
const RUNTIME_MAX_NODES := BoardSolver.RUNTIME_MAX_NODES
const PEELING_ATTEMPTS := 128
const RANDOM_FALLBACK_ATTEMPTS := 16


static func assign(cells: Array[CellData], tile_pool: Array[String] = []) -> Array[String]:
	var pair_count := cells.size() / 2
	if cells.size() % 2 != 0:
		push_error("Tile count must be even, got %d" % cells.size())
		return []

	var pool := _resolve_pool(tile_pool, pair_count)
	var pair_types: Array[String] = []
	for index in range(pair_count):
		pair_types.append(pool[index % pool.size()])

	var tile_ids: Array[String] = []
	for pair_type in pair_types:
		tile_ids.append(pair_type)
		tile_ids.append(pair_type)

	tile_ids.shuffle()
	return tile_ids


static func assign_solvable(
	cells: Array[CellData],
	tile_pool: Array[String] = [],
	max_attempts: int = DEFAULT_MAX_ATTEMPTS,
	max_nodes: int = BoardSolver.MAX_NODES,
) -> Array[String]:
	var peeling_attempts := mini(max_attempts, PEELING_ATTEMPTS)
	var peeled := _assign_by_peeling(cells, tile_pool, peeling_attempts)
	if not peeled.is_empty():
		return peeled

	var random_attempts := mini(max_attempts, RANDOM_FALLBACK_ATTEMPTS)
	for _attempt in range(random_attempts):
		var tile_ids := assign(cells, tile_pool)
		if tile_ids.is_empty():
			return []
		if BoardSolver.is_solvable(cells, tile_ids, max_nodes):
			return tile_ids

	return []


## 模拟真实消除：从满盘每次取 2 张当前可选牌配对，倒推牌型分配（保证可解）。
static func _assign_by_peeling(
	cells: Array[CellData],
	tile_pool: Array[String],
	max_attempts: int,
) -> Array[String]:
	var pair_count := cells.size() / 2
	if cells.size() % 2 != 0:
		return []

	var pool := _resolve_pool(tile_pool, pair_count)
	var pair_types: Array[String] = []
	for index in range(pair_count):
		pair_types.append(pool[index % pool.size()])

	for _attempt in range(max_attempts):
		var order := pair_types.duplicate()
		order.shuffle()
		var tile_ids := _build_by_peeling(cells, order)
		if not tile_ids.is_empty():
			return tile_ids

	return []


static func _build_by_peeling(
	cells: Array[CellData],
	pair_types: Array[String],
) -> Array[String]:
	var tile_ids: Array[String] = []
	tile_ids.resize(cells.size())

	var active: Array[int] = []
	for index in cells.size():
		active.append(index)

	for pair_type in pair_types:
		var free_indices := _free_active_indices(cells, active)
		if free_indices.size() < 2:
			return []

		free_indices.shuffle()
		var first_idx: int = free_indices[0]
		var second_idx: int = free_indices[1]

		tile_ids[first_idx] = pair_type
		tile_ids[second_idx] = pair_type
		active.erase(first_idx)
		active.erase(second_idx)

	return tile_ids


static func _free_active_indices(
	cells: Array[CellData],
	active: Array[int],
) -> Array[int]:
	var slots: Array[TileSlot] = []
	for index in active:
		slots.append(TileSlot.from_parts(cells[index], ""))

	var free_indices: Array[int] = []
	for index in active:
		var slot := TileSlot.from_parts(cells[index], "")
		if BoardRules.is_slot_free(slot, slots):
			free_indices.append(index)
	return free_indices


static func _resolve_pool(tile_pool: Array[String], pair_count: int) -> Array[String]:
	if tile_pool.is_empty():
		return _default_pool(pair_count)

	var pool: Array[String] = []
	for tile_id in tile_pool:
		if TileRegistry.get_tile(tile_id) != null:
			pool.append(tile_id)

	if pool.is_empty():
		return _default_pool(pair_count)

	pool.shuffle()
	return pool


static func _default_pool(pair_count: int) -> Array[String]:
	var all_ids := TileRegistry.get_all_ids()
	all_ids.shuffle()

	if all_ids.size() >= pair_count:
		return all_ids.slice(0, pair_count)

	var pool: Array[String] = []
	while pool.size() < pair_count:
		pool.append_array(all_ids)
	return pool.slice(0, pair_count)
