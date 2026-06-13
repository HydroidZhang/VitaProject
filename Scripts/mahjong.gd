class_name MahjongTile
extends Area2D

signal pressed

@onready var _shadow: ColorRect = $Shadow
@onready var _side_bottom: ColorRect = $SideBottom
@onready var _side_right: ColorRect = $SideRight
@onready var _face: ColorRect = $Face
@onready var _face_highlight: ColorRect = $FaceHighlight
@onready var _label: Label = $Label
@onready var _selection_frame: Node2D = $SelectionFrame
@onready var _hint_frame: Node2D = $HintFrame

var tile_type: TileType = null
var cell: CellData = null
var layer: int = 0
var is_free: bool = true

var _selected: bool = false
var _match_hint: bool = false
var _base_color: Color = Color.WHITE
var _base_z_index: int = 0


func _ready() -> void:
	input_event.connect(_on_input_event)
	_disable_control_input_passthrough()


func set_base_z_index(value: int) -> void:
	_base_z_index = value


func setup(tile_id: String, tile_layer: int = 0, cell_data: CellData = null) -> void:
	cell = cell_data
	layer = tile_layer
	tile_type = TileRegistry.get_tile(tile_id)
	_apply_visual()


func set_selected(selected: bool) -> void:
	_selected = selected
	z_index = _base_z_index + (100 if _selected else 0)
	_apply_visual()


func set_match_hint(hint: bool) -> void:
	_match_hint = hint
	_apply_visual()


func set_free(free: bool) -> void:
	is_free = free
	_apply_visual()


func _disable_control_input_passthrough() -> void:
	for child in get_children():
		_set_ignore_mouse_recursive(child)


func _set_ignore_mouse_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_ignore_mouse_recursive(child)


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int,
) -> void:
	if not is_free:
		return
	if _is_press_event(event):
		pressed.emit()
		get_viewport().set_input_as_handled()


func _is_press_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		return touch_event.pressed and touch_event.index == 0
	return false


func _apply_visual() -> void:
	_selection_frame.visible = _selected and is_free
	_hint_frame.visible = _match_hint and is_free and not _selected
	scale = Vector2(1.07, 1.07) if _selected else Vector2.ONE

	if tile_type == null:
		_label.text = ""
		_face.color = Color(0.35, 0.35, 0.35)
		_side_right.color = Color(0.25, 0.25, 0.25)
		_side_bottom.color = Color(0.2, 0.2, 0.2)
		_shadow.color = Color(0, 0, 0, 0.2)
		_face_highlight.color = Color(1, 1, 1, 0.15)
		modulate = Color(0.65, 0.65, 0.65, 1)
		return

	_label.text = tile_type.display_name
	_base_color = TileType.get_category_color(tile_type.category)

	var face_color := _base_color
	if _selected:
		face_color = _base_color.lightened(0.28)
	elif not is_free:
		face_color = _base_color.darkened(0.18)
	else:
		match layer:
			0:
				face_color = _base_color.darkened(0.12)
			1:
				face_color = _base_color
			_:
				face_color = _base_color.lightened(0.1)

	_face.color = face_color
	_side_right.color = face_color.darkened(0.25)
	_side_bottom.color = face_color.darkened(0.38)
	_face_highlight.color = Color(1, 1, 1, 0.35 if _selected else 0.22 + layer * 0.06)
	_shadow.color = Color(0, 0, 0, clampf(0.38 - layer * 0.08, 0.14, 0.38))
	modulate = Color.WHITE if is_free else Color(0.72, 0.72, 0.72, 1)
