class_name FreeTileChecker
extends RefCounted

static func is_free(tile: MahjongTile, tiles: Array[MahjongTile]) -> bool:
	if not is_instance_valid(tile) or tile.cell == null:
		return false
	return BoardRules.is_slot_free(_to_slot(tile), _to_slots(tiles))


static func get_block_info(tile: MahjongTile, tiles: Array[MahjongTile]) -> Dictionary:
	if not is_instance_valid(tile) or tile.cell == null:
		return {
			"covered": true,
			"left_blocked": true,
			"right_blocked": true,
		}
	return BoardRules.get_block_info(_to_slot(tile), _to_slots(tiles))


static func _to_slot(tile: MahjongTile) -> TileSlot:
	return TileSlot.from_parts(tile.cell, tile.tile_type.id if tile.tile_type else "")


static func _to_slots(tiles: Array[MahjongTile]) -> Array[TileSlot]:
	var slots: Array[TileSlot] = []
	for tile in tiles:
		if is_instance_valid(tile) and tile.cell != null:
			slots.append(_to_slot(tile))
	return slots
