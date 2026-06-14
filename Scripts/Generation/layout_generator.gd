class_name LayoutGenerator
extends RefCounted


static func layer_count_for_level(level_id: int) -> int:
	if level_id <= 1:
		return 1
	if level_id <= 10:
		return 2
	return 3


static func tile_count_for_level(level_id: int) -> int:
	if level_id <= 1:
		return 8
	return 8 + (level_id - 1) * 2


static func build_simple_layout(tile_count: int, layer_count: int) -> Array[CellData]:
	if tile_count < 2 or tile_count % 2 != 0:
		return []

	var maxes := GridSlots.max_counts(layer_count)
	match layer_count:
		1:
			if tile_count <= maxes[0]:
				return GridSlots.build_layout([tile_count, 0, 0])
		2:
			for dist in _two_layer_distributions(tile_count, maxes):
				var cells := GridSlots.build_layout(dist)
				if cells.size() == tile_count:
					return cells
		3:
			for dist in _three_layer_distributions(tile_count, maxes):
				var cells := GridSlots.build_layout(dist)
				if cells.size() == tile_count:
					return cells
	return []


static func build_layout_attempt(
	tile_count: int,
	layer_count: int,
	attempt_index: int,
) -> Array[CellData]:
	var distributions := _distributions_for(tile_count, layer_count)
	if attempt_index >= distributions.size():
		return []
	var dist: Array = distributions[attempt_index]
	return GridSlots.build_layout(dist)


static func build_all_candidates(tile_count: int, layer_count: int) -> Array:
	return build_layout_attempts(tile_count, layer_count, 999)


static func build_layout_attempts(
	tile_count: int,
	layer_count: int,
	max_attempts: int,
) -> Array:
	var results: Array = []
	for dist in _distributions_for(tile_count, layer_count):
		var cells := GridSlots.build_layout(dist)
		if cells.is_empty():
			continue
		results.append(cells)
		if results.size() >= max_attempts:
			break
	return results


static func build_pyramid(tile_count: int, layer_count: int) -> Array[CellData]:
	return build_simple_layout(tile_count, layer_count)


static func _distributions_for(tile_count: int, layer_count: int) -> Array:
	var maxes := GridSlots.max_counts(layer_count)
	match layer_count:
		1:
			if tile_count <= maxes[0]:
				return [[tile_count, 0, 0]]
		2:
			return _two_layer_distributions(tile_count, maxes)
		3:
			return _three_layer_distributions(tile_count, maxes)
	return []


static func _two_layer_distributions(
	tile_count: int,
	max_per_layer: Array[int],
) -> Array:
	var results: Array = []
	var try_l1: Array[int] = [4, 2, 6, 8]
	for l1_count in try_l1:
		if l1_count < 2 or l1_count > mini(8, mini(max_per_layer[1], tile_count - 2)):
			continue
		if l1_count % 2 != 0:
			continue
		var l0_count: int = tile_count - l1_count
		if l0_count < 2 or l0_count > max_per_layer[0]:
			continue
		if not _is_nice_l0_count(l0_count):
			continue
		var dist: Array[int] = [l0_count, l1_count, 0]
		if not _contains_distribution(results, dist):
			results.append(dist)

	for l1_count in range(2, mini(9, tile_count - 1), 2):
		var l0_count: int = tile_count - l1_count
		if l0_count < 2 or l0_count > max_per_layer[0]:
			continue
		if not _is_nice_l0_count(l0_count):
			continue
		var dist: Array[int] = [l0_count, l1_count, 0]
		if not _contains_distribution(results, dist):
			results.append(dist)

	return results


static func _is_nice_l0_count(count: int) -> bool:
	var remainder := count % GridSlots.L0_COLS
	return remainder == 0 or remainder >= 3


static func _three_layer_distributions(
	tile_count: int,
	max_per_layer: Array[int],
) -> Array:
	var results: Array = []
	var preferred_pairs: Array = [
		[4, 2],
		[6, 2],
		[8, 2],
		[10, 2],
		[12, 2],
		[4, 4],
		[8, 4],
		[2, 2],
	]
	for pair in preferred_pairs:
		_try_three_layer_dist(
			results, tile_count, max_per_layer, pair[0], pair[1]
		)

	# 牌数多时底层最多 35 格，必须把多余牌放到 L1/L2
	for l2_count in range(2, mini(max_per_layer[2], tile_count - 6) + 1, 2):
		for l1_count in range(2, mini(max_per_layer[1], tile_count - l2_count - 2) + 1, 2):
			_try_three_layer_dist(
				results, tile_count, max_per_layer, l1_count, l2_count
			)

	return results


static func _try_three_layer_dist(
	results: Array,
	tile_count: int,
	max_per_layer: Array[int],
	l1_count: int,
	l2_count: int,
) -> void:
	if l1_count < 2 or l1_count > max_per_layer[1]:
		return
	if l2_count < 2 or l2_count > max_per_layer[2]:
		return
	var l0_count: int = tile_count - l1_count - l2_count
	if l0_count < 2 or l0_count > max_per_layer[0]:
		return
	if not _is_nice_l0_count(l0_count):
		return
	var dist: Array[int] = [l0_count, l1_count, l2_count]
	if not _contains_distribution(results, dist):
		results.append(dist)


static func _contains_distribution(list: Array, dist: Array[int]) -> bool:
	for existing in list:
		if not existing is Array:
			continue
		var existing_dist: Array = existing
		if existing_dist.size() != dist.size():
			continue
		var same := true
		for index in dist.size():
			if int(existing_dist[index]) != dist[index]:
				same = false
				break
		if same:
			return true
	return false
