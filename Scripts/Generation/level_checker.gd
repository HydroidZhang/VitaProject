class_name LevelChecker
extends RefCounted

const DEFAULT_MAX_ATTEMPTS := 500


static func verify_layout(cells: Array[CellData]) -> Dictionary:
	if cells.is_empty():
		return _fail("布局为空")
	if cells.size() % 2 != 0:
		return _fail("牌数必须为偶数，当前 %d" % cells.size())

	return {
		"ok": true,
		"message": "布局合法（%d 张牌）" % cells.size(),
		"tile_count": cells.size(),
	}


static func verify_solvable(
	cells: Array[CellData],
	tile_pool: Array[String] = [],
	max_attempts: int = DEFAULT_MAX_ATTEMPTS,
	max_nodes: int = BoardSolver.MAX_NODES,
) -> Dictionary:
	var layout_result := verify_layout(cells)
	if not layout_result.ok:
		return layout_result

	var tile_ids := TileAssigner.assign_solvable(
		cells, tile_pool, max_attempts, max_nodes
	)
	if tile_ids.is_empty():
		return _fail("无法生成可解牌型")

	return {
		"ok": true,
		"message": "可解（%d 张牌）" % cells.size(),
		"tile_count": cells.size(),
		"tile_ids": tile_ids,
	}


static func verify_level(level: LevelData, max_attempts: int = DEFAULT_MAX_ATTEMPTS) -> Dictionary:
	if level == null:
		return _fail("关卡数据为空")

	var cells := LayoutLoader.load(level.layout_path)
	if cells.is_empty():
		return _fail("无法加载布局: %s" % level.layout_path)

	return verify_solvable(cells, level.tile_pool, max_attempts)


static func verify_all_levels(max_attempts: int = DEFAULT_MAX_ATTEMPTS) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for level in LevelRegistry.load_all():
		var result := verify_level(level, max_attempts)
		result["level_id"] = level.id
		result["level_name"] = level.name
		results.append(result)
	return results


static func print_report(results: Array[Dictionary]) -> void:
	var passed := 0
	for result in results:
		var level_id: int = result.get("level_id", 0)
		var level_name: String = result.get("level_name", "")
		if result.ok:
			passed += 1
			print("[OK] 关卡 %d %s — %s" % [level_id, level_name, result.message])
		else:
			push_error("[FAIL] 关卡 %d %s — %s" % [level_id, level_name, result.message])
	print("关卡校验: %d / %d 通过" % [passed, results.size()])


static func _fail(message: String) -> Dictionary:
	return {
		"ok": false,
		"message": message,
		"tile_count": 0,
	}
