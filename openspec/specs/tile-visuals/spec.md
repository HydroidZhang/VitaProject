# tile-visuals Specification

## Purpose

Mahjong tile presentation: face textures, selection/hint visuals, match elimination and collision effects, blocked-tile tips, and gameplay sound effects.

## Requirements

### Requirement: Procedural tile face textures

The system SHALL render each mahjong tile face using a generated `ImageTexture` keyed by `tile_id`, with category-colored header and suit pips where applicable.

#### Scenario: Tile setup assigns texture

- **WHEN** `MahjongTile.setup()` is called with a valid `tile_id`
- **THEN** the face sprite displays the cached texture for that tile type

### Requirement: Selection animation

The system SHALL show a high-contrast gold selection treatment on the selected free tile, including a thick gold border, semi-transparent yellow face overlay, outer glow, gold side edges, sparkle particles, and a brief scale bounce settling at selected scale.

#### Scenario: Player selects a tile

- **WHEN** `set_selected(true)` is called on a free tile
- **THEN** `SelectionFrame` becomes visible with gold border and face overlay
- **AND** `SelectionSparkles` emits while selected
- **AND** the tile scale animates with back easing before settling above 1.0

### Requirement: Match hint visual

When one tile is selected, other free matching tiles SHALL show a mint-green face overlay and thinner green border distinct from the gold selection style.

#### Scenario: Hint shown for matchable tile

- **WHEN** a tile is selected and another free tile shares the same `tile_type.id`
- **THEN** the other tile shows `HintFrame` with green overlay and border
- **AND** the hint is hidden if that tile becomes selected

### Requirement: Match elimination animation

The system SHALL animate matched pairs with a merge impact, shatter burst, debris particles, and fade-out before removing tiles from the scene.

#### Scenario: Player matches two tiles

- **WHEN** a valid pair is matched
- **THEN** both tiles move together and impact at the collision center
- **AND** `MatchCollisionEffect` spawns on `TileLayer` at the collision position
- **AND** tiles squash, burst apart with rotation, and fade out
- **AND** board state updates only after the shatter sequence completes

### Requirement: Collision particle effect coordinate space

Collision visual effects SHALL be parented to `TileLayer` using tile-local collision coordinates so particles appear at the actual impact point after board scaling and centering.

#### Scenario: Effect at impact point

- **WHEN** `MatchCollisionEffect.spawn()` runs after a pair collision
- **THEN** the effect root is added as a child of `TileLayer`
- **AND** its position equals the collision center in tile-layer local space

### Requirement: Game sound effects

The system SHALL play distinct sounds for tile click, successful match, level clear, and shuffle actions.

#### Scenario: Tile click

- **WHEN** the player presses a free tile
- **THEN** a click sound plays

#### Scenario: Successful match

- **WHEN** the player matches two tiles
- **THEN** a collision sound plays at impact

### Requirement: Blocked tile floating tip

When the player taps a blocked tile, the system SHALL show a floating tip below the top HUD bar (not persistent side marks on tiles).

#### Scenario: Tile covered

- **WHEN** the player taps a tile covered by an upper layer
- **THEN** a floating message "该麻将被盖住" appears below the stats bar with fade-in and upward drift animation

#### Scenario: Tile side blocked

- **WHEN** the player taps a tile blocked on both sides
- **THEN** a floating message "两边被锁住" appears with the same animation
