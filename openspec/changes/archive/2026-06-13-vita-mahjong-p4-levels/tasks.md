## 1. 关卡数据

- [x] 1.1 创建 `LevelData`、`LevelRegistry`
- [x] 1.2 创建 `Data/Levels/levels.json`（3 关配置）
- [x] 1.3 创建 `Data/Layouts/demo_16.json`（16 格宽塔布局）

## 2. 进度存档

- [x] 2.1 创建 `ProgressManager`（读写 `user://vita_progress.json`）
- [x] 2.2 实现通关解锁下一关逻辑

## 3. 选关 UI

- [x] 3.1 创建 `LevelSelect.tscn` + `level_select.gd`
- [x] 3.2 显示关卡名、难度、锁定状态

## 4. 主流程集成

- [x] 4.1 重构 `Main.tscn` / `main.gd`：选关 ↔ 游戏切换
- [x] 4.2 `board.gd` 支持 `level_cleared` 信号携带 level_id，Esc 返回选关
- [x] 4.3 通关后显示「下一关」/「返回选关」

## 5. 验证

- [x] 5.1 首关可玩，二三关锁定
- [x] 5.2 通关解锁下一关，重启游戏进度保留
- [x] 5.3 三关布局与难度可区分
