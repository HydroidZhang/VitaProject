## Why

P1 已能生成完整牌盘，但无法交互。P2 需要实现 Vita Mahjong 核心玩法：点击选牌、判断可选牌、配对消除，让游戏可玩。

## What Changes

- 新增 `FreeTileChecker` / `BoardRules`：上方无遮挡 + 左右至少一侧空闲
- 新增 `BoardController`：选中、配对、消除、通关判定
- 新增 `BoardState` 牌盘状态管理
- `MahjongTile` 增加点击检测（CollisionShape2D）、可选/选中/配对提示视觉
- 修复 Control 子节点拦截点击、demo 关卡牌型分配导致的死锁

## Capabilities

### New Capabilities

- `tile-gameplay`: 可选牌判定、点击选中、同牌型配对消除

### Modified Capabilities

- `tile-display`: 增加选中边框、配对绿色提示、可选/锁定明暗区分
- `board-generation`: 牌实例携带 `cell` 数据供规则判定

## Impact

- **新增**: `Scripts/Game/`（board_controller, board_state, free_tile_checker, board_rules, tile_slot）
- **修改**: `mahjong.gd`、`board.gd`、`Scenes/Mahjong.tscn`、`Scenes/Board.tscn`
