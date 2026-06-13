## Why

项目启动时只有 `Mahjong.tscn` 白模（色块 + 文字），无法按牌型动态显示内容。P0 需要建立牌型数据与单张牌配置能力，作为后续布局生成和玩法的基础。

## What Changes

- 新增 `TileType`、`TileRegistry`、`TileConstants` 数据层
- 为 `Mahjong.tscn` 挂载 `mahjong.gd`，提供 `setup(tile_id)` API
- 支持 34 种麻将牌型（万/条/饼/风/箭）的文字与花色底色显示
- 新增 `set_selected()` 选中状态（供 P2 使用）
- `main.gd` 演示横向排列多张不同牌型

## Capabilities

### New Capabilities

- `tile-display`: 单张麻将牌的数据定义、查询与视觉配置

### Modified Capabilities

（无）

## Impact

- **新增**: `Scripts/Data/tile_type.gd`、`tile_registry.gd`、`tile_constants.gd`、`mahjong.gd`
- **修改**: `Scenes/Mahjong.tscn`、`Main.tscn`
