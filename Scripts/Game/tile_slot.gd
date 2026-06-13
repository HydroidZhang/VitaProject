class_name TileSlot
extends RefCounted

var cell: CellData
var tile_id: String = ""


static func from_parts(cell_data: CellData, id: String) -> TileSlot:
	var slot := TileSlot.new()
	slot.cell = cell_data
	slot.tile_id = id
	return slot
