class_name ScorePopEffect
extends RefCounted

const FLOAT_DISTANCE := 42.0
const LABEL_SIZE := Vector2(140.0, 56.0)
const LabelScene := preload("res://Scenes/ScorePopLabel.tscn")


static func spawn_on_control(parent: Control, local_pos: Vector2, amount: int) -> void:
	var label := LabelScene.instantiate() as Label
	label.text = "+%d" % amount
	label.position = local_pos - LABEL_SIZE * 0.5
	label.pivot_offset = LABEL_SIZE * 0.5
	label.modulate = Color(1, 1, 1, 0)
	label.scale = Vector2(0.55, 0.55)
	parent.add_child(label)

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.12, 1.12), 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().set_parallel(true)
	tween.tween_property(label, "modulate:a", 0.0, 0.42)\
		.set_delay(0.08).set_ease(Tween.EASE_IN)
	tween.tween_property(label, "position:y", label.position.y - FLOAT_DISTANCE, 0.5)\
		.set_delay(0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.28, 1.28), 0.5)\
		.set_delay(0.08).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(label.queue_free)
