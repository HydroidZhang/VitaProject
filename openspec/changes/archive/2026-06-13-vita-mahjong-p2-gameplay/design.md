## Context

P1 生成 12 张 3 层金字塔牌盘。玩法遵循 Shanghai 麻将规则。

## Goals / Non-Goals

**Goals:**
- 点击可选牌选中，再点同牌型消除
- 不可选牌变暗且无法点击
- 选中金色边框，可配对牌绿色提示
- 全部消除后显示通关

**Non-Goals:**
- 随机洗牌（P3）
- 多关卡（P4）
- 动画特效

## Decisions

### 1. 规则逻辑与节点分离

`BoardRules` 基于 `TileSlot`（cell + tile_id）做纯逻辑判定，`FreeTileChecker` 包装为 `MahjongTile` 接口，供实机和求解器共用。

### 2. 点击检测

`Area2D` + `CollisionShape2D`，所有 `ColorRect`/`Label` 设 `mouse_filter = IGNORE` 防止拦截。

### 3. 网格遮挡判定

牌占网格宽 2、高 3。上层 `layer` 更大且网格区域重叠则视为遮挡。同层左右邻居间隔 `x ± 2` 为挡边。

### 4. Demo 关卡牌型分配

外层配对（x=1 与 x=7 同牌型），避免相邻同牌型导致只能选一张无法消对。

## Risks / Trade-offs

- [Risk] 固定分配不当导致死锁 → P3 引入可解性验证
- [Risk] Control 吃事件 → mouse_filter IGNORE + input_pickable
