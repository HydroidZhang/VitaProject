extends Node2D

const HomeScreenScene := preload("res://Scenes/HomeScreen.tscn")
const LevelSelectScene := preload("res://Scenes/LevelSelect.tscn")
const BoardScene := preload("res://Scenes/Board.tscn")
const GameHUDScene := preload("res://Scenes/GameHUD.tscn")
const ResultOverlayScene := preload("res://Scenes/ResultOverlay.tscn")
const SettingsOverlayScene := preload("res://Scenes/SettingsOverlay.tscn")
const PlayBackgroundScene := preload("res://Scenes/PlayBackground.tscn")

var _home: Control
var _level_select: Control
var _board: Node2D
var _game_hud: Control
var _result_overlay: Control
var _settings_overlay: Control
var _play_bg: TextureRect
var _progress: ProgressManager
var _current_level: LevelData = null
var _paused_from_game: bool = false


func _ready() -> void:
	await HotUpdateManager.ensure_ready()
	_bootstrap_ui()


func _bootstrap_ui() -> void:
	_progress = ProgressManager.load()

	_play_bg = PlayBackgroundScene.instantiate()
	_play_bg.visible = false
	$CanvasLayer.add_child(_play_bg)

	_board = BoardScene.instantiate()
	_board.visible = false
	$CanvasLayer.add_child(_board)
	_board.level_cleared.connect(_on_level_cleared)
	_board.stats_changed.connect(_on_stats_changed)
	_board.block_tip_requested.connect(_on_block_tip_requested)
	_board.match_scored.connect(_on_match_scored)

	_home = HomeScreenScene.instantiate()
	$CanvasLayer.add_child(_home)
	_home.play_pressed.connect(_start_level)
	_home.level_select_pressed.connect(_show_level_select)
	_home.settings_pressed.connect(_show_settings)

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
	_game_hud.board_pointer_at.connect(_on_board_pointer_at)

	_settings_overlay = SettingsOverlayScene.instantiate()
	_settings_overlay.z_index = 30
	$CanvasLayer.add_child(_settings_overlay)

	_result_overlay = ResultOverlayScene.instantiate()
	_result_overlay.z_index = 20
	$CanvasLayer.add_child(_result_overlay)
	_result_overlay.next_level_pressed.connect(_on_next_level)
	_result_overlay.home_pressed.connect(_go_home)

	GameSettings.changed.connect(_on_game_settings_changed)
	BgmManager.play_home()


func _on_game_settings_changed() -> void:
	if not GameSettings.music_enabled:
		return
	if _home.visible or (_level_select.visible and not _paused_from_game):
		BgmManager.play_home()


func _on_stats_changed(score: int, matches: int) -> void:
	_game_hud.sync_stats(score, matches)


func _on_block_tip_requested(message: String) -> void:
	if _game_hud.has_method("show_block_tip"):
		_game_hud.show_block_tip(message)


func _on_board_pointer_at(canvas_pos: Vector2) -> void:
	if _board.visible and _board.has_method("handle_pointer_at"):
		_board.handle_pointer_at(canvas_pos)


func _on_match_scored(canvas_pos: Vector2, amount: int) -> void:
	if _game_hud.has_method("show_score_pop"):
		_game_hud.show_score_pop(canvas_pos, amount)


func _start_level(level: LevelData) -> void:
	_current_level = level
	_show_game(false)
	_game_hud.start_level(level)
	_board.start_level_data(level, ScreenAdapter.get_layout_size())


func _on_level_selected_from_list(level: LevelData) -> void:
	_level_select.visible = false
	_start_level(level)


func _show_game(resume_running: bool = false) -> void:
	_paused_from_game = false
	_home.visible = false
	_level_select.visible = false
	_result_overlay.hide_result()
	_play_bg.visible = true
	_game_hud.visible = true
	_board.visible = true
	if resume_running:
		BgmManager.play_running()
	else:
		BgmManager.play_level_start()


func _go_home() -> void:
	_paused_from_game = false
	_play_bg.visible = false
	_game_hud.visible = false
	_board.visible = false
	if _board.has_method("stop_and_clear"):
		_board.stop_and_clear()
	_result_overlay.hide_result()
	_level_select.visible = false
	_home.visible = true
	_home.refresh()
	BgmManager.play_home()


func _show_settings() -> void:
	if _settings_overlay.has_method("open"):
		_settings_overlay.open()


func _show_level_select() -> void:
	_paused_from_game = _board.visible
	if _paused_from_game:
		_play_bg.visible = false
		_game_hud.visible = false
		_board.visible = false
	else:
		_home.visible = false
	_result_overlay.hide_result()
	_level_select.visible = true
	if _level_select.has_method("refresh"):
		_level_select.refresh()
	if not _paused_from_game:
		BgmManager.play_home()


func _on_shuffle() -> void:
	if not _game_hud.try_consume_shuffle():
		return
	if _board.visible and _board.has_method("regenerate_level"):
		SfxManager.play_shuffle()
		_board.regenerate_level(ScreenAdapter.get_layout_size())


func _on_hint() -> void:
	if not _game_hud.try_consume_hint():
		return
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

	_game_hud.visible = false
	_board.visible = false
	_result_overlay.show_result(level_id, elapsed_sec, score, matches, next_level)
	BgmManager.play_win()


func _on_next_level(level: LevelData) -> void:
	_result_overlay.hide_result()
	_start_level(level)


func _unhandled_input(event: InputEvent) -> void:
	if _board.visible and _game_hud.visible and _game_hud.has_method("try_handle_board_pointer"):
		if _game_hud.try_handle_board_pointer(event):
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			if _level_select.visible:
				_level_select.visible = false
				if _paused_from_game:
					_show_game(true)
				else:
					_home.visible = true
			elif _board.visible:
				_go_home()
