class_name PointerInput
extends RefCounted

const DEDUPE_MS := 120
const DEDUPE_DISTANCE_PX := 20.0

static var _last_press_ms: int = -1000
static var _last_press_pos: Vector2 = Vector2(-99999.0, -99999.0)
static var _last_touch_ms: int = -1000
static var _last_touch_pos: Vector2 = Vector2(-99999.0, -99999.0)


static func prefers_touch_events() -> bool:
	return DisplayServer.is_touchscreen_available()


static func event_viewport_position(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).position
	return Vector2.ZERO


static func is_primary_press(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		return touch_event.pressed and touch_event.index == 0
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	return false


static func consume_primary_press(event: InputEvent) -> bool:
	if not is_primary_press(event):
		return false

	var viewport_pos := event_viewport_position(event)
	var now_ms := Time.get_ticks_msec()

	if event is InputEventScreenTouch:
		_last_touch_ms = now_ms
		_last_touch_pos = viewport_pos
	elif (
		event is InputEventMouseButton
		and prefers_touch_events()
		and now_ms - _last_touch_ms < DEDUPE_MS
		and viewport_pos.distance_to(_last_touch_pos) < DEDUPE_DISTANCE_PX
	):
		return false

	if (
		now_ms - _last_press_ms < DEDUPE_MS
		and viewport_pos.distance_to(_last_press_pos) < DEDUPE_DISTANCE_PX
	):
		return false

	_last_press_ms = now_ms
	_last_press_pos = viewport_pos
	return true


static func viewport_to_canvas(viewport_pos: Vector2) -> Vector2:
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return (tree as SceneTree).root.get_viewport().get_canvas_transform().affine_inverse() * viewport_pos
	return viewport_pos
