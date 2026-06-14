# Design: 对局手感打磨

## 连击

- `ComboTracker` 记录 `current_combo` / `max_combo`
- 以 `_elapsed_sec` 为时间轴：距上次消除 ≤ `COMBO_WINDOW_SEC`（3s）则连击 +1，否则重置为 1
- 加分：`bonus = (combo - 1) * COMBO_BONUS_PER_LEVEL`（60），与基础 `MATCH_SCORE` 一并计入总分
- 提示：仅 `combo >= 2` 时 `GameHUD.ComboTip` 在屏幕右侧播放一次动画（不与分数飘字重复）
- 结算：`level_cleared` 携带 `max_combo`，`ResultOverlay`「最高连击」与分级文案

## 选中与配对提示

| 状态 | 视觉 |
|------|------|
| 选中 | 7px 金黄外框、`SelectionFaceOverlay` 半透明黄、外圈光晕、`SelectionSparkles`、侧棱金色、scale 1.08 + 回弹 |
| 可配对提示 | `HintGlow` 薄荷绿铺满牌面、4px 绿框（细于选中框） |

## 碰撞碎裂

1. 两牌 `MERGE_DURATION` 加速撞向中心
2. 碰撞回调：`MatchCollisionEffect.spawn(tile_layer, collision_pos, …)`
3. 效果节点必须挂在 **`TileLayer`**（牌 `position` 为层本地坐标；层有 `BoardLayoutScaler` 偏移与缩放）
4. 碎裂：冲击闪光（`Polygon2D`）、飞散碎屑、象牙碎屑粒子 + 金色火花粒子
5. 牌体：短暂压扁后沿碰撞法向弹开、旋转淡出；`TileLayer` 轻微抖动

## 设置控件

- 音乐：`Button` `toggle_mode`，绿/灰大按钮（约 220×72）
- 音量：`ProgressBar` 橙色填充 + 透明轨道 `HSlider` 叠在同一 `VolumeTrack` 内
