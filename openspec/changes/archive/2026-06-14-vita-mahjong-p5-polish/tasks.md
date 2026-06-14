## 1. 牌面贴图

- [x] 1.1 创建 `TileTextureAtlas`（程序化牌面 + 缓存）
- [x] 1.2 `Mahjong.tscn` 增加 `FaceSprite`，`mahjong.gd` 接入贴图

## 2. 动画

- [x] 2.1 `MahjongTile` 选中回弹动画
- [x] 2.2 `MahjongTile.play_eliminate()` 消除动画
- [x] 2.3 `BoardController` 等待双牌动画后再刷新

## 3. 音效

- [x] 3.1 创建 `SfxManager` Autoload（程序化短音）
- [x] 3.2 接入点击、配对、通关、洗牌

## 4. 验证

- [x] 4.1 进关可见贴图牌面，选中有动画
- [x] 4.2 配对消除有动画与音效，通关有音效

## 5. 阻挡提示

- [x] 5.1 取消牌侧常驻红绿遮挡条
- [x] 5.2 点击被挡牌时顶栏下飘字提示（盖住/两边锁住）
