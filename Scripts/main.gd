extends Node2D

const BoardScene := preload("res://Scenes/Board.tscn")


func _ready() -> void:
	var board: Node2D = BoardScene.instantiate()
	add_child(board)

	if board.has_method("start_level"):
		board.start_level(
			DemoLevel.LAYOUT_PATH,
			DemoLevel.EMPTY_TILE_IDS,
			DemoLevel.TILE_POOL,
			get_viewport_rect().size,
		)
