extends Control

signal back_pressed
signal shuffle_pressed
signal hint_pressed
signal menu_pressed

@onready var _level_label: Label = $TopBar/Margin/HBox/LevelLabel
@onready var _score_label: Label = $TopBar/Margin/HBox/ScoreLabel
@onready var _match_label: Label = $TopBar/Margin/HBox/MatchLabel
@onready var _back_button: Button = %BackButton
@onready var _shuffle_button: Button = %ShuffleButton
@onready var _hint_button: Button = %HintButton
@onready var _menu_button: Button = %MenuButton

var score: int = 0
var matches: int = 0


func _ready() -> void:
	_back_button.pressed.connect(func(): back_pressed.emit())
	_shuffle_button.pressed.connect(func(): shuffle_pressed.emit())
	_hint_button.pressed.connect(func(): hint_pressed.emit())
	_menu_button.pressed.connect(func(): menu_pressed.emit())


func reset_stats() -> void:
	score = 0
	matches = 0
	_update_labels()


func start_level(level: LevelData) -> void:
	_level_label.text = "关卡 %d" % level.id
	reset_stats()


func sync_stats(new_score: int, new_matches: int) -> void:
	score = new_score
	matches = new_matches
	_update_labels()


func _update_labels() -> void:
	_score_label.text = "分数 %d" % score
	_match_label.text = "匹配 %d" % matches
