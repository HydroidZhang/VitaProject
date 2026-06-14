# Vita 麻将 — 项目总结

## 项目概览

Godot 4.6 竖屏麻将消除游戏，设计分辨率 **720×1080**，目标平台 Android。

---

## 目录结构

| 路径 | 说明 |
|------|------|
| `Assets/Mahjong/` | 牌面贴图 |
| `Assets/UI/` | 主页 / 对局 / 结算 UI |
| `Assets/Audio/` | BGM（`game_start` / `game_running` / `game_win`） |
| `Scenes/` | 场景（Home、GameHUD、Board、Settings 等） |
| `Scripts/` | 游戏逻辑、UI、音频、生成 |
| `Data/Levels/` | 关卡 JSON |
| `docs/` | 文档 |

---

## 核心系统

### 对局

- 程序化生成关卡：`RuntimeLevelBuilder` + `LayoutGenerator`
- 5×7 底层槽位，`BoardLayoutScaler` 按屏幕自动放大牌桌
- 触摸选牌：`PointerInput` + `GameHUD` 对局区判定
- 消除动画：`MatchElimination`，+320 飘字在碰撞点上方

### 音频

| 曲目 | 时机 |
|------|------|
| `game_running.mp3` | 主界面 / 选关循环 |
| `game_start.mp3` | 进关一次，播完接 running |
| `game_win.mp3` | 通关结算 |

- `BgmManager` — 播放控制
- `GameSettings` — 音乐开关、音量（`user://vita_settings.json`）
- `SfxManager` — 代码生成短音效（点击、消除等）

### 道具次数

- 1～10 关：洗牌 / 提示各 **2** 次
- 11 关起：各 **3** 次  
- 配置：`Scripts/Game/gameplay_constants.gd`

### 热更

- `HotUpdateManager` + `Assets/Audio` 等可打 PCK  
- 配置：`Scripts/Update/hot_update_config.gd`

### UI 交互

- `ButtonPressScale` — 按钮按下缩放（需 `has_meta` 再读 tween，避免报错）

---

## 显示适配

- `project.godot`：`stretch/aspect = keep_width`（超长屏铺满宽度）
- `ScreenAdapter`：安全区 / 视口尺寸

---

## 本次修复（报错 & 警告）

### 错误

- **`button_press_scale.gd`**：`get_meta("press_scale_tween")` 在 meta 不存在时抛错 → 改为先 `has_meta()` 再读取。

### 警告

- `board_controller.gd`：局部变量 `show_hint` 与函数同名 → 改为 `should_show_hint`
- `tile_type.gd`：参数 `category` 遮蔽成员 → 改为 `tile_category`
- `mahjong.gd`：参数 `visible` 遮蔽 `CanvasItem.visible` → 改为 `parts_visible`
- `level_select.gd`：未使用信号 `back_pressed` → 删除
- `result_overlay.gd`：未使用参数 `level_id` → 改为 `_level_id`
- `board_builder.gd`：未使用变量 `area` → 移除
- `grid_slots.gd`：整数除法 → 使用 `//`

---

## 常用配置入口

| 需求 | 文件 |
|------|------|
| 道具次数 | `gameplay_constants.gd` |
| BGM 路径 / 音量基准 | `bgm_config.gd` |
| 音乐开关默认值 | `game_settings.gd` |
| 牌大小 / 棋盘填充比例 | `tile_constants.gd`、`board_layout_scaler.gd` |
| 导出 Android | `export_presets.cfg` |

---

## Autoload

```
GameSettings → SfxManager → ScreenAdapter → HotUpdateManager → BgmManager
```
