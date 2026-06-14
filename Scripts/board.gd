extends Node2D

signal level_cleared(level_id: int, elapsed_sec: float, score: int, matches: int, max_combo: int)
signal stats_changed(score: int, matches: int)
signal block_tip_requested(message: String)
signal match_scored(board_pos: Vector2, amount: int, combo: int)

@onready var _controller: BoardController = $BoardController

var _tile_layer: Node2D

var _tile_pool: Array[String] = []
var _current_level_id: int = 0
var _elapsed_sec: float = 0.0
var _score: int = 0
var _matches: int = 0
var _playing: bool = false
var _combo_tracker := ComboTracker.new()


func _ready() -> void:
	_tile_layer = Node2D.new()
	_tile_layer.name = "TileLayer"
	add_child(_tile_layer)
	_controller.match_scored.connect(_on_match_scored)
	_controller.block_tip_requested.connect(block_tip_requested.emit)


func handle_pointer_at(canvas_pos: Vector2) -> void:
	if not _playing:
		return
	_controller.handle_pointer_at(canvas_pos)


func _process(delta: float) -> void:
	if _playing:
		_elapsed_sec += delta


func start_level_data(level: LevelData, viewport_size: Vector2 = Vector2.ZERO) -> void:
	if viewport_size == Vector2.ZERO:
		viewport_size = UIConstants.viewport_size()
	_current_level_id = level.id
	_tile_pool = LevelCatalog.tile_pool_for(level.id)
	_elapsed_sec = 0.0
	_score = 0
	_matches = 0
	_combo_tracker.reset()
	_playing = true
	_deal_generated_board_async(viewport_size, true)


func regenerate_level(viewport_size: Vector2 = Vector2.ZERO) -> void:
	if viewport_size == Vector2.ZERO:
		viewport_size = UIConstants.viewport_size()
	if not _playing:
		return
	_tile_pool = LevelCatalog.tile_pool_for(_current_level_id)
	_deal_generated_board_async(viewport_size, false)


func request_hint() -> void:
	_controller.show_hint()


func stop_and_clear() -> void:
	_playing = false
	_clear_tiles()
	_controller.reset()


func _deal_generated_board_async(
	viewport_size: Vector2,
	reset_stats: bool,
) -> void:
	_clear_tiles()
	_controller.reset()
	await get_tree().process_frame

	var generated := RuntimeLevelBuilder.generate(_current_level_id, _tile_pool)
	if not generated.get("ok", false):
		_playing = false
		push_error("Failed to generate solvable board for level %d" % _current_level_id)
		return

	if not _playing:
		return

	var cells: Array[CellData] = generated.get("cells", [])
	var raw_tile_ids: Variant = generated.get("tile_ids", [])
	var tile_ids: Array[String] = []
	if typeof(raw_tile_ids) == TYPE_ARRAY:
		for tile_id in raw_tile_ids:
			tile_ids.append(str(tile_id))

	var play_area := UIConstants.play_area(viewport_size)
	var tiles := BoardBuilder.build_from_cells(
		_tile_layer, cells, tile_ids, viewport_size, play_area
	)
	BoardLayoutScaler.apply_layer(_tile_layer, play_area)
	if not _playing:
		for tile in tiles:
			tile.queue_free()
		return
	if tiles.is_empty():
		_playing = false
		return

	if reset_stats:
		_score = 0
		_matches = 0
		_combo_tracker.reset()
		stats_changed.emit(_score, _matches)

	_controller.initialize(tiles)


func _on_match_scored(layer_pos: Vector2, base_amount: int) -> void:
	_matches += 1
	var combo := _combo_tracker.register_match(_elapsed_sec)
	var total_amount := base_amount + ComboTracker.bonus_for(combo)
	_score += total_amount
	stats_changed.emit(_score, _matches)
	match_scored.emit(_collision_pos_to_canvas(layer_pos), total_amount, combo)


func _collision_pos_to_canvas(layer_pos: Vector2) -> Vector2:
	var canvas_pos := _tile_layer.get_global_transform_with_canvas() * layer_pos
	var above := TileConstants.HALF_SIZE.y * _tile_layer.scale.y + UIConstants.SCORE_POP_ABOVE_TILE_PX
	return canvas_pos + Vector2(0.0, -above)


func _clear_tiles() -> void:
	if _tile_layer == null:
		return
	_tile_layer.scale = Vector2.ONE
	_tile_layer.position = Vector2.ZERO
	for child in _tile_layer.get_children():
		if child is MahjongTile:
			child.queue_free()


func _on_board_cleared() -> void:
	_playing = false
	level_cleared.emit(_current_level_id, _elapsed_sec, _score, _matches, _combo_tracker.max_combo)
