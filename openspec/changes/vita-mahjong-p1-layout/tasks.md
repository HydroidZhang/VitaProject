## 1. 数据模型与工具类

- [x] 1.1 创建 `Scripts/Generation/cell_data.gd`，定义 `x`、`y`、`layer` 字段
- [x] 1.2 创建 `Scripts/Generation/grid_converter.gd`，实现 `grid_to_world()` 与 `compute_z_index()`
- [x] 1.3 创建 `Scripts/Generation/layout_loader.gd`，从 JSON 加载并校验布局（字段完整性、cells 非空）

## 2. 布局数据

- [x] 2.1 创建 `Data/Layouts/demo_12.json`，包含 12 格 3 层金字塔布局
- [x] 2.2 在关卡数据中定义 12 个固定 `tile_id`（6 对配对牌型）

## 3. 棋盘生成

- [x] 3.1 创建 `Scripts/Generation/board_builder.gd`，校验 cells 与 tile_ids 数量一致
- [x] 3.2 实现 `build(board_node, layout_path, tile_ids)`：实例化 Mahjong、调用 `setup()`、设置 position 与 z_index
- [x] 3.3 创建 `Scenes/Board.tscn`（Node2D 根节点）

## 4. 主场景集成

- [x] 4.1 修改 `Scripts/main.gd`：实例化 Board，调用 BoardBuilder 加载 demo_12 关卡
- [x] 4.2 调整 Board 居中偏移，确保 12 张牌在 720×1080 视口内完整可见

## 5. 验证

- [x] 5.1 运行 Main 场景，确认显示 12 张多层牌（非原 6 张横排演示）
- [x] 5.2 确认上层牌视觉上压住下层牌，各牌文字与花色颜色正确
