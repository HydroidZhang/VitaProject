## 技术方案

### 1. 牌面贴图 `TileTextureAtlas`

- 运行时 `Image` 绘制 65×94 象牙色牌面 + 花色顶栏 + 简化的筒/条/万点数图案
- 风牌/箭牌以花色块 + 留白留给 `Label` 文字
- 按 `tile_id` 缓存 `ImageTexture`，`MahjongTile` 通过 `Sprite2D` 显示

### 2. 动画

| 事件 | 实现 |
|------|------|
| 选中 | `Tween` 缩放回弹（`TRANS_BACK`） |
| 消除 | 并行放大 + 淡出，完成后 `queue_free` |
| 提示 | 保持现有绿框，可选轻微脉冲（后续） |

`BoardController._remove_pair` 等待双牌动画结束后再刷新状态。

### 3. 音效 `SfxManager`（Autoload）

- 运行时生成短促 `AudioStreamWAV` 音调，无需外部音频文件
- `play_click` / `play_match` / `play_clear` / `play_shuffle`
- 多 `AudioStreamPlayer` 池避免连点截断

### 4. 兼容

- 侧面 `ColorRect` 伪 3D 保留，颜色仍随 `face_color` 联动
- 无外部资源时项目可独立运行；后续可替换为真实 PNG 图集
