## 1. 共用规则

- [x] 1.1 抽取 `BoardRules` 与 `TileSlot`
- [x] 1.2 `FreeTileChecker` 改为调用 `BoardRules`

## 2. 分配与求解

- [x] 2.1 创建 `TileAssigner`（assign / assign_solvable）
- [x] 2.2 创建 `BoardSolver` DFS 可解性验证

## 3. 集成

- [x] 3.1 `demo_level.gd` 提供 `TILE_POOL` 与 `EMPTY_TILE_IDS`
- [x] 3.2 `board.gd` 支持自动分配与 R 键重开
- [x] 3.3 `main.gd` 传入空 tile_ids 触发随机分配

## 4. 验证

- [x] 4.1 每次开局牌型不同
- [x] 4.2 按 R 可重新洗牌并完成通关
