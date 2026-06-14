class_name RuntimeLevelBuilder
extends RefCounted

## 目标牌数失败时按 +2 / +4 交替加牌重试，直到成功或达到上限。
const BUMP_DELTAS: Array[int] = [0, 2, 4, 2, 4, 2, 4, 2, 4, 2]
const SOLVE_ATTEMPTS := TileAssigner.RUNTIME_MAX_ATTEMPTS
const SOLVE_MAX_NODES := TileAssigner.RUNTIME_MAX_NODES


static func generate(level_id: int, tile_pool: Array[String]) -> Dictionary:
	var layer_count := LayoutGenerator.layer_count_for_level(level_id)
	var target_count := LayoutGenerator.tile_count_for_level(level_id)
	var tile_count := target_count

	for bump_index in BUMP_DELTAS.size():
		if bump_index > 0:
			tile_count += BUMP_DELTAS[bump_index]

		var result := _try_tile_count(
			level_id, tile_pool, tile_count, layer_count, target_count, bump_index
		)
		if result.get("ok", false):
			return result

	push_warning(
		"RuntimeLevelBuilder: level %d failed (target %d, last tried %d)"
		% [level_id, target_count, tile_count]
	)
	return {"ok": false}


static func _try_tile_count(
	level_id: int,
	tile_pool: Array[String],
	tile_count: int,
	layer_count: int,
	target_count: int,
	bump_index: int,
) -> Dictionary:
	if tile_count % 2 != 0:
		tile_count += 1

	var simple := LayoutGenerator.build_simple_layout(tile_count, layer_count)
	if not simple.is_empty():
		var simple_check := _verify(simple, tile_pool)
		if simple_check.get("ok", false):
			return _pack_result(
				level_id, simple, simple_check, tile_count, layer_count,
				target_count, bump_index
			)

	var layout_index := 0
	while true:
		var cells := LayoutGenerator.build_layout_attempt(
			tile_count, layer_count, layout_index
		)
		if cells.is_empty():
			break

		var check := _verify(cells, tile_pool)
		if check.get("ok", false):
			return _pack_result(
				level_id, cells, check, tile_count, layer_count,
				target_count, bump_index
			)
		layout_index += 1

	return {"ok": false}


static func _verify(
	cells: Array[CellData],
	tile_pool: Array[String],
) -> Dictionary:
	return LevelChecker.verify_solvable(
		cells, tile_pool, SOLVE_ATTEMPTS, SOLVE_MAX_NODES
	)


static func _pack_result(
	level_id: int,
	cells: Array[CellData],
	check: Dictionary,
	tile_count: int,
	layer_count: int,
	target_count: int,
	bump_index: int,
) -> Dictionary:
	return {
		"ok": true,
		"cells": cells,
		"tile_ids": check.get("tile_ids", []),
		"tile_count": cells.size(),
		"layer_count": layer_count,
		"target_count": target_count,
		"actual_count": tile_count,
		"bumps": bump_index,
		"extra_tiles": tile_count - target_count,
	}
