class_name ScreenTransition
extends RefCounted

enum Kind {
	FADE,
	SCALE_IN,
	SLIDE_UP,
	SLIDE_DOWN,
}

const SHOW_DURATION := 0.3
const HIDE_DURATION := 0.22
const GENTLE_SHOW_DURATION := 0.42
const GENTLE_HIDE_DURATION := 0.34
const CROSSFADE_OVERLAP := 0.08


static func crossfade(hide_items: Array, show_items: Array) -> void:
	if show_items.is_empty() and hide_items.is_empty():
		return

	var tree: SceneTree = null
	for item in show_items:
		var node: CanvasItem = item[0]
		if node != null:
			_set_visible(node)
			tree = node.get_tree()
	if tree == null:
		for item in hide_items:
			var node: CanvasItem = item[0]
			if node != null and node.visible:
				tree = node.get_tree()
				break
	if tree == null:
		return

	await tree.process_frame

	for item in show_items:
		var node: CanvasItem = item[0]
		if node == null:
			continue
		_prepare_pivot_sync(node, item[1])
		_apply_show_from(node, item[1])

	for item in hide_items:
		var node: CanvasItem = item[0]
		if node == null or not node.visible:
			continue
		_prepare_pivot_sync(node, item[1])

	await tree.create_timer(CROSSFADE_OVERLAP).timeout

	for item in hide_items:
		var node: CanvasItem = item[0]
		if node == null or not node.visible:
			continue
		_start_hide_tween(node, item[1], GENTLE_HIDE_DURATION)

	for item in show_items:
		var node: CanvasItem = item[0]
		if node == null:
			continue
		_start_show_tween(node, item[1], GENTLE_SHOW_DURATION)

	await tree.create_timer(maxi(GENTLE_SHOW_DURATION, GENTLE_HIDE_DURATION)).timeout

	for item in hide_items:
		var node: CanvasItem = item[0]
		if node == null:
			continue
		node.visible = false
		_reset_node(node)

	for item in show_items:
		var node: CanvasItem = item[0]
		if node != null:
			_reset_node(node)


static func show_in(node: CanvasItem, kind: Kind = Kind.FADE, duration: float = SHOW_DURATION) -> void:
	if node == null:
		return
	_set_visible(node)
	await node.get_tree().process_frame
	_prepare_pivot_sync(node, kind)
	_apply_show_from(node, kind)
	var tween := _start_show_tween(node, kind, duration)
	if tween != null:
		await tween.finished
	_reset_node(node)


static func hide_out(node: CanvasItem, kind: Kind = Kind.FADE, duration: float = HIDE_DURATION) -> void:
	if node == null or not node.visible:
		return
	_prepare_pivot_sync(node, kind)
	var tween := _start_hide_tween(node, kind, duration)
	if tween != null:
		await tween.finished
	node.visible = false
	_reset_node(node)


static func show_group(items: Array, duration: float = SHOW_DURATION) -> void:
	if items.is_empty():
		return
	var tree: SceneTree = null
	for item in items:
		var node: CanvasItem = item[0]
		if node == null:
			continue
		_set_visible(node)
		tree = node.get_tree()
	if tree == null:
		return
	await tree.process_frame
	for item in items:
		var node: CanvasItem = item[0]
		if node == null:
			continue
		_prepare_pivot_sync(node, item[1])
		_apply_show_from(node, item[1])
		_start_show_tween(node, item[1], duration)
	await tree.create_timer(duration).timeout
	for item in items:
		var node: CanvasItem = item[0]
		if node != null:
			_reset_node(node)


static func hide_group(items: Array, duration: float = HIDE_DURATION) -> void:
	if items.is_empty():
		return
	var tree: SceneTree = null
	for item in items:
		var node: CanvasItem = item[0]
		if node == null or not node.visible:
			continue
		_prepare_pivot_sync(node, item[1])
		_start_hide_tween(node, item[1], duration)
		tree = node.get_tree()
	if tree == null:
		return
	await tree.create_timer(duration).timeout
	for item in items:
		var node: CanvasItem = item[0]
		if node != null:
			node.visible = false
			_reset_node(node)


static func _set_visible(node: CanvasItem) -> void:
	if node is Control:
		(node as Control).show()
	else:
		node.visible = true


static func _start_show_tween(
	node: CanvasItem,
	kind: Kind,
	duration: float = SHOW_DURATION,
) -> Tween:
	var tween := node.create_tween()
	tween.set_parallel(true)
	match kind:
		Kind.FADE:
			tween.tween_property(node, "modulate:a", 1.0, duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		Kind.SCALE_IN:
			tween.tween_property(node, "modulate:a", 1.0, duration)
			tween.tween_property(node, "scale", Vector2.ONE, duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		Kind.SLIDE_UP, Kind.SLIDE_DOWN:
			tween.tween_property(node, "modulate:a", 1.0, duration)
			tween.tween_property(node, "scale", Vector2.ONE, duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func _start_hide_tween(
	node: CanvasItem,
	kind: Kind,
	duration: float = HIDE_DURATION,
) -> Tween:
	var tween := node.create_tween()
	tween.set_parallel(true)
	match kind:
		Kind.FADE:
			tween.tween_property(node, "modulate:a", 0.0, duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		Kind.SCALE_IN:
			tween.tween_property(node, "modulate:a", 0.0, duration)
			tween.tween_property(node, "scale", Vector2(0.96, 0.96), duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		Kind.SLIDE_UP:
			tween.tween_property(node, "modulate:a", 0.0, duration)
			tween.tween_property(node, "scale", Vector2(1.0, 0.96), duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		Kind.SLIDE_DOWN:
			tween.tween_property(node, "modulate:a", 0.0, duration)
			tween.tween_property(node, "scale", Vector2(1.0, 0.96), duration)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func _apply_show_from(node: CanvasItem, kind: Kind) -> void:
	match kind:
		Kind.FADE:
			node.modulate = Color(1, 1, 1, 0)
			node.scale = Vector2.ONE
		Kind.SCALE_IN:
			node.modulate = Color(1, 1, 1, 0)
			node.scale = Vector2(0.86, 0.86)
		Kind.SLIDE_UP, Kind.SLIDE_DOWN:
			node.modulate = Color(1, 1, 1, 0)
			node.scale = Vector2(1.0, 0.97)


static func _prepare_pivot_sync(node: CanvasItem, kind: Kind) -> void:
	if not node is Control:
		return
	var control := node as Control
	if kind == Kind.FADE:
		control.pivot_offset = Vector2.ZERO
		return
	control.pivot_offset = _pivot_for(control, kind)


static func _pivot_for(control: Control, kind: Kind) -> Vector2:
	var size := control.size
	if size.x < 1.0 or size.y < 1.0:
		size = UIConstants.viewport_size()
	match kind:
		Kind.SLIDE_UP, Kind.SLIDE_DOWN:
			return Vector2(size.x * 0.5, size.y)
		_:
			return size * 0.5


static func _reset_node(node: CanvasItem) -> void:
	node.modulate = Color.WHITE
	node.scale = Vector2.ONE
	if node is Control:
		(node as Control).pivot_offset = Vector2.ZERO
