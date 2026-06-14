class_name MatchCollisionEffect
extends RefCounted

const EFFECT_LIFETIME := 0.6
const CHIP_COUNT := 10
const SHARD_PARTICLE_AMOUNT := 22
const SPARK_PARTICLE_AMOUNT := 16


static func spawn(
	effect_parent: Node2D,
	collision_pos: Vector2,
	first: MahjongTile,
	second: MahjongTile,
	z_index: int = 0,
) -> void:
	var root := Node2D.new()
	root.name = "CollisionEffect"
	root.position = collision_pos
	root.z_index = z_index
	effect_parent.add_child(root)

	var accent := _pick_accent_color(first, second)
	_spawn_chip_shards(root, accent)
	_spawn_shard_particles(root, accent)
	_spawn_spark_particles(root)

	effect_parent.get_tree().create_timer(EFFECT_LIFETIME).timeout.connect(root.queue_free)


static func _pick_accent_color(first: MahjongTile, second: MahjongTile) -> Color:
	if first.tile_type != null:
		return TileType.get_category_color(first.tile_type.category)
	if second.tile_type != null:
		return TileType.get_category_color(second.tile_type.category)
	return Color(0.92, 0.86, 0.72)


static func _spawn_chip_shards(parent: Node2D, accent: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for _chip_index in CHIP_COUNT:
		var chip := Polygon2D.new()
		var chip_w := rng.randf_range(7.0, 16.0)
		var chip_h := rng.randf_range(5.0, 12.0)
		chip.polygon = PackedVector2Array([
			Vector2(-chip_w * 0.5, -chip_h * 0.5),
			Vector2(chip_w * 0.5, -chip_h * 0.5),
			Vector2(chip_w * 0.5, chip_h * 0.5),
			Vector2(-chip_w * 0.5, chip_h * 0.5),
		])
		chip.position = Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-14.0, 10.0))
		chip.color = Color(0.88, 0.72, 0.38, 0.9).lerp(accent, rng.randf_range(0.2, 0.5))
		chip.rotation = rng.randf_range(-0.8, 0.8)
		parent.add_child(chip)

		var angle := rng.randf() * TAU
		var distance := rng.randf_range(34.0, 78.0)
		var target := chip.position + Vector2(cos(angle), sin(angle)) * distance + Vector2(0, 22.0)
		var duration := rng.randf_range(0.2, 0.36)

		var tween := chip.create_tween()
		tween.set_parallel(true)
		tween.tween_property(chip, "position", target, duration)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(chip, "rotation", chip.rotation + rng.randf_range(-2.4, 2.4), duration)
		tween.tween_property(chip, "scale", Vector2(rng.randf_range(0.35, 0.7), rng.randf_range(0.35, 0.7)), duration)
		tween.tween_property(chip, "modulate:a", 0.0, duration * 0.75).set_delay(duration * 0.2)


static func _spawn_shard_particles(parent: Node2D, accent: Color) -> void:
	var particles := CPUParticles2D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = SHARD_PARTICLE_AMOUNT
	particles.lifetime = 0.42
	particles.explosiveness = 0.92
	particles.randomness = 0.55
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(16, 22)
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 280)
	particles.initial_velocity_min = 70.0
	particles.initial_velocity_max = 180.0
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.2
	particles.color = Color(0.95, 0.82, 0.45, 0.75).lerp(accent, 0.35)
	parent.add_child(particles)


static func _spawn_spark_particles(parent: Node2D) -> void:
	var particles := CPUParticles2D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = SPARK_PARTICLE_AMOUNT
	particles.lifetime = 0.34
	particles.explosiveness = 1.0
	particles.randomness = 0.65
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 120)
	particles.initial_velocity_min = 90.0
	particles.initial_velocity_max = 220.0
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 1.8
	particles.color = Color(1, 0.82, 0.22, 0.85)
	parent.add_child(particles)
