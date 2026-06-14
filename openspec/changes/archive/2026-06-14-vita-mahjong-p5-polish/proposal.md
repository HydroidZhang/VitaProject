## Why

P0–P4 与 UI 白模已完成，牌面仍由 ColorRect + Label 拼接，消除为瞬间消失，无音效反馈。P5 提升视觉与手感，为后续接入真实美术资源打基础。

## What Changes

- 程序化生成麻将牌面贴图（`TileTextureAtlas`），替换纯色牌面
- 选中弹跳与配对消除 Tween 动画
- `SfxManager` 全局音效（点击、配对、通关、洗牌）
- 更新 `MahjongTile`、`BoardController` 集成动画与音效

## Capabilities

### New Capabilities

- `tile-visuals`: 牌面贴图生成、选中/消除动画、游戏音效

### Modified Capabilities

- `tile-display`: 牌面由 ColorRect 升级为 Sprite2D 贴图

## Impact

- **新增**: `Scripts/Visual/tile_texture_atlas.gd`、`Scripts/Audio/sfx_manager.gd`
- **修改**: `mahjong.gd`、`Mahjong.tscn`、`board_controller.gd`、`main.gd`、`project.godot`
