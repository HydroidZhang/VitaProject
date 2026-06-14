class_name MahjongTile
extends Area2D

@onready var _shadow: ColorRect = $Shadow
@onready var _side_bottom: ColorRect = $SideBottom
@onready var _side_right: ColorRect = $SideRight
@onready var _face: ColorRect = $Face
@onready var _face_sprite: Sprite2D = $FaceSprite
@onready var _face_highlight: ColorRect = $FaceHighlight
@onready var _label: Label = $Label
@onready var _selection_frame: Node2D = $SelectionFrame
@onready var _selection_sparkles: CPUParticles2D = $SelectionFrame/SelectionSparkles
@onready var _hint_frame: Node2D = $HintFrame
@onready var _left_block: ColorRect = $BlockMarks/LeftMark
@onready var _right_block: ColorRect = $BlockMarks/RightMark
@onready var _cover_block: ColorRect = $BlockMarks/CoverMark

var tile_type: TileType = null
var cell: CellData = null
var layer: int = 0
var is_free: bool = true

var _selected: bool = false
var _match_hint: bool = false
var _base_color: Color = Color.WHITE
var _base_z_index: int = 0
var _eliminating: bool = false
var _block_info: Dictionary = {}


func _ready() -> void:
	input_pickable = false
	_disable_control_input_passthrough()
	_face.visible = false
	if tile_type != null:
		_apply_visual()


func can_receive_pointer() -> bool:
	return not _eliminating


func set_base_z_index(value: int) -> void:
	_base_z_index = value


func setup(tile_id: String, tile_layer: int = 0, cell_data: CellData = null) -> void:
	cell = cell_data
	layer = tile_layer
	tile_type = TileRegistry.get_tile(tile_id)
	if is_node_ready():
		_apply_visual()
	else:
		call_deferred("_apply_visual")


func set_selected(selected: bool) -> void:
	if _eliminating:
		return

	var was_selected := _selected
	_selected = selected
	z_index = _base_z_index + (100 if _selected else 0)
	_apply_visual()
	if selected and not was_selected:
		_play_select_bounce()
	elif not selected:
		scale = Vector2.ONE


func set_match_hint(hint: bool) -> void:
	_match_hint = hint
	_apply_visual()


func set_free(free: bool, block_info: Dictionary = {}) -> void:
	is_free = free
	_block_info = block_info
	_apply_visual()


func begin_pair_elimination(top_z: int) -> void:
	_eliminating = true
	_selected = false
	_match_hint = false
	input_pickable = false
	z_index = top_z
	scale = Vector2.ONE
	_selection_frame.visible = false
	_hint_frame.visible = false
	_selection_sparkles.emitting = false


func _play_select_bounce() -> void:
	scale = Vector2.ONE
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.14, 1.14), 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _disable_control_input_passthrough() -> void:
	for child in get_children():
		_set_ignore_mouse_recursive(child)


func _set_ignore_mouse_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_ignore_mouse_recursive(child)


func _apply_visual() -> void:
	if not is_node_ready():
		return

	_selection_frame.visible = _selected and is_free
	_hint_frame.visible = _match_hint and is_free and not _selected
	_selection_sparkles.emitting = _selected and is_free
	if not _eliminating:
		scale = Vector2(1.08, 1.08) if _selected else Vector2.ONE

	if tile_type == null:
		_label.text = ""
		_label.visible = false
		_face_sprite.texture = TileTextureAtlas.get_face_texture(null)
		_face_sprite.scale = TileTextureAtlas.get_sprite_scale(_face_sprite.texture)
		_set_procedural_parts_visible(true)
		_side_right.color = Color(0.25, 0.25, 0.25)
		_side_bottom.color = Color(0.2, 0.2, 0.2)
		_shadow.color = Color(0, 0, 0, 0.2)
		_face_highlight.color = Color(1, 1, 1, 0.15)
		modulate = Color(0.65, 0.65, 0.65, 1)
		return

	var uses_file_texture := TileTextureAtlas.uses_file_texture(tile_type)
	_label.visible = not uses_file_texture
	_label.text = "" if uses_file_texture else tile_type.display_name
	_base_color = TileType.get_category_color(tile_type.category)
	_face_sprite.texture = TileTextureAtlas.get_face_texture(tile_type)
	_face_sprite.scale = TileTextureAtlas.get_sprite_scale(_face_sprite.texture)
	_face_sprite.position = Vector2.ZERO if uses_file_texture else Vector2(-3.5, -4.0)
	_set_procedural_parts_visible(not uses_file_texture)

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

	_face_sprite.modulate = Color.WHITE if is_free else Color(0.78, 0.78, 0.78)
	_apply_face_highlight(uses_file_texture, face_color)
	if _selected and is_free:
		_side_right.color = Color(0.98, 0.84, 0.16, 1)
		_side_bottom.color = Color(0.9, 0.74, 0.1, 1)
		_shadow.color = Color(0.82, 0.62, 0.04, 0.38)
	elif uses_file_texture:
		_shadow.color = Color(0, 0, 0, clampf(0.32 - layer * 0.06, 0.12, 0.32))
	else:
		_side_right.color = face_color.darkened(0.25)
		_side_bottom.color = face_color.darkened(0.38)
		_shadow.color = Color(0, 0, 0, clampf(0.38 - layer * 0.08, 0.14, 0.38))
	modulate = Color.WHITE if is_free else Color(0.72, 0.72, 0.72, 1)
	_update_block_marks()


func _apply_face_highlight(uses_file_texture: bool, face_color: Color) -> void:
	if _selected and is_free:
		_set_face_highlight_rect(-34.0, -49.0, 27.0, 43.0)
		_face_highlight.color = Color(1, 0.94, 0.32, 0.18)
		return

	if _match_hint and is_free:
		_set_face_highlight_rect(-34.0, -49.0, 27.0, 43.0)
		_face_highlight.color = Color(0.52, 1, 0.64, 0.16)
		return

	if uses_file_texture:
		_set_face_highlight_rect(-34.0, -49.0, 27.0, -44.0)
		_face_highlight.color = Color(1, 1, 1, 0.08)
	else:
		_set_face_highlight_rect(-34.0, -49.0, 27.0, -44.0)
		_face_highlight.color = Color(1, 1, 1, 0.22 + layer * 0.06)


func _set_face_highlight_rect(left: float, top: float, right: float, bottom: float) -> void:
	_face_highlight.offset_left = left
	_face_highlight.offset_top = top
	_face_highlight.offset_right = right
	_face_highlight.offset_bottom = bottom


func _set_procedural_parts_visible(parts_visible: bool) -> void:
	_face.visible = false
	_side_right.visible = parts_visible
	_side_bottom.visible = parts_visible


func _update_block_marks() -> void:
	_left_block.visible = false
	_right_block.visible = false
	_cover_block.visible = false


func get_block_message() -> String:
	if bool(_block_info.get("covered", false)):
		return "该麻将被盖住"
	var left_blocked := bool(_block_info.get("left_blocked", false))
	var right_blocked := bool(_block_info.get("right_blocked", false))
	if left_blocked and right_blocked:
		return "两边被锁住"
	if left_blocked:
		return "左侧被锁住"
	if right_blocked:
		return "右侧被锁住"
	return "无法选择"
