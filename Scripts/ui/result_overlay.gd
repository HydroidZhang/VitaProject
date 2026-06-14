extends Control

signal next_level_pressed(level: LevelData)
signal home_pressed

@onready var _title_label: Label = $MainColumn/Frame/TitleLabel
@onready var _time_label: Label = $MainColumn/Content/StatsRow/TimeBox/VBox/ValueLabel
@onready var _score_label: Label = $MainColumn/Content/StatsRow/ScoreBox/VBox/ValueLabel
@onready var _combo_label: Label = $MainColumn/Content/StatsRow/ComboBox/VBox/ValueLabel
@onready var _feedback_label: Label = $MainColumn/Content/FeedbackLabel
@onready var _progress_label: Label = $MainColumn/Content/ProgressRow/ProgressLabel
@onready var _progress_bar: ProgressBar = $MainColumn/Content/ProgressRow/ProgressBar
@onready var _next_button: TextureButton = %NextButton
@onready var _next_label: Label = $MainColumn/Content/NextButton/NextLabel
@onready var _home_button: Button = $MainColumn/Content/HomeButton
@onready var _dim: ColorRect = $Dim
@onready var _main_column: VBoxContainer = $MainColumn

var _next_level: LevelData = null


func _ready() -> void:
	ButtonPressScale.bind_many([_next_button, _home_button])
	_next_button.pressed.connect(_on_next_pressed)
	_home_button.pressed.connect(func(): home_pressed.emit())
	visible = false


func show_result(
	_level_id: int,
	elapsed_sec: float,
	score: int,
	matches: int,
	next_level: LevelData = null,
	max_combo: int = 1,
) -> void:
	if not is_node_ready():
		await ready

	_next_level = next_level
	var total_seconds := int(elapsed_sec)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	_title_label.text = "才华横溢"
	_time_label.text = "%02d:%02d" % [minutes, seconds]
	_score_label.text = str(score)
	_combo_label.text = str(maxi(max_combo, 1))
	_feedback_label.text = _feedback_for(max_combo, matches)
	_update_progress(_level_id)

	if next_level != null:
		_next_label.text = "关卡 %d" % next_level.id
	else:
		_next_label.text = "全部通关"
	_next_button.visible = true
	_home_button.visible = true

	visible = true
	move_to_front()
	await get_tree().process_frame
	await ScreenTransition.show_group([
		[_dim, ScreenTransition.Kind.FADE],
		[_main_column, ScreenTransition.Kind.SCALE_IN],
	])


func hide_result() -> void:
	if not visible:
		return
	await ScreenTransition.hide_group([
		[_dim, ScreenTransition.Kind.FADE],
		[_main_column, ScreenTransition.Kind.SCALE_IN],
	])
	visible = false
	_next_level = null


func _feedback_for(max_combo: int, matches: int) -> String:
	if max_combo >= 5:
		return "手感火热！最高 %d 连击，共消除 %d 对。" % [max_combo, matches]
	if max_combo >= 3:
		return "节奏不错！最高 %d 连击，继续挑战更高连击吧。" % max_combo
	if max_combo >= 2:
		return "打出了 %d 连击，三秒内连续消除可获得连击加分。" % max_combo
	return "击败了 95.27% 的玩家！你的表现堪称完美！"


func _update_progress(level_id: int) -> void:
	var levels := LevelRegistry.load_all()
	var total := maxi(levels.size(), 1)
	var cleared := clampi(level_id, 0, total)
	_progress_bar.max_value = float(total)
	_progress_bar.value = float(cleared)
	_progress_label.text = "关卡 %d / %d" % [cleared, total]


func _on_next_pressed() -> void:
	if _next_level != null:
		next_level_pressed.emit(_next_level)
	else:
		home_pressed.emit()
