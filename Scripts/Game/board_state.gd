class_name BoardState
extends RefCounted

var _tiles: Array[MahjongTile] = []


func register(tile: MahjongTile) -> void:
	_tiles.append(tile)


func unregister(tile: MahjongTile) -> void:
	_tiles.erase(tile)


func get_active_tiles() -> Array[MahjongTile]:
	var active: Array[MahjongTile] = []
	for tile in _tiles:
		if is_instance_valid(tile):
			active.append(tile)
	return active


func is_empty() -> bool:
	return get_active_tiles().is_empty()
