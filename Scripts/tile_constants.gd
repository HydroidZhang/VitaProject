class_name TileConstants
extends RefCounted

const DISPLAY_SCALE := 1.10
const BASE_TILE_SIZE := Vector2(73.0, 102.0)
const TILE_SIZE := BASE_TILE_SIZE * DISPLAY_SCALE
const HALF_SIZE := TILE_SIZE * 0.5
const TILE_THICKNESS := 8.0
## 垂直逻辑格 = 半张牌高；行间 2 格 = 整张牌高，层间 1 格 = 半张错位
const GRID_Y_STEP := TILE_SIZE.y / 2.0
const GRID_ROW_SPACING := 2
const LAYER_Y_OFFSET := 1
const LAYER_OFFSET := Vector2(-4.0, -10.0)
