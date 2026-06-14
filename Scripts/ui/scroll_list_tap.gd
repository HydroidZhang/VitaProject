class_name ScrollListTap
extends RefCounted

## 列表内点击与滑动分离（对标 Android RecyclerView touch slop / iOS delaysContentTouches）。
## 手势在 ScrollContainer 统一判定，子项 mouse_filter=IGNORE，不抢滚动。

const TOUCH_SLOP_PX := 10.0
const TAP_SLOP_PX := 22.0
const SCROLL_SLOP_PX := 4


static func bind(scroll: ScrollContainer, on_tap_at: Callable) -> void:
	if scroll.has_meta(&"scroll_list_tap_bound"):
		return
	scroll.set_meta(&"scroll_list_tap_bound", true)

	var state := {
		"down": false,
		"start": Vector2.ZERO,
		"scroll_start": 0,
		"cancelled": false,
	}

	scroll.gui_input.connect(func(event: InputEvent) -> void:
		_handle_input(scroll, state, on_tap_at, event)
	)


static func _handle_input(
	scroll: ScrollContainer,
	state: Dictionary,
	on_tap_at: Callable,
	event: InputEvent,
) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(scroll, state, on_tap_at, event as InputEventScreenTouch)
		return

	if event is InputEventScreenDrag:
		_handle_drag(scroll, state, event as InputEventScreenDrag)
		return

	if PointerInput.prefers_touch_events():
		return

	if event is InputEventMouseButton:
		_handle_mouse(scroll, state, on_tap_at, event as InputEventMouseButton)
		return

	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if state["down"] and motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_mark_cancel_if_moved(scroll, state, motion.position)


static func _handle_touch(
	scroll: ScrollContainer,
	state: Dictionary,
	on_tap_at: Callable,
	touch: InputEventScreenTouch,
) -> void:
	if touch.pressed:
		_begin_pointer(scroll, state, touch.position)
		return
	if state["down"]:
		_end_pointer(scroll, state, on_tap_at, touch.position)


static func _handle_mouse(
	scroll: ScrollContainer,
	state: Dictionary,
	on_tap_at: Callable,
	mouse: InputEventMouseButton,
) -> void:
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	if mouse.pressed:
		_begin_pointer(scroll, state, mouse.position)
		return
	if state["down"]:
		_end_pointer(scroll, state, on_tap_at, mouse.position)


static func _handle_drag(
	scroll: ScrollContainer,
	state: Dictionary,
	drag: InputEventScreenDrag,
) -> void:
	if not state["down"]:
		return
	_mark_cancel_if_moved(scroll, state, drag.position)


static func _begin_pointer(scroll: ScrollContainer, state: Dictionary, pos: Vector2) -> void:
	state["down"] = true
	state["cancelled"] = false
	state["start"] = pos
	state["scroll_start"] = scroll.scroll_vertical


static func _end_pointer(
	scroll: ScrollContainer,
	state: Dictionary,
	on_tap_at: Callable,
	pos: Vector2,
) -> void:
	state["down"] = false
	if state["cancelled"] or not _qualifies_as_tap(scroll, state, pos):
		return
	var global_pos := scroll.get_global_transform_with_canvas() * pos
	on_tap_at.call(global_pos)


static func _mark_cancel_if_moved(
	scroll: ScrollContainer,
	state: Dictionary,
	pos: Vector2,
) -> void:
	if state["start"].distance_to(pos) >= TOUCH_SLOP_PX:
		state["cancelled"] = true
	if absi(scroll.scroll_vertical - int(state["scroll_start"])) >= SCROLL_SLOP_PX:
		state["cancelled"] = true


static func _qualifies_as_tap(scroll: ScrollContainer, state: Dictionary, pos: Vector2) -> bool:
	if state["start"].distance_to(pos) > TAP_SLOP_PX:
		return false
	if absi(scroll.scroll_vertical - int(state["scroll_start"])) > SCROLL_SLOP_PX:
		return false
	return true
