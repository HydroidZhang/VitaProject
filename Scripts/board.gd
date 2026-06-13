extends Node2D

signal level_cleared(level_id: int, elapsed_sec: float, score: int, matches: int)
signal stats_changed(score: int, matches: int)

@onready var _controller: BoardController = $BoardController

var _layout_path: String = ""
var _tile_pool: Array[String] = []
var _current_level_id: int = 0
var _elapsed_sec: float = 0.0
var _score: int = 0
var _matches: int = 0
var _playing: bool = false


func _ready() -> void:
	_controller.pair_removed.connect(_on_pair_removed)


func _process(delta: float) -> void:
	if _playing:
		_elapsed_sec += delta


func start_level_data(level: LevelData, viewport_size: Vector2 = Vector2(720.0, 1080.0)) -> void:
	_current_level_id = level.id
	_layout_path = level.layout_path
	_tile_pool = level.tile_pool.duplicate()
	_elapsed_sec = 0.0
	_score = 0
	_matches = 0
	_playing = true
	start_level(level.layout_path, DemoLevel.EMPTY_TILE_IDS, _tile_pool, viewport_size)


func start_level(
	layout_path: String,
	tile_ids: Array[String] = DemoLevel.EMPTY_TILE_IDS,
	tile_pool: Array[String] = DemoLevel.TILE_POOL,
	viewport_size: Vector2 = Vector2(720.0, 1080.0),
) -> void:
	_layout_path = layout_path
	_tile_pool = tile_pool

	_clear_tiles()
	_controller.reset()

	var resolved_tile_ids := tile_ids
	if resolved_tile_ids.is_empty():
		var cells := LayoutLoader.load(layout_path)
		if cells.is_empty():
			_playing = false
			return
		resolved_tile_ids = TileAssigner.assign_solvable(cells, tile_pool)

	var play_area := Rect2(
		0.0,
		UIConstants.TOP_BAR_H,
		viewport_size.x,
		viewport_size.y - UIConstants.TOP_BAR_H - UIConstants.BOTTOM_BAR_H,
	)
	var tiles := BoardBuilder.build(
		self, layout_path, resolved_tile_ids, viewport_size, play_area
	)
	if tiles.is_empty():
		_playing = false
		return

	_controller.initialize(tiles)


func restart_level(viewport_size: Vector2 = Vector2(720.0, 1080.0)) -> void:
	var level := LevelRegistry.get_by_id(_current_level_id)
	if level != null:
		start_level_data(level, viewport_size)


func request_hint() -> void:
	_controller.show_hint()


func _on_pair_removed() -> void:
	_matches += 1
	_score += 100
	stats_changed.emit(_score, _matches)


func _clear_tiles() -> void:
	for child in get_children():
		if child is MahjongTile:
			child.queue_free()


func _on_board_cleared() -> void:
	_playing = false
	level_cleared.emit(_current_level_id, _elapsed_sec, _score, _matches)
