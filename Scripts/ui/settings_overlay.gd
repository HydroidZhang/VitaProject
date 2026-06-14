extends Control

signal closed

@onready var _music_toggle: Button = %MusicToggle
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_bar: ProgressBar = %VolumeBar
@onready var _volume_value: Label = %VolumeValue
@onready var _close_button: Button = %CloseButton
@onready var _dim: ColorRect = $Dim

var _style_music_on: StyleBoxFlat
var _style_music_off: StyleBoxFlat
var _syncing_ui: bool = false


func _ready() -> void:
	visible = false
	_cache_music_styles()
	_close_button.pressed.connect(_on_close_pressed)
	_music_toggle.toggled.connect(_on_music_toggled)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_dim.gui_input.connect(_on_dim_input)
	ButtonPressScale.bind_many([_close_button, _music_toggle])
	_sync_from_settings()


func _cache_music_styles() -> void:
	_style_music_on = _music_toggle.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	_style_music_off = _style_music_on.duplicate() as StyleBoxFlat
	_style_music_off.bg_color = Color(0.38, 0.34, 0.32, 1.0)


func open() -> void:
	_sync_from_settings()
	visible = true
	move_to_front()


func close() -> void:
	visible = false
	closed.emit()


func _sync_from_settings() -> void:
	_syncing_ui = true
	_music_toggle.button_pressed = GameSettings.music_enabled
	_apply_music_toggle_visual(GameSettings.music_enabled)
	_volume_slider.value = GameSettings.music_volume * 100.0
	_volume_slider.editable = GameSettings.music_enabled
	_update_volume_display(_volume_slider.value)
	_syncing_ui = false


func _on_music_toggled(enabled: bool) -> void:
	if _syncing_ui:
		return
	_apply_music_toggle_visual(enabled)
	GameSettings.set_music_enabled(enabled)
	_volume_slider.editable = enabled


func _on_volume_changed(value: float) -> void:
	if _syncing_ui:
		return
	_update_volume_display(value)
	GameSettings.set_music_volume(value / 100.0)


func _apply_music_toggle_visual(enabled: bool) -> void:
	var style := _style_music_on if enabled else _style_music_off
	_music_toggle.text = "开启" if enabled else "关闭"
	for state in ["normal", "hover", "pressed", "focus"]:
		_music_toggle.add_theme_stylebox_override(state, style)


func _update_volume_display(value: float) -> void:
	var rounded := int(round(value))
	_volume_value.text = "%d%%" % rounded
	_volume_bar.value = float(rounded)


func _on_close_pressed() -> void:
	close()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			close()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			close()
