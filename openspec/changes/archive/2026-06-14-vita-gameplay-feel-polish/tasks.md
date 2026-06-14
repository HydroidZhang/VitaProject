## 1. 连击

- [x] 1.1 新增 `ComboTracker` 与 `GameplayConstants` 连击窗口/加分常量
- [x] 1.2 `board.gd` 计分与 `level_cleared` 传递 `max_combo`
- [x] 1.3 `GameHUD` 右侧 `ComboTip` 连击飘字（仅 combo ≥ 2）
- [x] 1.4 `ResultOverlay` 最高连击与分级反馈文案

## 2. 选中与提示

- [x] 2.1 `Mahjong.tscn` 加粗选中框、牌面蒙层、选中粒子
- [x] 2.2 `mahjong.gd` 选中金色侧棱、绿提示牌面蒙层
- [x] 2.3 配对提示细绿框 + 薄荷绿铺满蒙层

## 3. 碰撞碎裂

- [x] 3.1 新增 `MatchCollisionEffect`（闪光、碎屑、粒子）
- [x] 3.2 `MatchElimination` 压扁弹开碎裂动画与牌层抖动
- [x] 3.3 效果挂到 `TileLayer` 修正坐标系

## 4. 设置弹窗

- [x] 4.1 大号音乐开关按钮
- [x] 4.2 橙色音量条 + 叠层滑块

## 5. 文档

- [x] 5.1 更新 `tile-visuals`、`tile-gameplay`、`game-ui` spec
- [x] 5.2 更新 `docs/笔试总结.md`
