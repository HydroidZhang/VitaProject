## Why

P0–P3 已完成单布局 demo 的完整玩法，但玩家每次只能重复同一关卡。P4 引入多关卡、选关界面与进度解锁，让游戏具备基本的关卡推进体验。

## What Changes

- 新增 `LevelData` 与 `LevelRegistry`，从 `Data/Levels/levels.json` 加载关卡列表
- 新增第二个布局 `demo_16.json`（16 格宽塔）
- 新增 `ProgressManager`，本地存档解锁进度（`user://progress.json`）
- 新增 `LevelSelect` 选关场景/UI
- 重构主流程：选关 → 游戏 → 通关解锁下一关 → 返回选关
- `Board` 通关后通知上层解锁并显示返回选关

## Capabilities

### New Capabilities

- `level-progression`: 关卡配置、选关 UI、通关解锁与进度存档

### Modified Capabilities

- `board-generation`: 支持从 `LevelData` 启动关卡（layout + tile_pool）
- `tile-gameplay`: 通关后触发关卡完成流程（非仅显示文字）

## Impact

- **新增**: `Data/Levels/levels.json`、`Data/Layouts/demo_16.json`、`Scripts/Data/level_data.gd`、`level_registry.gd`、`Scripts/Game/progress_manager.gd`、`Scenes/LevelSelect.tscn`、`Scripts/level_select.gd`
- **修改**: `Main.tscn`、`main.gd`、`board.gd`、`project.godot`（主场景）
- **废弃**: `demo_level.gd` 硬编码入口（改为 levels.json 驱动）
