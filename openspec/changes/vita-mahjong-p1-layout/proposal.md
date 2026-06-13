## Why

P0 已完成单张麻将牌的可配置白模（`setup()` 显示不同牌型），但主场景仍只能手动摆放演示牌，无法构成一盘可玩的牌局。P1 需要引入布局模板与棋盘生成能力，让游戏能从数据驱动地生成一整盘麻将，为后续配对消除（P2）和多关卡（P4）打下基础。

## What Changes

- 新增 JSON 布局模板格式，描述每张牌在逻辑网格中的位置与层数
- 新增逻辑坐标系统（半格偏移 + 层叠 z_index），将网格坐标转换为世界像素坐标
- 新增 `BoardBuilder`，读取布局模板并实例化 `Mahjong.tscn` 填满牌桌
- 新增固定牌型分配（手工指定或简单配对列表），保证 P1 可解且无需随机洗牌
- 新增 `Board.tscn` 容器场景，替代 `main.gd` 中的横向演示排列
- 提供第一个可运行关卡：小布局 JSON + 对应牌型列表，运行后显示完整牌盘

## Capabilities

### New Capabilities

- `layout-template`: 布局模板的 JSON 格式定义、加载与校验（格数、层数、坐标）
- `board-generation`: 从布局模板生成棋盘，包含坐标转换、实例化白模、牌型分配与 z_index 层叠

### Modified Capabilities

（无——项目尚无既有 spec）

## Impact

- **新增文件**: `Data/Layouts/*.json`、`Scripts/Generation/`、`Scenes/Board.tscn`
- **修改文件**: `Scripts/main.gd`（改为加载关卡并调用 BoardBuilder）
- **依赖既有**: `Scenes/Mahjong.tscn`、`Scripts/mahjong.gd`、`Scripts/tile_constants.gd`、`Scripts/Data/tile_registry.gd`
- **不在范围**: 点击交互、配对消除、随机洗牌、可解性验证（留给 P2/P3）
