class_name UIConstants
extends RefCounted

## 与 GameHUD.tscn 中 PlayTouchArea 对齐：顶栏高度 + 牌桌顶部留白
const TOP_BAR_H := 130.0
const PLAY_AREA_TOP_EXTRA := 48.0
const BOTTOM_BAR_H := 132.0
const GAME_HUD_Z_INDEX := 3500
const SCORE_POP_ABOVE_TILE_PX := 18.0


static func viewport_size() -> Vector2:
	return ScreenAdapter.get_viewport_size()


static func play_area(viewport_size: Vector2) -> Rect2:
	var top := TOP_BAR_H + PLAY_AREA_TOP_EXTRA
	return Rect2(0.0, top, viewport_size.x, viewport_size.y - top - BOTTOM_BAR_H)
