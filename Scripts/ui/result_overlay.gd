extends Control

signal next_level_pressed(level: LevelData)
signal home_pressed

@onready var _title_label: Label = $Center/Panel/TitleLabel
@onready var _time_label: Label = $Center/Panel/StatsRow/TimeBox/VBox/ValueLabel
@onready var _score_label: Label = $Center/Panel/StatsRow/ScoreBox/VBox/ValueLabel
@onready var _combo_label: Label = $Center/Panel/StatsRow/ComboBox/VBox/ValueLabel
@onready var _feedback_label: Label = $Center/Panel/FeedbackLabel
@onready var _next_button: Button = $Center/Panel/NextButton
@onready var _home_button: Button = $Center/Panel/HomeButton

var _next_level: LevelData = null


func _ready() -> void:
	_next_button.pressed.connect(_on_next_pressed)
	_home_button.pressed.connect(func(): home_pressed.emit())
	visible = false


func show_result(
	level_id: int,
	elapsed_sec: float,
	score: int,
	matches: int,
	next_level: LevelData,
) -> void:
	_next_level = next_level
	var minutes := int(elapsed_sec) / 60
	var seconds := int(elapsed_sec) % 60
	_time_label.text = "%02d:%02d" % [minutes, seconds]
	_score_label.text = str(score)
	_combo_label.text = str(maxi(matches, 1))
	_feedback_label.text = "击败了 95.27% 的玩家！你的表现堪称完美！"

	if next_level != null:
		_next_button.text = "关卡 %d" % next_level.id
		_next_button.visible = true
	else:
		_next_button.text = "全部通关"
		_next_button.visible = true

	visible = true


func hide_result() -> void:
	visible = false
	_next_level = null


func _on_next_pressed() -> void:
	if _next_level != null:
		next_level_pressed.emit(_next_level)
	else:
		home_pressed.emit()
