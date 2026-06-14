extends Control

signal next_level_pressed(level: LevelData)
signal home_pressed

@onready var _title_label: Label = $MainColumn/Frame/TitleLabel
@onready var _time_label: Label = $MainColumn/Content/StatsRow/TimeBox/VBox/ValueLabel
@onready var _score_label: Label = $MainColumn/Content/StatsRow/ScoreBox/VBox/ValueLabel
@onready var _combo_label: Label = $MainColumn/Content/StatsRow/ComboBox/VBox/ValueLabel
@onready var _feedback_label: Label = $MainColumn/Content/FeedbackLabel
@onready var _next_button: TextureButton = %NextButton
@onready var _next_label: Label = $MainColumn/Content/NextButton/NextLabel
@onready var _home_button: Button = $MainColumn/Content/HomeButton

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
	_combo_label.text = str(maxi(matches, 1))
	_feedback_label.text = "击败了 95.27% 的玩家！你的表现堪称完美！"

	if next_level != null:
		_next_label.text = "关卡 %d" % next_level.id
	else:
		_next_label.text = "全部通关"
	_next_button.visible = true
	_home_button.visible = true

	visible = true
	move_to_front()


func hide_result() -> void:
	visible = false
	_next_level = null


func _on_next_pressed() -> void:
	if _next_level != null:
		next_level_pressed.emit(_next_level)
	else:
		home_pressed.emit()
