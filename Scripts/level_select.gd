extends Control

signal level_selected(level: LevelData)
signal back_pressed

const LevelButtonScene := preload("res://Scenes/LevelButton.tscn")

@onready var _title_label: Label = $Center/Panel/TitleLabel
@onready var _level_list: VBoxContainer = $Center/Panel/LevelList
@onready var _hint_label: Label = $Center/Panel/HintLabel

var _progress: ProgressManager = ProgressManager.load()
var _levels: Array[LevelData] = []


func _ready() -> void:
	_levels = LevelRegistry.load_all()
	_build_level_buttons()


func refresh() -> void:
	_progress = ProgressManager.load()
	_build_level_buttons()


func _build_level_buttons() -> void:
	for child in _level_list.get_children():
		child.queue_free()

	if _levels.is_empty():
		_hint_label.text = "未找到关卡配置"
		return

	_hint_label.text = "已解锁 %d / %d 关" % [_progress.highest_unlocked, _levels.size()]

	for level in _levels:
		var row = LevelButtonScene.instantiate()
		_level_list.add_child(row)
		var unlocked := _progress.is_unlocked(level.id)
		row.setup(level.id, level.name, level.difficulty, unlocked)
		row.pressed.connect(_on_level_row_pressed.bind(level, unlocked))


func _on_level_row_pressed(level: LevelData, unlocked: bool) -> void:
	if unlocked:
		level_selected.emit(level)
