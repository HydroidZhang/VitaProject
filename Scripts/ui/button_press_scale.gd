class_name ButtonPressScale
extends RefCounted

const PRESS_SCALE := 0.9
const ANIM_DURATION := 0.07
const META_BOUND := &"press_scale_bound"
const META_TWEEN := &"press_scale_tween"


static func bind(target: Control) -> void:
	if target == null or (target.has_meta(META_BOUND) and target.get_meta(META_BOUND)):
		return
	target.set_meta(META_BOUND, true)
	_refresh_pivot(target)
	target.resized.connect(func() -> void:
		_refresh_pivot(target)
	)

	if target is BaseButton:
		_bind_base_button(target as BaseButton)
	else:
		_bind_generic_control(target)


static func bind_many(targets: Array) -> void:
	for node in targets:
		if node is Control:
			bind(node as Control)


static func press_down(target: Control) -> void:
	_animate_to(target, PRESS_SCALE)


static func press_up(target: Control) -> void:
	_animate_to(target, 1.0)


static func _bind_base_button(button: BaseButton) -> void:
	button.button_down.connect(func() -> void:
		if not button.disabled:
			press_down(button)
	)
	button.button_up.connect(func() -> void:
		press_up(button)
	)
	button.mouse_exited.connect(func() -> void:
		if button.scale != Vector2.ONE:
			press_up(button)
	)


static func _bind_generic_control(target: Control) -> void:
	target.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			var touch_event := event as InputEventScreenTouch
			if touch_event.pressed:
				press_down(target)
			else:
				press_up(target)
			return

		if event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			if mouse_event.button_index != MOUSE_BUTTON_LEFT:
				return
			if mouse_event.pressed:
				press_down(target)
			else:
				press_up(target)
	)


static func _refresh_pivot(target: Control) -> void:
	target.pivot_offset = target.size * 0.5


static func _animate_to(target: Control, scale_value: float) -> void:
	if target.has_meta(META_TWEEN):
		var existing: Variant = target.get_meta(META_TWEEN)
		if existing is Tween and is_instance_valid(existing):
			(existing as Tween).kill()

	var tween := target.create_tween()
	target.set_meta(META_TWEEN, tween)
	tween.tween_property(
		target,
		"scale",
		Vector2.ONE * scale_value,
		ANIM_DURATION,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
