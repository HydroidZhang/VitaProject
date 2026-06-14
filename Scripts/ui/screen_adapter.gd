extends Node

## 屏幕自适应：设计分辨率 720×1080，运行时按实际视口与安全区适配。

signal insets_changed(left: float, top: float, right: float, bottom: float)
signal viewport_resized(size: Vector2)

const DESIGN_SIZE := Vector2(720.0, 1080.0)

var safe_left: float = 0.0
var safe_top: float = 0.0
var safe_right: float = 0.0
var safe_bottom: float = 0.0


func _ready() -> void:
	var root := get_tree().root
	if not root.size_changed.is_connected(_on_root_resized):
		root.size_changed.connect(_on_root_resized)
	_refresh()


func get_viewport_size() -> Vector2:
	var visible := get_viewport().get_visible_rect().size
	if visible.x < 1.0 or visible.y < 1.0:
		return DESIGN_SIZE
	return visible


func get_layout_size() -> Vector2:
	## 运行时视口（keep_width 下高度随屏幕拉长，无上下黑边）
	return get_viewport_size()


func get_design_size() -> Vector2:
	return DESIGN_SIZE


func get_insets() -> Vector4:
	return Vector4(safe_left, safe_top, safe_right, safe_bottom)


func _on_root_resized() -> void:
	_refresh()


func _refresh() -> void:
	_update_safe_insets()
	var size := get_viewport_size()
	insets_changed.emit(safe_left, safe_top, safe_right, safe_bottom)
	viewport_resized.emit(size)


func _update_safe_insets() -> void:
	var viewport := get_viewport()
	var video_size := viewport.get_visible_rect().size
	var screen_size := Vector2i(DisplayServer.screen_get_size())

	if screen_size.x <= 0 or screen_size.y <= 0:
		safe_left = 0.0
		safe_top = 0.0
		safe_right = 0.0
		safe_bottom = 0.0
		return

	var safe := DisplayServer.get_display_safe_area()
	var scale_x := video_size.x / float(screen_size.x)
	var scale_y := video_size.y / float(screen_size.y)

	safe_left = float(safe.position.x) * scale_x
	safe_top = float(safe.position.y) * scale_y
	safe_right = float(screen_size.x - safe.end.x) * scale_x
	safe_bottom = float(screen_size.y - safe.end.y) * scale_y
