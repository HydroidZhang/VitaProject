## Why

P2 使用手工固定的牌型分配，每局内容相同且需人工保证可解。P3 引入随机洗牌与可解性验证，让每次开局牌型不同且保证能通关。

## What Changes

- 新增 `TileAssigner`：按布局格数生成配对列表并 shuffle
- 新增 `BoardSolver`：DFS 验证牌局可解
- `BoardRules` 抽为共用规则模块（实机 + 求解器）
- `start_level` 支持空 tile_ids 时自动生成可解分配
- 按 **R** 重新洗牌开局

## Capabilities

### New Capabilities

- `tile-assignment`: 随机牌型分配与可解性验证

### Modified Capabilities

- `board-generation`: `start_level` 支持自动生成 tile_ids
- `tile-gameplay`: 每局牌型随机，按 R 重开

## Impact

- **新增**: `tile_assigner.gd`、`board_solver.gd`、`tile_slot.gd`、`board_rules.gd`
- **修改**: `demo_level.gd`、`board.gd`、`main.gd`、`free_tile_checker.gd`
