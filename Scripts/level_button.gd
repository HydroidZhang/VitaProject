extends Control

signal pressed

@onready var _id_label: Label = $Margin/HBox/IdLabel
@onready var _name_label: Label = $Margin/HBox/NameLabel
@onready var _stars_label: Label = $Margin/HBox/StarsLabel
@onready var _lock_label: Label = $Margin/HBox/LockLabel

var _unlocked: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(level_id: int, level_name: String, difficulty: int, unlocked: bool) -> void:
	_unlocked = unlocked
	_id_label.text = "第 %d 关" % level_id
	_name_label.text = level_name
	_stars_label.text = "★".repeat(difficulty)
	_lock_label.text = "" if unlocked else "🔒"
	modulate = Color(1, 1, 1, 1) if unlocked else Color(0.6, 0.6, 0.62, 1)


func trigger_tap() -> void:
	if not _unlocked:
		return
	ButtonPressScale.press_down(self)
	var tween := create_tween()
	tween.tween_interval(0.07)
	tween.tween_callback(func() -> void:
		ButtonPressScale.press_up(self)
		pressed.emit()
	)
