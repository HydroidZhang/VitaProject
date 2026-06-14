# UI 资源说明

## 原始资源路径

设计稿与切图源文件位于：

```
C:\Users\cp168\Downloads\Assets
```

项目内资源放在 `res://Assets/` 下。

---

## 目录结构

| 路径 | 说明 | 状态 |
|------|------|------|
| `Assets/Mahjong/` | 麻将牌面贴图（34 张） | 已接入 |
| `Assets/UI/Home/` | 主页背景、Logo、按钮 | 已接入 |
| `Assets/UI/Game/` | 游戏背景、顶栏、工具按钮 | 已接入 |
| `Assets/UI/Result/` | 结算光效、边框、下一关按钮 | 已接入 |

---

## 代码入口

| 文件 | 作用 |
|------|------|
| `Scenes/HomeScreen.tscn` | 主页布局与贴图（可在编辑器直接调整） |
| `Scenes/LevelSelect.tscn` | 选关界面 |
| `Scenes/LevelButton.tscn` | 关卡行样式 |
| `Scenes/GameHUD.tscn` | 游戏 HUD |
| `Scenes/ResultOverlay.tscn` | 结算界面 |
| `Scenes/PlayBackground.tscn` | 游戏背景 |
| `Scripts/ui/ui_constants.gd` | 布局尺寸常量（顶栏 88px、底栏 140px） |
| `Scripts/ui/home_screen.gd` | 主页逻辑（仅动态文本与信号） |
| `Scripts/ui/game_hud.gd` | HUD 逻辑（仅动态数值与信号） |
| `Scripts/ui/result_overlay.gd` | 结算逻辑（仅动态数值与信号） |
| `Scripts/level_select.gd` | 选关列表生成 |
| `Scripts/level_button.gd` | 关卡行点击逻辑 |
| `Scripts/main.gd` | 场景切换 |

> **调整 UI**：在 Godot 编辑器中打开对应 `.tscn`，直接拖动节点、改 offset/anchor、替换 Texture 即可。贴图与 StyleBox 均已写在场景里，不再运行时拼装。

---

## 屏幕自适应（Android）

设计分辨率 **720×1080**，通过 `project.godot` 配置：

| 设置 | 值 | 说明 |
|------|-----|------|
| `stretch/mode` | `canvas_items` | 2D UI 与牌桌随视口缩放 |
| `stretch/aspect` | `expand` | 全面屏竖屏扩展高度，无黑边 |
| `handheld/orientation` | `1` | 锁定竖屏 |

运行时由 Autoload `ScreenAdapter` 提供：

- `get_viewport_size()` — 当前逻辑视口尺寸
- `get_insets()` — 刘海/状态栏/导航栏安全区（Vector4: left, top, right, bottom）

各 UI 脚本实现 `apply_screen_adaptation(insets)`，`main.gd` 在启动与尺寸变化时自动调用。牌桌区域按实际视口高度重新居中布局。

**编辑器预览长屏**：`project.godot` 中 `window_height_override=1600` 可模拟 20:9 机型。

---

## 布局规范（对照标准图）

| 界面 | 要点 |
|------|------|
| 主页 | 左上头像、资源条、右上设置；Logo 居中偏上；门环居中；橙色开始按钮靠下 |
| 选关 | 同主页背景；Logo +「已解锁 X / Y 关」；橙色关卡行可滚动 |
| 游戏 | 顶栏三列竖排（关卡/分数/匹配）；底部洗牌/提示圆形按钮间距 120px |
| 结算 | 莲花光效 + 祥云框；标题「才华横溢」；深色统计卡片；绿色下一关按钮 |

---

## 麻将贴图

见 `Scripts/Visual/tile_texture_atlas.gd` 中 `TEXTURE_MAP`。

- 单张尺寸：210 × 310 px
- 游戏内缩放至：73 × 102 px

---

## UI 切图映射

### 主页 `Assets/UI/Home/`

| 文件 | 源文件 | 用途 |
|------|--------|------|
| bg.png | Image_1_Part_1 | 主页/选关背景 |
| logo_clean.png | Image_8 1 | Logo（透明底） |
| door_icon.png | Image_1_Part_2 | 门环装饰 |
| btn_play.png | Image_1_Part_3 | 开始/关卡行按钮底图 |
| profile.png | Image_1_Part_4 | 头像按钮 |
| resource_bar.png | x0 | 资源条（叶子 x0） |
| btn_settings.png | Image_1_Part_8 | 设置按钮 |
| leaf_1.png | Image_1_Part_7 | 落叶装饰 |
| leaf_2.png | Image_1_Part_9 | 落叶装饰 |
| leaf_3.png | Image_1_Part_12 | 落叶装饰 |

### 游戏 `Assets/UI/Game/`

| 文件 | 源文件 | 用途 |
|------|--------|------|
| bg.png | Image_12_Part_1 | 牌桌绿色背景（含木质底栏） |
| top_bar.png | Image_10_Part_4 | 顶栏条（备用） |
| btn_back.png | Image_12_Part_9 | 返回 |
| btn_menu.png | Image_12_Part_8 | 菜单 |
| btn_shuffle.png | Image_12_Part_5 | 洗牌 |
| btn_hint.png | Image_12_Part_6 | 提示 |

### 结算 `Assets/UI/Result/`

| 文件 | 源文件 | 用途 |
|------|--------|------|
| glow_top.png | Image_10_Part_1 | 顶部光晕 |
| frame.png | Image_10_Part_2 | 祥云边框 |
| btn_next.png | Image_10_Part_3 | 下一关按钮 |

---

## 同步资源

```powershell
# 麻将贴图
Copy-Item "C:\Users\cp168\Downloads\Assets\Mahjong\*.png" "e:\GotDotProject\vita\Assets\Mahjong\" -Force

# 主页 UI
Copy-Item "C:\Users\cp168\Downloads\Assets\Image_1_Part_1.png" "e:\GotDotProject\vita\Assets\UI\Home\bg.png" -Force
Copy-Item "C:\Users\cp168\Downloads\Assets\Image_8 1.png" "e:\GotDotProject\vita\Assets\UI\Home\logo_clean.png" -Force
Copy-Item "C:\Users\cp168\Downloads\Assets\x0.png" "e:\GotDotProject\vita\Assets\UI\Home\resource_bar.png" -Force
```

复制后重新打开 Godot 以生成 `.import` 文件。
