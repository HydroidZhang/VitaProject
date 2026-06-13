class_name CellData
extends RefCounted

var x: int = 0
var y: int = 0
var layer: int = 0


static func from_dict(data: Dictionary) -> CellData:
	var cell := CellData.new()
	cell.x = int(data.get("x", 0))
	cell.y = int(data.get("y", 0))
	cell.layer = int(data.get("layer", 0))
	return cell
