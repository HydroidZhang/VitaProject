class_name GridSlots
extends RefCounted

## 固定槽位：L0 5×7(35)、L1 4×6(24)、L2 3×5(15)。
## cell.y：L0 为行号 0,1,2…；L1/L2 为所对齐的底层行号。
const L0_COLS := 5
const L0_ROWS := 7
const L1_COLS := 4
const L1_ROWS := 6
const L2_COLS := 3
const L2_ROWS := 5
const MAX_LAYERS := 3
const ROW_STEP := 1

const L0_MAX := L0_COLS * L0_ROWS
const L1_MAX := L1_COLS * L1_ROWS
const L2_MAX := L2_COLS * L2_ROWS


static func layer0_pos(col: int, row: int) -> Vector2i:
	return Vector2i(col * 2, row)


static func layer1_pos(col: int, row: int) -> Vector2i:
	return Vector2i(col * 2 + 1, row)


static func layer2_pos(col: int, row: int) -> Vector2i:
	return Vector2i(col * 2 + 2, row)


static func all_layer0_slots() -> Array[Vector2i]:
	var slots: Array[Vector2i] = []
	for row in L0_ROWS:
		var row_slots: Array[Vector2i] = []
		for col in L0_COLS:
			row_slots.append(layer0_pos(col, row))
		_sort_row_center(row_slots, L0_COLS)
		slots.append_array(row_slots)
	return slots


static func all_layer1_slots() -> Array[Vector2i]:
	var slots: Array[Vector2i] = []
	for row in L1_ROWS:
		for col in L1_COLS:
			slots.append(layer1_pos(col, row))
	return _sort_l1(slots)


static func all_layer2_slots() -> Array[Vector2i]:
	var slots: Array[Vector2i] = []
	for row in L2_ROWS:
		for col in L2_COLS:
			slots.append(layer2_pos(col, row))
	return _sort_l2(slots)


static func build_layout(counts: Array[int]) -> Array[CellData]:
	var l0_count: int = counts[0]
	var l1_count: int = counts[1] if counts.size() > 1 else 0
	var l2_count: int = counts[2] if counts.size() > 2 else 0

	if l0_count < 0 or l1_count < 0 or l2_count < 0:
		return []
	if l0_count + l1_count + l2_count < 2:
		return []
	if (l0_count + l1_count + l2_count) % 2 != 0:
		return []

	var l0_slots := take_slots(all_layer0_slots(), l0_count)
	if l0_slots.size() != l0_count:
		return []

	var result: Array[CellData] = []
	result.append_array(cells_from_slots(l0_slots, 0))

	if l1_count > 0:
		var l1_pool := _filter_layer1_on_l0(l0_slots)
		var l1_slots := _take_unique_positions(l1_pool, l1_count)
		if l1_slots.size() != l1_count:
			return []
		result.append_array(cells_from_slots(l1_slots, 1))

		if l2_count > 0:
			var l1_cells := _cells_on_layer(result, 1)
			var l2_pool := _filter_layer2_on_l1(l1_cells)
			var l2_slots := _take_unique_positions(l2_pool, l2_count)
			if l2_slots.size() != l2_count:
				return []
			result.append_array(cells_from_slots(l2_slots, 2))
	elif l2_count > 0:
		return []

	return result


static func max_counts(layer_count: int) -> Array[int]:
	match layer_count:
		1:
			return [L0_MAX, 0, 0]
		2:
			return [L0_MAX, L1_MAX, 0]
		3:
			return [L0_MAX, L1_MAX, L2_MAX]
		_:
			return [0, 0, 0]


static func cells_from_slots(slots: Array[Vector2i], layer: int) -> Array[CellData]:
	var cells: Array[CellData] = []
	for pos in slots:
		var cell := CellData.new()
		cell.x = pos.x
		cell.y = pos.y
		cell.layer = layer
		cells.append(cell)
	return cells


static func take_slots(slots: Array[Vector2i], count: int) -> Array[Vector2i]:
	var picked: Array[Vector2i] = []
	for index in mini(count, slots.size()):
		picked.append(slots[index])
	return picked


static func _take_unique_positions(
	slots: Array[Vector2i],
	count: int,
) -> Array[Vector2i]:
	var picked: Array[Vector2i] = []
	var seen: Dictionary = {}
	for pos in slots:
		var key := _slot_key(pos)
		if seen.has(key):
			continue
		seen[key] = true
		picked.append(pos)
		if picked.size() >= count:
			break
	return picked


static func _filter_layer1_on_l0(l0_slots: Array[Vector2i]) -> Array[Vector2i]:
	var l0_set := _slot_set(l0_slots)
	var filtered: Array[Vector2i] = []
	var seen: Dictionary = {}
	for row in L1_ROWS:
		for col in L1_COLS:
			var left := layer0_pos(col, row)
			var right := layer0_pos(col + 1, row)
			if not l0_set.has(_slot_key(left)) or not l0_set.has(_slot_key(right)):
				continue
			var pos := layer1_pos(col, row)
			var key := _slot_key(pos)
			if seen.has(key):
				continue
			seen[key] = true
			filtered.append(pos)
	return _sort_l1_on_l0(filtered, l0_slots)


