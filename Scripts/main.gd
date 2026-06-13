extends Node2D

const HomeScreenScene := preload("res://Scenes/HomeScreen.tscn")
const LevelSelectScene := preload("res://Scenes/LevelSelect.tscn")
const BoardScene := preload("res://Scenes/Board.tscn")
const GameHUDScene := preload("res://Scenes/GameHUD.tscn")
const ResultOverlayScene := preload("res://Scenes/ResultOverlay.tscn")
const PlayBackgroundScene := preload("res://Scenes/PlayBackground.tscn")

var _home: Control
var _level_select: Control
var _board: Node2D
var _game_hud: Control
var _result_overlay: Control
var _play_bg: ColorRect
var _progress: ProgressManager
var _current_level: LevelData = null


func _ready() -> void:
	_progress = ProgressManager.load()

	_play_bg = PlayBackgroundScene.instantiate()
	_play_bg.visible = false
	$CanvasLayer.add_child(_play_bg)

	_board = BoardScene.instantiate()
	_board.visible = false
	$CanvasLayer.add_child(_board)
	_board.level_cleared.connect(_on_level_cleared)
	_board.stats_changed.connect(_on_stats_changed)

	_home = HomeScreenScene.instantiate()
	$CanvasLayer.add_child(_home)
	_home.play_pressed.connect(_start_level)
	_home.level_select_pressed.connect(_show_level_select)
	_home.settings_pressed.connect(_show_level_select)

	_level_select = LevelSelectScene.instantiate()
	_level_select.visible = false
	$CanvasLayer.add_child(_level_select)
	_level_select.level_selected.connect(_on_level_selected_from_list)

	_game_hud = GameHUDScene.instantiate()
	_game_hud.visible = false
	$CanvasLayer.add_child(_game_hud)
	_game_hud.back_pressed.connect(_go_home)
	_game_hud.shuffle_pressed.connect(_on_shuffle)
	_game_hud.hint_pressed.connect(_on_hint)
	_game_hud.menu_pressed.connect(_show_level_select)

	_result_overlay = ResultOverlayScene.instantiate()
	$CanvasLayer.add_child(_result_overlay)
	_result_overlay.next_level_pressed.connect(_on_next_level)
	_result_overlay.home_pressed.connect(_go_home)


func _on_stats_changed(score: int, matches: int) -> void:
	_game_hud.sync_stats(score, matches)


func _start_level(level: LevelData) -> void:
	_current_level = level
	_show_game()
	_game_hud.start_level(level)
	_board.start_level_data(level, get_viewport_rect().size)


func _on_level_selected_from_list(level: LevelData) -> void:
	_level_select.visible = false
	_start_level(level)


func _show_game() -> void:
	_home.visible = false
	_level_select.visible = false
	_result_overlay.hide_result()
	_play_bg.visible = true
	_game_hud.visible = true
	_board.visible = true


func _go_home() -> void:
	_play_bg.visible = false
	_game_hud.visible = false
	_board.visible = false
	_result_overlay.hide_result()
	_home.visible = true
	_home.refresh()


func _show_level_select() -> void:
	_level_select.visible = true
	if _level_select.has_method("refresh"):
		_level_select.refresh()


func _on_shuffle() -> void:
	if _board.visible and _board.has_method("restart_level"):
		_board.restart_level(get_viewport_rect().size)
		if _current_level != null:
			_game_hud.start_level(_current_level)


func _on_hint() -> void:
	if _board.visible and _board.has_method("request_hint"):
		_board.request_hint()


func _on_level_cleared(
	level_id: int,
	elapsed_sec: float,
	score: int,
	matches: int,
) -> void:
	var levels := LevelRegistry.load_all()
	var max_id := levels[levels.size() - 1].id if not levels.is_empty() else level_id
	_progress.unlock_next_after(level_id, max_id)

	var next_level: LevelData = null
	if level_id < max_id:
		next_level = LevelRegistry.get_by_id(level_id + 1)

	_result_overlay.show_result(level_id, elapsed_sec, score, matches, next_level)
	_game_hud.visible = false


func _on_next_level(level: LevelData) -> void:
	_result_overlay.hide_result()
	_start_level(level)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			if _board.visible:
				_go_home()
			elif _level_select.visible:
				_level_select.visible = false
