# Design: ScrollListTap

## 模式来源

| 平台 | 对照 |
|------|------|
| Android | `RecyclerView` + touch slop，先识别拖动手势 |
| iOS | `UITableView` `delaysContentTouches` / `canCancelContentTouches` |
| Godot | `ScrollContainer.gui_input` 统一路由，子项 `IGNORE` |

Godot 无独立「精确点击」API；列表场景用 **tap vs drag 状态机** 是业内常规做法。

## 架构

```
LevelSelect
  LevelScroll (ScrollContainer)  ← ScrollListTap.bind()
    LevelList (VBox)
      LevelButton × N  (mouse_filter=IGNORE, 仅展示 + trigger_tap)
```

## 阈值（`scroll_list_tap.gd`）

| 常量 | 默认 | 含义 |
|------|------|------|
| `TOUCH_SLOP_PX` | 10 | 超过则取消本次点击判定 |
| `TAP_SLOP_PX` | 22 | 松手时位移上限，仍算点击 |
| `SCROLL_SLOP_PX` | 4 | 列表滚动超过则不算点击 |

## 关卡行布局

`LevelButton.tscn`：`HBox` 垂直居中，`margin_bottom` 略大于 `margin_top`，补偿按钮贴图视觉重心。
