# Proposal: 对局手感打磨（连击 / 选中 / 碰撞碎裂 / 设置控件）

## Why

笔试交付前需补齐参考 Vita 的体验细节：连击反馈与结算、选中/配对提示辨识度、消除碰撞碎裂感，以及移动端设置页控件可点性。

## What Changes

- **连击**：3 秒内连续消除计连击，右侧飘字提示，连击加分，结算展示最高连击
- **选中视觉**：加粗金黄边框、牌面蒙层、粒子闪烁、金色立体边；可配对牌薄荷绿蒙层 + 细绿框
- **碰撞碎裂**：两牌撞合后压扁弹开、碎屑与粒子（坐标挂在 `TileLayer`）、牌桌微震
- **设置弹窗**：大号音乐开关、橙色音量进度条与滑块叠层

## 范围

- `Scripts/Game/combo_tracker.gd`、`Scripts/board.gd`
- `Scripts/mahjong.gd`、`Scenes/Mahjong.tscn`
- `Scripts/Visual/match_elimination.gd`、`Scripts/Visual/match_collision_effect.gd`
- `Scripts/ui/game_hud.gd`、`Scenes/GameHUD.tscn`
- `Scripts/ui/result_overlay.gd`、`Scenes/SettingsOverlay.tscn`

## 非目标

- 不改关卡生成与配对规则
- 不替换牌面 PNG 图集
