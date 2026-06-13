extends Node2D

@onready var _controller: BoardController = $BoardController
@onready var _status_label: Label = $StatusLabel

var _layout_path: String = ""
var _tile_pool: Array[String] = []


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
			_status_label.text = "布局加载失败"
			return
		resolved_tile_ids = TileAssigner.assign_solvable(cells, tile_pool)

	var tiles := BoardBuilder.build(self, layout_path, resolved_tile_ids, viewport_size)
	if tiles.is_empty():
		_status_label.text = "布局加载失败"
		return

	_controller.initialize(tiles)
	_status_label.text = "消除所有牌即可通关，按 R 重新洗牌"


func restart_level(viewport_size: Vector2 = Vector2(720.0, 1080.0)) -> void:
	start_level(_layout_path, DemoLevel.EMPTY_TILE_IDS, _tile_pool, viewport_size)


func _clear_tiles() -> void:
	for child in get_children():
		if child is MahjongTile:
			child.queue_free()


func _on_board_cleared() -> void:
	_status_label.text = "通关！按 R 再来一局"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_R:
			restart_level(get_viewport_rect().size)
