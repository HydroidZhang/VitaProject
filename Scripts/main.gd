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
var _transitioning: bool = false


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
	_home.play_pressed.connect(_on_play_pressed)
	_home.level_select_pressed.connect(_on_level_select_pressed)
	_home.settings_pressed.connect(_show_settings)

	_level_select = LevelSelectScene.instantiate()
	_level_select.visible = false
	$CanvasLayer.add_child(_level_select)
	_level_select.level_selected.connect(_on_level_selected_from_list)

	_game_hud = GameHUDScene.instantiate()
	_game_hud.visible = false
	$CanvasLayer.add_child(_game_hud)
	_game_hud.back_pressed.connect(_on_back_pressed)
	_game_hud.shuffle_pressed.connect(_on_shuffle)
	_game_hud.hint_pressed.connect(_on_hint)
	_game_hud.menu_pressed.connect(_on_menu_pressed)
	_game_hud.board_pointer_at.connect(_on_board_pointer_at)

	_settings_overlay = SettingsOverlayScene.instantiate()
	_settings_overlay.z_index = 30
	$CanvasLayer.add_child(_settings_overlay)

	_result_overlay = ResultOverlayScene.instantiate()
	_result_overlay.z_index = 20
	$CanvasLayer.add_child(_result_overlay)
	_result_overlay.next_level_pressed.connect(_on_next_level)
	_result_overlay.home_pressed.connect(_on_result_home_pressed)

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


func _on_match_scored(canvas_pos: Vector2, amount: int, combo: int = 1) -> void:
	if _game_hud.has_method("show_score_pop"):
		_game_hud.show_score_pop(canvas_pos, amount, combo)


func _on_play_pressed(level: LevelData) -> void:
	_run_start_level(level)


func _on_level_select_pressed() -> void:
	_run_show_level_select()


func _on_back_pressed() -> void:
	_run_go_home()


func _on_menu_pressed() -> void:
	_run_show_level_select()


func _on_result_home_pressed() -> void:
	_run_go_home()


func _run_start_level(level: LevelData) -> void:
	if _transitioning:
		return
	_transitioning = true
	_current_level = level
	await _enter_game(false)
	_game_hud.start_level(level)
	_board.start_level_data(level, ScreenAdapter.get_layout_size())
	_transitioning = false


func _on_level_selected_from_list(level: LevelData) -> void:
	if _transitioning:
		return
	_run_start_level_from_list(level)


func _run_start_level_from_list(level: LevelData) -> void:
	if _transitioning:
		return
	_transitioning = true
	if _level_select.visible:
		await ScreenTransition.hide_out(
			_level_select,
			ScreenTransition.Kind.FADE,
			ScreenTransition.GENTLE_HIDE_DURATION,
		)
	_current_level = level
	await _enter_game(false)
	_game_hud.start_level(level)
	_board.start_level_data(level, ScreenAdapter.get_layout_size())
	_transitioning = false


func _enter_game(resume_running: bool = false) -> void:
	_paused_from_game = false
	if _result_overlay.visible:
		await _result_overlay.hide_result()

	var hide_items: Array = []
	if _home.visible:
		hide_items.append([_home, ScreenTransition.Kind.FADE])
	if _level_select.visible:
		hide_items.append([_level_select, ScreenTransition.Kind.FADE])

	_play_bg.visible = true
	_game_hud.visible = true
	_board.visible = true

	var show_items: Array = [
		[_play_bg, ScreenTransition.Kind.FADE],
		[_game_hud, ScreenTransition.Kind.FADE],
		[_board, ScreenTransition.Kind.FADE],
	]

	if hide_items.is_empty():
		await get_tree().process_frame
		await ScreenTransition.show_group(show_items, ScreenTransition.GENTLE_SHOW_DURATION)
	else:
		await ScreenTransition.crossfade(hide_items, show_items)

	if resume_running:
		BgmManager.play_running()
	else:
		BgmManager.play_level_start()


