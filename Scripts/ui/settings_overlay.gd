extends Control

signal closed

@onready var _music_toggle: CheckButton = %MusicToggle
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
@onready var _close_button: Button = %CloseButton
@onready var _dim: ColorRect = $Dim

var _syncing_ui: bool = false


func _ready() -> void:
	visible = false
	_close_button.pressed.connect(_on_close_pressed)
	_music_toggle.toggled.connect(_on_music_toggled)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_dim.gui_input.connect(_on_dim_input)
	ButtonPressScale.bind(_close_button)
	_sync_from_settings()


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
	_volume_slider.value = GameSettings.music_volume * 100.0
	_volume_slider.editable = GameSettings.music_enabled
	_update_volume_label(_volume_slider.value)
	_syncing_ui = false


func _on_music_toggled(enabled: bool) -> void:
	if _syncing_ui:
		return
	GameSettings.set_music_enabled(enabled)
	_volume_slider.editable = enabled


func _on_volume_changed(value: float) -> void:
	if _syncing_ui:
		return
	_update_volume_label(value)
	GameSettings.set_music_volume(value / 100.0)


func _update_volume_label(value: float) -> void:
	_volume_value.text = "%d%%" % int(round(value))


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
