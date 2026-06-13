## 1. 规则引擎

- [x] 1.1 创建 `TileSlot`、`BoardRules` 遮挡与挡边判定
- [x] 1.2 创建 `FreeTileChecker` 包装 MahjongTile 接口
- [x] 1.3 创建 `BoardState` 活跃牌管理

## 2. 交互控制

- [x] 2.1 创建 `BoardController` 选中/配对/消除逻辑
- [x] 2.2 集成到 `Board.tscn` 与 `board.gd`

## 3. 牌面交互

- [x] 3.1 `Mahjong.tscn` 添加 CollisionShape2D
- [x] 3.2 修复 Control mouse_filter 拦截点击
- [x] 3.3 选中金框、配对绿框、锁定变暗视觉

## 4. 可解性修复

- [x] 4.1 修正 demo 关卡牌型分配（外层配对）
- [x] 4.2 牌实例写入 `cell` 数据

## 5. 验证

- [x] 5.1 可选牌可点击选中
- [x] 5.2 同牌型配对消除，全部消完通关
