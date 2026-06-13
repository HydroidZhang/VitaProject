extends Control

signal play_pressed(level: LevelData)
signal level_select_pressed
signal settings_pressed

@onready var _play_button: Button = $Center/Panel/PlayButton
@onready var _level_select_button: Button = $Center/Panel/LevelSelectButton
@onready var _settings_button: Button = %SettingsButton

var _progress: ProgressManager = ProgressManager.load()


func _ready() -> void:
	_refresh_play_button()
	_play_button.pressed.connect(_on_play_pressed)
	_level_select_button.pressed.connect(func(): level_select_pressed.emit())
	_settings_button.pressed.connect(func(): settings_pressed.emit())


func refresh() -> void:
	_progress = ProgressManager.load()
	_refresh_play_button()


func _refresh_play_button() -> void:
	var level := _get_continue_level()
	if level == null:
		_play_button.text = "暂无关卡"
		_play_button.disabled = true
		return
	_play_button.disabled = false
	_play_button.text = "关卡 %d" % level.id


func _get_continue_level() -> LevelData:
	var levels := LevelRegistry.load_all()
	if levels.is_empty():
		return null
	var best: LevelData = null
	for level in levels:
		if _progress.is_unlocked(level.id):
			best = level
	return best if best != null else levels[0]


func _on_play_pressed() -> void:
	var level := _get_continue_level()
	if level != null:
		play_pressed.emit(level)
