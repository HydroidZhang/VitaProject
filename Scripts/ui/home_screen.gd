extends Control

signal play_pressed(level: LevelData)
signal level_select_pressed
signal settings_pressed

@onready var _play_button: TextureButton = %PlayButton
@onready var _play_label: Label = $PlayButton/TitleLabel
@onready var _level_select_button: Button = $LevelSelectButton
@onready var _settings_button: TextureButton = %SettingsButton
@onready var _profile_button: TextureButton = %ProfileButton

var _progress: ProgressManager = ProgressManager.load()


func _ready() -> void:
	_refresh_play_button()
	ButtonPressScale.bind_many([
		_play_button,
		_level_select_button,
		_settings_button,
		_profile_button,
	])
	_play_button.pressed.connect(_on_play_pressed)
	_level_select_button.pressed.connect(func(): level_select_pressed.emit())
	_settings_button.pressed.connect(func(): settings_pressed.emit())
	_profile_button.pressed.connect(func(): level_select_pressed.emit())


func refresh() -> void:
	_progress = ProgressManager.load()
	_refresh_play_button()


func _refresh_play_button() -> void:
	var level := _get_continue_level()
	if level == null:
		_play_label.text = "暂无关卡"
		_play_button.disabled = true
		_play_button.modulate = Color(0.55, 0.55, 0.55, 1)
		return
	_play_button.disabled = false
	_play_button.modulate = Color.WHITE
	_play_label.text = "关卡 %d" % level.id


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
