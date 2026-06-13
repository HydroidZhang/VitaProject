class_name BoardController
extends Node

signal board_cleared

var _state := BoardState.new()
var _selected: MahjongTile = null


func reset() -> void:
	_state = BoardState.new()
	_selected = null


func initialize(tiles: Array[MahjongTile]) -> void:
	reset()
	for tile in tiles:
		_state.register(tile)
		tile.pressed.connect(_on_tile_pressed.bind(tile))

	refresh_free_states()


func refresh_free_states() -> void:
	var active_tiles := _state.get_active_tiles()
	for tile in active_tiles:
		var free := FreeTileChecker.is_free(tile, active_tiles)
		if not free and tile == _selected:
			tile.set_selected(false)
			_selected = null
		tile.set_free(free)

	refresh_match_hints()


func refresh_match_hints() -> void:
	var active_tiles := _state.get_active_tiles()
	for tile in active_tiles:
		var show_hint := (
			_selected != null
			and tile != _selected
			and tile.is_free
			and _can_match(_selected, tile)
		)
		tile.set_match_hint(show_hint)


func _on_tile_pressed(tile: MahjongTile) -> void:
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


func _can_match(first: MahjongTile, second: MahjongTile) -> bool:
	if first.tile_type == null or second.tile_type == null:
		return false
	return first.tile_type.id == second.tile_type.id


func _remove_pair(first: MahjongTile, second: MahjongTile) -> void:
	_state.unregister(first)
	_state.unregister(second)
	first.queue_free()
	second.queue_free()
	refresh_free_states()

	if _state.is_empty():
		board_cleared.emit()
