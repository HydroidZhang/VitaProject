## Context

demo_12 布局固定 12 格（6 对），牌型从 `TILE_POOL`（12 种）中随机抽取配对。

## Goals / Non-Goals

**Goals:**
- 每次开局随机分配 6 对牌型
- 分配结果经 DFS 求解器验证可解
- 最多重试 200 次，失败则降级为未验证分配
- R 键重新洗牌

**Non-Goals:**
- 多布局关卡（P4）
- 难度分级
- 存档进度

## Decisions

### 1. 分配与布局分离

`TileAssigner.assign(cells, pool)` 只负责生成 `tile_ids` 数组，顺序与 cells 一一对应后 shuffle。

### 2. 求解器

`BoardSolver.is_solvable(cells, tile_ids)` 用 DFS 枚举自由牌配对消除，12 格规模下性能可接受。上限 50000 节点防死循环。

### 3. 类型安全

空数组参数使用 `DemoLevel.EMPTY_TILE_IDS: Array[String]` 避免 GDScript 无类型 `[]` 报错。

## Risks / Trade-offs

- [Risk] 200 次重试仍无解 → push_warning 并返回未验证分配
- [Trade-off] DFS 不保证找到最短解，只验证存在解
