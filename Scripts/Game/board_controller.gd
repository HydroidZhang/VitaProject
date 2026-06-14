class_name BoardController
extends Node

signal board_cleared
signal pair_removed
signal match_scored(board_pos: Vector2, amount: int)
signal block_tip_requested(message: String)

var _state := BoardState.new()
var _selected: MahjongTile = null
var _last_pointer_ms: int = -1000
var _last_pointer_pos: Vector2 = Vector2(-99999.0, -99999.0)


func reset() -> void:
	_state = BoardState.new()
	_selected = null
	_last_pointer_ms = -1000
	_last_pointer_pos = Vector2(-99999.0, -99999.0)


func initialize(tiles: Array[MahjongTile]) -> void:
	reset()
	for tile in tiles:
		_state.register(tile)

	refresh_free_states()


func handle_pointer_at(canvas_pos: Vector2) -> void:
	var now_ms := Time.get_ticks_msec()
	if (
		now_ms - _last_pointer_ms < 100
		and canvas_pos.distance_to(_last_pointer_pos) < 16.0
	):
		return
	_last_pointer_ms = now_ms
	_last_pointer_pos = canvas_pos

	var tile := TilePicker.pick_tile_at(_state.get_active_tiles(), canvas_pos)
	if tile == null:
		return

	SfxManager.play_click()
	if not tile.is_free:
		block_tip_requested.emit(tile.get_block_message())
		return

	_handle_tile_pressed(tile)


func refresh_free_states() -> void:
	var active_tiles := _state.get_active_tiles()
	for tile in active_tiles:
		var block_info := FreeTileChecker.get_block_info(tile, active_tiles)
		var free: bool = FreeTileChecker.is_free(tile, active_tiles)
		if not free and tile == _selected:
			tile.set_selected(false)
			_selected = null
		tile.set_free(free, block_info)

	refresh_match_hints()


func refresh_match_hints() -> void:
	var active_tiles := _state.get_active_tiles()
	for tile in active_tiles:
		var should_show_hint := (
			_selected != null
			and tile != _selected
			and tile.is_free
			and _can_match(_selected, tile)
		)
		tile.set_match_hint(should_show_hint)


func _handle_tile_pressed(tile: MahjongTile) -> void:
	if not tile.is_free:
		return

	if _selected == null:
		_selected = tile
		tile.set_selected(true)
		refresh_match_hints()
		return

	if _selected == tile:
		_selected.set_selected(false)
		_selected = null
		refresh_match_hints()
		return

	if _can_match(_selected, tile):
		var first := _selected
		_selected = null
		first.set_selected(false)
		_remove_pair(first, tile)
		return

	_selected.set_selected(false)
	_selected = tile
	tile.set_selected(true)
	refresh_match_hints()


func show_hint() -> void:
	var active_tiles := _state.get_active_tiles()
	var free_tiles: Array[MahjongTile] = []
	for tile in active_tiles:
		if FreeTileChecker.is_free(tile, active_tiles):
			free_tiles.append(tile)

	for first_index in free_tiles.size():
		for second_index in range(first_index + 1, free_tiles.size()):
			if _can_match(free_tiles[first_index], free_tiles[second_index]):
				free_tiles[first_index].set_match_hint(true)
				free_tiles[second_index].set_match_hint(true)
				return


func _can_match(first: MahjongTile, second: MahjongTile) -> bool:
	if first.tile_type == null or second.tile_type == null:
		return false
	return first.tile_type.id == second.tile_type.id


func _remove_pair(first: MahjongTile, second: MahjongTile) -> void:
	_state.unregister(first)
	_state.unregister(second)
	_selected = null
	refresh_free_states()

	var board := get_parent() as Node2D
	if board == null:
		first.queue_free()
		second.queue_free()
		_finish_pair_removed()
		return

	var board_now_empty := _state.is_empty()
	var on_collision := func(collision_pos: Vector2) -> void:
		match_scored.emit(collision_pos, GameplayConstants.MATCH_SCORE)
	var on_finished := func() -> void:
		first.queue_free()
		second.queue_free()
		_finish_pair_removed(board_now_empty)

	MatchElimination.play(board, first, second, on_collision, on_finished)


func _finish_pair_removed(board_now_empty: bool = false) -> void:
	pair_removed.emit()
	refresh_free_states()
	if board_now_empty:
		SfxManager.play_clear()
		board_cleared.emit()
