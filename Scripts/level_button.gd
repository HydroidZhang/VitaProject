extends PanelContainer

signal pressed

@onready var _id_label: Label = $Margin/HBox/IdLabel
@onready var _name_label: Label = $Margin/HBox/NameLabel
@onready var _stars_label: Label = $Margin/HBox/StarsLabel
@onready var _lock_label: Label = $Margin/HBox/LockLabel

var _unlocked: bool = true


func setup(level_id: int, level_name: String, difficulty: int, unlocked: bool) -> void:
	_unlocked = unlocked
	_id_label.text = "第 %d 关" % level_id
	_name_label.text = level_name
	_stars_label.text = "★".repeat(difficulty)
	_lock_label.text = "" if unlocked else "🔒"
	modulate = Color(1, 1, 1, 1) if unlocked else Color(0.55, 0.55, 0.58, 1)


func _gui_input(event: InputEvent) -> void:
	if not _unlocked:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			pressed.emit()
			accept_event()
