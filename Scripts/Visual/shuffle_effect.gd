class_name ShuffleEffect
extends RefCounted

const COLLECT_DURATION := 0.34
const HOLD_DURATION := 0.1
const DEAL_DURATION := 0.38
const DEAL_STAGGER := 0.018
const PILE_CENTER := Vector2.ZERO
const PILE_SCALE := Vector2(0.32, 0.32)


static func collect(layer: Node2D, tiles: Array[MahjongTile]) -> void:
	if tiles.is_empty():
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for tile in tiles:
		tile.set_selected(false)
		tile.set_match_hint(false)
		tile.rotation = 0.0

	var tween := layer.create_tween()
	tween.set_parallel(true)
	for tile in tiles:
		var spin := rng.randf_range(-0.45, 0.45)
		tween.tween_property(tile, "position", PILE_CENTER, COLLECT_DURATION)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(tile, "scale", PILE_SCALE, COLLECT_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(tile, "rotation", spin, COLLECT_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(tile, "modulate:a", 0.55, COLLECT_DURATION)

	await tween.finished
	await layer.get_tree().create_timer(HOLD_DURATION).timeout


static func deal(layer: Node2D, tiles: Array[MahjongTile]) -> void:
	if tiles.is_empty():
		return

	var ordered := tiles.duplicate()
	ordered.sort_custom(func(a: MahjongTile, b: MahjongTile) -> bool:
		if a.layer != b.layer:
			return a.layer < b.layer
		if a.position.y != b.position.y:
			return a.position.y < b.position.y
		return a.position.x < b.position.x
	)

	for tile in ordered:
		var target: Vector2 = tile.get_meta("shuffle_target_pos", PILE_CENTER)
		tile.position = PILE_CENTER
		tile.scale = PILE_SCALE
		tile.rotation = 0.0
		tile.modulate = Color(1, 1, 1, 0.0)
		tile.set_meta("shuffle_target_pos", target)

	var tween := layer.create_tween()
	tween.set_parallel(true)
	for index in ordered.size():
		var tile: MahjongTile = ordered[index]
		var target: Vector2 = tile.get_meta("shuffle_target_pos", PILE_CENTER)
		var delay := float(index) * DEAL_STAGGER
		tween.tween_property(tile, "position", target, DEAL_DURATION)\
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(tile, "scale", Vector2.ONE, DEAL_DURATION)\
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(tile, "modulate:a", 1.0, DEAL_DURATION * 0.7)\
			.set_delay(delay)
		tween.tween_property(tile, "rotation", 0.0, DEAL_DURATION * 0.6)\
			.set_delay(delay)

	await tween.finished

	for tile in ordered:
		tile.modulate = Color.WHITE
		tile.scale = Vector2.ONE
		tile.rotation = 0.0
		if tile.has_meta("shuffle_target_pos"):
			tile.remove_meta("shuffle_target_pos")
