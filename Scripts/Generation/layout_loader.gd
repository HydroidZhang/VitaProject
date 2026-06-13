class_name LayoutLoader
extends RefCounted

static func load(path: String) -> Array[CellData]:
	if not FileAccess.file_exists(path):
		push_error("Layout file not found: %s" % path)
		return []

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open layout file: %s" % path)
		return []

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("Invalid JSON in layout file: %s" % path)
		return []

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Layout root must be an object: %s" % path)
		return []

	var data: Dictionary = parsed
	if not data.has("cells"):
		push_error("Layout missing 'cells' array: %s" % path)
		return []

	var raw_cells: Variant = data["cells"]
	if typeof(raw_cells) != TYPE_ARRAY:
		push_error("Layout 'cells' must be an array: %s" % path)
		return []

	if raw_cells.is_empty():
		push_error("Layout 'cells' must not be empty: %s" % path)
		return []

	var cells: Array[CellData] = []
	for index in raw_cells.size():
		var raw_cell: Variant = raw_cells[index]
		if typeof(raw_cell) != TYPE_DICTIONARY:
			push_error("Cell %d is not an object in layout: %s" % [index, path])
			return []

		var cell_dict: Dictionary = raw_cell
		for field in ["x", "y", "layer"]:
			if not cell_dict.has(field):
				push_error("Cell %d missing '%s' in layout: %s" % [index, field, path])
				return []

		cells.append(CellData.from_dict(cell_dict))

	return cells
