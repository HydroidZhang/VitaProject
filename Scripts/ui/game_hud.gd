extends Control

signal back_pressed
signal shuffle_pressed
signal hint_pressed
signal menu_pressed

signal board_pointer_at(canvas_pos: Vector2)

@onready var _level_value: Label = $TopBar/HBox/StatsCenter/LevelStat/LevelValue
@onready var _score_value: Label = $TopBar/HBox/StatsCenter/ScoreStat/ScoreValue
@onready var _match_value: Label = $TopBar/HBox/StatsCenter/MatchStat/MatchValue
@onready var _back_button: TextureButton = %BackButton
@onready var _shuffle_button: TextureButton = %ShuffleButton
@onready var _hint_button: TextureButton = %HintButton
@onready var _shuffle_charge_label: Label = %ShuffleChargeLabel
@onready var _hint_charge_label: Label = %HintChargeLabel
@onready var _menu_button: TextureButton = %MenuButton
@onready var _top_bar: MarginContainer = $TopBar
@onready var _tools: HBoxContainer = $Tools
@onready var _float_tip: Label = $FloatTip
@onready var _score_pop_layer: Control = $ScorePopLayer
@onready var _play_touch: Control = $PlayTouchArea

var score: int = 0
var matches: int = 0
var _shuffle_remaining: int = 0
var _hint_remaining: int = 0
var _float_tip_base_top: float = 0.0
var _float_tip_height: float = 0.0
var _float_tip_tween: Tween = null


func _ready() -> void:
	_float_tip.visible = false
	_float_tip_base_top = _float_tip.offset_top
	_float_tip_height = _float_tip.offset_bottom - _float_tip.offset_top
	_reset_float_tip_position()
	ButtonPressScale.bind_many([
		_back_button,
		_shuffle_button,
		_hint_button,
		_menu_button,
	])
	_back_button.pressed.connect(func(): back_pressed.emit())
	_shuffle_button.pressed.connect(func(): shuffle_pressed.emit())
	_hint_button.pressed.connect(func(): hint_pressed.emit())
	_menu_button.pressed.connect(func(): menu_pressed.emit())


func try_handle_board_pointer(event: InputEvent) -> bool:
	if not PointerInput.consume_primary_press(event):
		return false

	var viewport_pos := PointerInput.event_viewport_position(event)
	if not _is_viewport_pos_in_play_area(viewport_pos):
		return false

	board_pointer_at.emit(PointerInput.viewport_to_canvas(viewport_pos))
	return true


func _is_viewport_pos_in_play_area(viewport_pos: Vector2) -> bool:
	if _top_bar.get_global_rect().has_point(viewport_pos):
		return false
	if _tools.get_global_rect().has_point(viewport_pos):
		return false
	return _play_touch.get_global_rect().has_point(viewport_pos)


func show_block_tip(message: String) -> void:
	if message.is_empty():
		return

	if _float_tip_tween != null:
		_float_tip_tween.kill()

	_float_tip.text = message
	_float_tip.visible = true
	_reset_float_tip_position()
	_float_tip.modulate = Color(1, 1, 1, 0)

	_float_tip_tween = create_tween()
	_float_tip_tween.set_parallel(true)
	_float_tip_tween.tween_property(_float_tip, "modulate:a", 1.0, 0.22)
	_float_tip_tween.tween_property(_float_tip, "offset_top", _float_tip_base_top - 8.0, 0.22)
	_float_tip_tween.tween_property(
		_float_tip,
		"offset_bottom",
		_float_tip_base_top + _float_tip_height - 8.0,
		0.22,
	)
	_float_tip_tween.chain().tween_interval(0.95)
	_float_tip_tween.chain().set_parallel(true)
	_float_tip_tween.tween_property(_float_tip, "modulate:a", 0.0, 0.38)
	_float_tip_tween.tween_property(_float_tip, "offset_top", _float_tip_base_top - 34.0, 0.38)
	_float_tip_tween.tween_property(
		_float_tip,
		"offset_bottom",
		_float_tip_base_top + _float_tip_height - 34.0,
		0.38,
	)
	_float_tip_tween.chain().tween_callback(func() -> void:
		_float_tip.visible = false
		_reset_float_tip_position()
	)


func show_score_pop(canvas_pos: Vector2, amount: int) -> void:
	var local_pos := _score_pop_layer.get_global_transform_with_canvas().affine_inverse() * canvas_pos
	ScorePopEffect.spawn_on_control(_score_pop_layer, local_pos, amount)


func _reset_float_tip_position() -> void:
	_float_tip.offset_top = _float_tip_base_top
	_float_tip.offset_bottom = _float_tip_base_top + _float_tip_height
	_float_tip.modulate = Color.WHITE


func reset_stats() -> void:
	score = 0
	matches = 0
	_update_labels()


func start_level(level: LevelData) -> void:
	_level_value.text = str(level.id)
	reset_stats()
	reset_tool_charges(level.id)


func try_consume_shuffle() -> bool:
	if _shuffle_remaining <= 0:
		return false
	_shuffle_remaining -= 1
	_update_tool_charges_ui()
	return true


func try_consume_hint() -> bool:
	if _hint_remaining <= 0:
		return false
	_hint_remaining -= 1
	_update_tool_charges_ui()
	return true


func reset_tool_charges(level_id: int) -> void:
	_shuffle_remaining = GameplayConstants.shuffle_charges_for_level(level_id)
	_hint_remaining = GameplayConstants.hint_charges_for_level(level_id)
	_update_tool_charges_ui()


func _update_tool_charges_ui() -> void:
	_shuffle_charge_label.text = str(_shuffle_remaining)
	_hint_charge_label.text = str(_hint_remaining)
	_shuffle_button.disabled = _shuffle_remaining <= 0
	_hint_button.disabled = _hint_remaining <= 0
	_shuffle_button.modulate = Color.WHITE if _shuffle_remaining > 0 else Color(0.62, 0.62, 0.62, 1)
	_hint_button.modulate = Color.WHITE if _hint_remaining > 0 else Color(0.62, 0.62, 0.62, 1)


func sync_stats(new_score: int, new_matches: int) -> void:
	score = new_score
	matches = new_matches
	_update_labels()


func _update_labels() -> void:
	_score_value.text = str(score)
	_match_value.text = str(matches)