static func _filter_layer2_on_l1(l1_cells: Array[CellData]) -> Array[Vector2i]:
	var l1_set := _cell_pos_set(l1_cells)
	var filtered: Array[Vector2i] = []
	var seen: Dictionary = {}
	for row in L2_ROWS:
		for col in L2_COLS:
			var left := layer1_pos(col, row)
			var right := layer1_pos(col + 1, row)
			if not l1_set.has(_slot_key(left)) or not l1_set.has(_slot_key(right)):
				continue
			var pos := layer2_pos(col, row)
			var key := _slot_key(pos)
			if seen.has(key):
				continue
			seen[key] = true
			filtered.append(pos)
	return _sort_l2_on_l1(filtered, l1_cells)


static func _cells_on_layer(cells: Array[CellData], layer: int) -> Array[CellData]:
	var result: Array[CellData] = []
	for cell in cells:
		if cell.layer == layer:
			result.append(cell)
	return result


static func _slot_set(slots: Array[Vector2i]) -> Dictionary:
	var seen: Dictionary = {}
	for pos in slots:
		seen[_slot_key(pos)] = true
	return seen


static func _cell_pos_set(cells: Array[CellData]) -> Dictionary:
	var seen: Dictionary = {}
	for cell in cells:
		seen[_slot_key_xy(cell.x, cell.y)] = true
	return seen


static func _slot_key(pos: Vector2i) -> String:
	return _slot_key_xy(pos.x, pos.y)


static func _slot_key_xy(x: int, y: int) -> String:
	return "%d,%d" % [x, y]


static func _sort_row_center(slots: Array[Vector2i], col_count: int) -> void:
	var center_col := (col_count - 1) / 2.0
	slots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var col_a := float(a.x) / 2.0
		var col_b := float(b.x) / 2.0
		return absf(col_a - center_col) < absf(col_b - center_col)
	)


static func _sort_l1_on_l0(
	slots: Array[Vector2i],
	l0_slots: Array[Vector2i],
) -> Array[Vector2i]:
	slots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y != b.y:
			return a.y < b.y
		var center := _center_col_for_row(l0_slots, a.y)
		var col_a := (float(a.x) - 1.0) / 2.0
		var col_b := (float(b.x) - 1.0) / 2.0
		if absf(col_a - center) != absf(col_b - center):
			return absf(col_a - center) < absf(col_b - center)
		return col_a < col_b
	)
	return slots


static func _sort_l2_on_l1(
	slots: Array[Vector2i],
	l1_cells: Array[CellData],
) -> Array[Vector2i]:
	slots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y != b.y:
			return a.y < b.y
		var center := _center_col_for_l1(l1_cells, a.y)
		var col_a := (float(a.x) - 2.0) / 2.0
		var col_b := (float(b.x) - 2.0) / 2.0
		if absf(col_a - center) != absf(col_b - center):
			return absf(col_a - center) < absf(col_b - center)
		return col_a < col_b
	)
	return slots


static func _center_col_for_row(l0_slots: Array[Vector2i], row: int) -> float:
	var cols: Array[int] = []
	for pos in l0_slots:
		if pos.y == row:
			cols.append(pos.x / 2)
	if cols.is_empty():
		return (L0_COLS - 1) / 2.0
	var min_col: int = cols[0]
	var max_col: int = cols[0]
	for col in cols:
		min_col = mini(min_col, col)
		max_col = maxi(max_col, col)
	return (float(min_col) + float(max_col)) / 2.0


static func _center_col_for_l1(l1_cells: Array[CellData], row: int) -> float:
	var cols: Array[int] = []
	for cell in l1_cells:
		if cell.y == row:
			cols.append((cell.x - 1) / 2)
	if cols.is_empty():
		return (L1_COLS - 1) / 2.0
	var min_col: int = cols[0]
	var max_col: int = cols[0]
	for col in cols:
		min_col = mini(min_col, col)
		max_col = maxi(max_col, col)
	return (float(min_col) + float(max_col)) / 2.0


static func _sort_l1(slots: Array[Vector2i]) -> Array[Vector2i]:
	var center_col := (L1_COLS - 1) / 2.0
	slots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var col_a := (float(a.x) - 1.0) / 2.0
		var col_b := (float(b.x) - 1.0) / 2.0
		return absf(col_a - center_col) < absf(col_b - center_col)
	)
	return slots


static func _sort_l2(slots: Array[Vector2i]) -> Array[Vector2i]:
	var center_col := (L2_COLS - 1) / 2.0
	slots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var col_a := (float(a.x) - 2.0) / 2.0
		var col_b := (float(b.x) - 2.0) / 2.0
		return absf(col_a - center_col) < absf(col_b - center_col)
	)
	return slots
