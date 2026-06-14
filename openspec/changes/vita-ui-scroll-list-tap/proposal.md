# Proposal: 选关列表滑动与点击分离

## 问题

选关 `ScrollContainer` 内关卡行占满宽度，手指在按钮上滑动时容易误触进关，或按钮 `mouse_filter=STOP` 抢走手势导致列表滑不动。

## 方案

采用移动端列表常见做法（Android touch slop / iOS delayed touch）：

- 在 `ScrollContainer` 层用 `ScrollListTap` 统一判定手势
- 关卡行 `mouse_filter=IGNORE`，不拦截滚动
- 松手且位移/滚动低于阈值时才 `trigger_tap()` 进关

## 范围

- `Scripts/ui/scroll_list_tap.gd`
- `Scripts/level_select.gd`
- `Scripts/level_button.gd`
- `Scenes/LevelButton.tscn` 文字垂直对齐

## 非目标

- 不改主流程与关卡数据
- 不引入新 UI 场景
