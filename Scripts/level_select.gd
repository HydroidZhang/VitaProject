extends Control

signal level_selected(level: LevelData)

const LevelButtonScene := preload("res://Scenes/LevelButton.tscn")

@onready var _level_list: VBoxContainer = $Margin/Panel/LevelScroll/LevelList
@onready var _hint_label: Label = $Margin/Panel/HintLabel
@onready var _level_scroll: ScrollContainer = $Margin/Panel/LevelScroll

var _progress: ProgressManager = ProgressManager.load()
var _levels: Array[LevelData] = []


func _ready() -> void:
	_configure_scroll()
	_levels = LevelRegistry.load_all()
	_build_level_buttons()
	ScrollListTap.bind(_level_scroll, _on_list_tap_at)


func _configure_scroll() -> void:
	_level_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_level_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO


func refresh() -> void:
	_progress = ProgressManager.load()
	_build_level_buttons()
	_level_scroll.scroll_vertical = 0


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


func _on_list_tap_at(global_pos: Vector2) -> void:
	for child in _level_list.get_children():
		if not child is Control:
			continue
		var row := child as Control
		if not row.get_global_rect().has_point(global_pos):
			continue
		if row.has_method("trigger_tap"):
			row.trigger_tap()
		return


func _on_level_row_pressed(level: LevelData, unlocked: bool) -> void:
	if unlocked:
		level_selected.emit(level)
