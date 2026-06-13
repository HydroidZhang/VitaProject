## Context

Godot 4.6 2D 竖屏项目，单张牌白模尺寸 73×102 px，使用 `Area2D` + `ColorRect` + `Label`。

## Goals / Non-Goals

**Goals:**
- 牌型 id 查询与显示配置
- 花色分类颜色区分
- 单张牌 `setup()` 一行代码完成配置

**Non-Goals:**
- 贴图资源
- 布局与交互

## Decisions

- `TileRegistry.get_tile()` 静态查询（避免与 `Object.get()` 冲突）
- `MahjongTile` 作为脚本 class_name，场景名保持 `Mahjong.tscn`
- 花色颜色在 `TileType.get_category_color()` 集中管理

## Risks / Trade-offs

- [Risk] `get` 方法名冲突 → 使用 `get_tile()` 命名