func _run_go_home() -> void:
	if _transitioning:
		return
	_transitioning = true
	_paused_from_game = false

	if _result_overlay.visible:
		await _result_overlay.hide_result()

	if _board.has_method("stop_and_clear"):
		_board.stop_and_clear()

	_level_select.visible = false
	_home.refresh()
	_home.visible = true

	if _board.visible or _game_hud.visible or _play_bg.visible:
		await ScreenTransition.crossfade(
			[
				[_game_hud, ScreenTransition.Kind.FADE],
				[_board, ScreenTransition.Kind.FADE],
				[_play_bg, ScreenTransition.Kind.FADE],
			],
			[[_home, ScreenTransition.Kind.FADE]],
		)
	else:
		await get_tree().process_frame
		await ScreenTransition.show_in(
			_home,
			ScreenTransition.Kind.FADE,
			ScreenTransition.GENTLE_SHOW_DURATION,
		)

	BgmManager.play_home()
	_transitioning = false


func _show_settings() -> void:
	if _transitioning:
		return
	if _settings_overlay.has_method("open"):
		_settings_overlay.open()


func _run_show_level_select() -> void:
	if _transitioning:
		return
	_transitioning = true
	_paused_from_game = _board.visible

	if _result_overlay.visible:
		await _result_overlay.hide_result()

	if _paused_from_game:
		await ScreenTransition.hide_group([
			[_game_hud, ScreenTransition.Kind.FADE],
			[_board, ScreenTransition.Kind.FADE],
			[_play_bg, ScreenTransition.Kind.FADE],
		], ScreenTransition.GENTLE_HIDE_DURATION)
	elif _home.visible:
		if _level_select.has_method("refresh"):
			_level_select.refresh()
		_level_select.visible = true
		await ScreenTransition.crossfade(
			[[_home, ScreenTransition.Kind.FADE]],
			[[_level_select, ScreenTransition.Kind.FADE]],
		)
		if not _paused_from_game:
			BgmManager.play_home()
		_transitioning = false
		return

	if _level_select.has_method("refresh"):
		_level_select.refresh()
	_level_select.visible = true
	await get_tree().process_frame
	await ScreenTransition.show_in(
		_level_select,
		ScreenTransition.Kind.FADE,
		ScreenTransition.GENTLE_SHOW_DURATION,
	)

	if not _paused_from_game:
		BgmManager.play_home()
	_transitioning = false


func _on_shuffle() -> void:
	if _transitioning:
		return
	if not _game_hud.try_consume_shuffle():
		return
	if _board.visible and _board.has_method("regenerate_level"):
		SfxManager.play_shuffle()
		_board.regenerate_level(ScreenAdapter.get_layout_size())


func _on_hint() -> void:
	if _transitioning:
		return
	if not _game_hud.try_consume_hint():
		return
	if _board.visible and _board.has_method("request_hint"):
		_board.request_hint()


func _on_level_cleared(
	level_id: int,
	elapsed_sec: float,
	score: int,
	matches: int,
	max_combo: int = 1,
) -> void:
	var levels := LevelRegistry.load_all()
	var max_id := levels[levels.size() - 1].id if not levels.is_empty() else level_id
	_progress.unlock_next_after(level_id, max_id)

	var next_level: LevelData = null
	if level_id < max_id:
		next_level = LevelRegistry.get_by_id(level_id + 1)

	_transitioning = true
	await ScreenTransition.hide_group([
		[_game_hud, ScreenTransition.Kind.FADE],
		[_board, ScreenTransition.Kind.FADE],
	])
	await _result_overlay.show_result(
		level_id, elapsed_sec, score, matches, next_level, max_combo
	)
	BgmManager.play_win()
	_transitioning = false


func _on_next_level(level: LevelData) -> void:
	_run_start_level(level)


func _run_escape() -> void:
	if _transitioning:
		return
	_transitioning = true
	if _level_select.visible:
		await ScreenTransition.hide_out(
			_level_select,
			ScreenTransition.Kind.FADE,
			ScreenTransition.GENTLE_HIDE_DURATION,
		)
		if _paused_from_game:
			await _enter_game(true)
		else:
			_home.visible = true
			await get_tree().process_frame
			await ScreenTransition.show_in(
				_home,
				ScreenTransition.Kind.FADE,
				ScreenTransition.GENTLE_SHOW_DURATION,
			)
	elif _board.visible:
		_transitioning = false
		_run_go_home()
		return
	_transitioning = false


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return

	if _board.visible and _game_hud.visible and _game_hud.has_method("try_handle_board_pointer"):
		if _game_hud.try_handle_board_pointer(event):
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_run_escape()
