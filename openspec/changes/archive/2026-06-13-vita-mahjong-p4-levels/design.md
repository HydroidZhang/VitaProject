## Context

当前仅 `demo_12` 单布局 + `DemoLevel.TILE_POOL`。P3 已支持随机可解分配。

## Goals / Non-Goals

**Goals:**
- 3 个关卡，难度递增（布局更大 / 牌池更广）
- 选关界面，未解锁关卡不可进入
- 通关解锁下一关，进度持久化
- 游戏中可返回选关

**Non-Goals:**
- 星级评分
- 云端存档
- 关卡编辑器

## Decisions

### 1. 关卡配置 JSON

`Data/Levels/levels.json` 数组，每项含 `id`、`name`、`layout_path`、`tile_pool`、`difficulty`。

### 2. 进度存档

`user://vita_progress.json`，字段 `highest_unlocked`（int）。首关默认解锁。

### 3. 场景流程

`Main.tscn` 为根，包含 `LevelSelect` 与 `Board` 两个子场景实例；选关后隐藏选关、显示 Board；通关或按 Esc 返回选关。

### 4. 布局

| 关卡 | 布局 | 格数 |
|------|------|------|
| 1 初识金字塔 | demo_12.json | 12 |
| 2 宽塔 | demo_16.json | 16 |
| 3 大师挑战 | demo_12.json | 12（更大牌池）|

### 5. demo_level.gd

保留 `EMPTY_TILE_IDS`、`TILE_POOL` 常量供兼容，关卡数据迁移到 `levels.json`。

## Risks / Trade-offs

- [Risk] 16 格求解更慢 → BoardSolver 节点上限已 50000，可接受
- [Risk] 宽布局超出屏幕 → BoardBuilder 居中算法自动适配
