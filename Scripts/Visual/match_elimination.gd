class_name MatchElimination
extends RefCounted

const MERGE_DURATION := 0.24
const SPREAD_DURATION := 0.14
const FADE_DURATION := 0.16
const MERGE_ALPHA := 0.62
const SPREAD_OFFSET := TileConstants.HALF_SIZE.x + 8.0


static func play(
	board: Node2D,
	first: MahjongTile,
	second: MahjongTile,
	on_collision: Callable,
	on_finished: Callable,
) -> void:
	var same_column := _is_same_column(first, second)
	var sides := _assign_sides(first, second, same_column)
	var left: MahjongTile = sides[0]
	var right: MahjongTile = sides[1]
	var lane_y := (first.position.y + second.position.y) * 0.5
	var merge_x := _collision_center_x(first, second, same_column)
	var collision_pos := Vector2(merge_x, lane_y)
	var top_z := mini(maxi(first.z_index, second.z_index) + 260, UIConstants.GAME_HUD_Z_INDEX - 1)

	for tile in [first, second]:
		tile.begin_pair_elimination(top_z)

	if same_column:
		var left_spread := Vector2(merge_x - SPREAD_OFFSET, lane_y)
		var right_spread := Vector2(merge_x + SPREAD_OFFSET, lane_y)

		var spread_tween := board.create_tween()
		spread_tween.set_parallel(true)
		spread_tween.tween_property(left, "position", left_spread, SPREAD_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		spread_tween.tween_property(right, "position", right_spread, SPREAD_DURATION)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		spread_tween.finished.connect(func() -> void:
			_run_merge(board, left, right, collision_pos, on_collision, on_finished)
		)
		return

	left.position.y = lane_y
	right.position.y = lane_y
	_run_merge(board, left, right, collision_pos, on_collision, on_finished)


static func _run_merge(
	board: Node2D,
	left: MahjongTile,
	right: MahjongTile,
	collision_pos: Vector2,
	on_collision: Callable,
	on_finished: Callable,
) -> void:
	var tween := board.create_tween()
	tween.set_parallel(true)
	tween.tween_property(left, "position", collision_pos, MERGE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(right, "position", collision_pos, MERGE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(left, "modulate:a", MERGE_ALPHA, MERGE_DURATION * 0.75)
	tween.tween_property(right, "modulate:a", MERGE_ALPHA, MERGE_DURATION * 0.75)

	tween.chain().tween_callback(func() -> void:
		SfxManager.play_collision()
		on_collision.call(collision_pos)
	)

	tween.set_parallel(true)
	tween.tween_property(left, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_property(right, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_property(left, "scale", Vector2(0.72, 0.72), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(right, "scale", Vector2(0.72, 0.72), FADE_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(on_finished)


static func _is_same_column(first: MahjongTile, second: MahjongTile) -> bool:
	if first.cell != null and second.cell != null:
		return (
			first.cell.x < second.cell.x + BoardRules.TILE_GRID_WIDTH
			and second.cell.x < first.cell.x + BoardRules.TILE_GRID_WIDTH
		)
	return absf(first.position.x - second.position.x) <= TileConstants.HALF_SIZE.x


static func _grid_aligned_x(tile: MahjongTile) -> float:
	if tile.cell == null:
		return tile.position.x
	return tile.position.x - GridConverter.layer_depth_offset(tile.layer).x


static func _collision_center_x(
	first: MahjongTile,
	second: MahjongTile,
	same_column: bool,
) -> float:
	if same_column:
		return (_grid_aligned_x(first) + _grid_aligned_x(second)) * 0.5
	return (first.position.x + second.position.x) * 0.5


static func _assign_sides(
	first: MahjongTile,
	second: MahjongTile,
	same_column: bool,
) -> Array[MahjongTile]:
	var sides: Array[MahjongTile] = []
	if same_column:
		if first.position.y <= second.position.y:
			sides.append(first)
			sides.append(second)
		else:
			sides.append(second)
			sides.append(first)
		return sides

	if first.position.x <= second.position.x:
		sides.append(first)
		sides.append(second)
	else:
		sides.append(second)
		sides.append(first)
	return sides
