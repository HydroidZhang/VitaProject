class_name MatchElimination
extends RefCounted

const MERGE_DURATION := 0.2
const SPREAD_DURATION := 0.14
const SHATTER_DURATION := 0.2
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
			_run_merge(board, left, right, collision_pos, top_z, on_collision, on_finished)
		)
		return

	left.position.y = lane_y
	right.position.y = lane_y
	_run_merge(board, left, right, collision_pos, top_z, on_collision, on_finished)


static func _run_merge(
	board: Node2D,
	left: MahjongTile,
	right: MahjongTile,
	collision_pos: Vector2,
	top_z: int,
	on_collision: Callable,
	on_finished: Callable,
) -> void:
	var tween := board.create_tween()
	tween.set_parallel(true)
	tween.tween_property(left, "position", collision_pos, MERGE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(right, "position", collision_pos, MERGE_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(left, "scale", Vector2(1.06, 1.06), MERGE_DURATION * 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(right, "scale", Vector2(1.06, 1.06), MERGE_DURATION * 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(func() -> void:
		SfxManager.play_collision()
		var tile_layer := left.get_parent() as Node2D
		if tile_layer != null:
			MatchCollisionEffect.spawn(tile_layer, collision_pos, left, right, top_z + 1)
		_shake_tile_layer(board)
		_shatter_tile(board, left, collision_pos, Vector2(-1.0, -0.18))
		_shatter_tile(board, right, collision_pos, Vector2(1.0, -0.18))
		on_collision.call(collision_pos)
	)

	tween.chain().tween_interval(SHATTER_DURATION)
	tween.chain().tween_callback(on_finished)


static func _shatter_tile(
	board: Node2D,
	tile: MahjongTile,
	collision_pos: Vector2,
	burst_dir: Vector2,
) -> void:
	var direction := burst_dir
	if tile.position.distance_squared_to(collision_pos) > 1.0:
		direction = (tile.position - collision_pos).normalized()
	direction = direction.normalized()

	var impact_tween := board.create_tween()
	impact_tween.tween_property(tile, "scale", Vector2(1.18, 0.78), 0.045)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	impact_tween.chain().set_parallel(true)
	impact_tween.tween_property(
		tile,
		"position",
		tile.position + direction * 26.0 + Vector2(0, -14.0),
		0.18,
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(tile, "rotation", direction.x * 0.32, 0.18)
	impact_tween.tween_property(tile, "scale", Vector2(0.22, 0.38), 0.18)
	impact_tween.tween_property(tile, "modulate:a", 0.0, 0.15)


static func _shake_tile_layer(board: Node2D) -> void:
	var layer := board.get_node_or_null("TileLayer") as Node2D
	if layer == null:
		return

	var origin := layer.position
	var tween := board.create_tween()
	tween.tween_property(layer, "position", origin + Vector2(5.0, 2.0), 0.03)
	tween.tween_property(layer, "position", origin + Vector2(-4.0, 1.0), 0.03)
	tween.tween_property(layer, "position", origin + Vector2(2.0, -1.0), 0.03)
	tween.tween_property(layer, "position", origin, 0.04)


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
