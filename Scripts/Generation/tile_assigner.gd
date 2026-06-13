class_name TileAssigner
extends RefCounted

const DEFAULT_MAX_ATTEMPTS := 200


static func assign(cells: Array[CellData], tile_pool: Array[String] = []) -> Array[String]:
	var pair_count := cells.size() / 2
	if cells.size() % 2 != 0:
		push_error("Tile count must be even, got %d" % cells.size())
		return []

	var pool := _resolve_pool(tile_pool, pair_count)
	var pair_types: Array[String] = []
	for index in pair_count:
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
) -> Array[String]:
	for attempt in max_attempts:
		var tile_ids := assign(cells, tile_pool)
		if tile_ids.is_empty():
			return []
		if BoardSolver.is_solvable(cells, tile_ids):
			return tile_ids

	push_warning("Failed to generate solvable assignment after %d attempts" % max_attempts)
	return assign(cells, tile_pool)


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
