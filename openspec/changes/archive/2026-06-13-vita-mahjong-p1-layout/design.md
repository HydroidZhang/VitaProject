## Context

项目是 Godot 4.6 2D 竖屏游戏（720×1080），已完成 P0：
- `Mahjong.tscn` 白模（73×102 px，`Area2D` + `ColorRect` + `Label`）
- `MahjongTile.setup(tile_id)` 按牌型显示文字与花色底色
- `TileRegistry` 提供 34 种牌型定义
- `TileConstants` 定义牌尺寸常量

当前 `main.gd` 仅横向排列 6 张演示牌，没有布局数据驱动能力。

## Goals / Non-Goals

**Goals:**
- 定义可复用的 JSON 布局模板格式
- 实现逻辑网格坐标 → 世界像素坐标转换（支持半格偏移层叠）
- 实现 `BoardBuilder`，从布局 + 牌型列表生成完整牌盘
- 提供第一个可运行小关卡（12 张牌，3 层），运行 Main 场景即可看到

**Non-Goals:**
- 点击选中、配对消除（P2）
- 随机洗牌与可解性验证（P3）
- 多关卡选择 UI（P4）
- 贴图资源，继续使用白模 ColorRect + Label

## Decisions

### 1. 逻辑网格使用 ×2 整数坐标

**选择**: 牌宽 = 2 格、牌高 = 3 格，坐标全部为整数（偶数 x 为整格对齐，奇数 x 为半格偏移）。

**理由**: 避免浮点累积误差；上层牌 x 偏移 1 格即可实现经典麻将叠层效果。

**备选**: 直接用像素坐标 —— 不利于复用和不同分辨率适配，弃用。

### 2. 布局与牌型分配分离

**选择**: JSON 布局只描述 `{x, y, layer}` 格子；牌型列表由关卡配置单独提供（`tiles` 数组，顺序与 cells 一一对应）。

**理由**: P1 用手工验证过的固定分配最简单可靠；布局模板可复用于不同牌型组合。

**备选**: 布局内嵌牌型 —— 灵活性低，同一形状无法快速换关，P1 不必要。

### 3. 坐标原点与缩放

**选择**: `Board` 节点居中于视口；`grid_to_world()` 使用 `TileConstants.TILE_SIZE` 做缩放，逻辑 1 格 = 像素半宽（36.5 px）。

**公式**:
```
world_x = origin_x + grid_x * (TILE_SIZE.x / 2)
world_y = origin_y + grid_y * (TILE_SIZE.y / 3)
z_index = layer * 100 + grid_y
```

### 4. 文件结构

```
res://
├── Data/Layouts/demo_12.json      # 第一个小布局
├── Scenes/Board.tscn              # 牌桌容器（Node2D）
├── Scripts/Generation/
│   ├── cell_data.gd               # 单格数据
│   ├── layout_loader.gd           # 读 JSON
│   ├── grid_converter.gd          # 坐标转换
│   └── board_builder.gd           # 生成牌盘
└── Scripts/main.gd                # 加载 demo 关卡
```

### 5. Board 场景结构

**选择**: `Board.tscn` 为 `Node2D` 根节点，子节点为动态实例化的 `Mahjong.tscn`。`BoardBuilder` 为静态/RefCounted 工具类，不挂场景树。

## Risks / Trade-offs

- **[Risk] JSON 格数与牌型列表长度不一致** → `LayoutLoader` 校验，不匹配时 `push_error` 并中止生成
- **[Risk] 布局超出屏幕** → demo 布局手工验证；`Board` 居中 + 小布局规避
- **[Trade-off] 固定分配无随机性** → P1 可接受，P3 再引入 `TileAssigner`
- **[Trade-off] 无遮挡检测** → P1 只生成视觉层叠，P2 再加 `FreeTileChecker`

## Migration Plan

1. 新增 Generation 脚本与 JSON 数据，不破坏既有 P0 API
2. 新增 `Board.tscn`，`main.gd` 改为调用 `BoardBuilder`
3. 保留 `Mahjong.tscn` 和 `setup()` 接口不变
4. 回滚：恢复 `main.gd` 演示排列即可

## Open Questions

- demo 布局形状：采用简单 3 层金字塔（12 格），还是经典龟形子集？→ P1 默认金字塔，易于验证层叠
