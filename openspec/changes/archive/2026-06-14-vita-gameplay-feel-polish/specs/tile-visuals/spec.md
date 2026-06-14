## MODIFIED Requirements

### Requirement: Selection animation

The system SHALL show a high-contrast gold selection treatment on the selected free tile, including a thick gold border, semi-transparent yellow face overlay, outer glow, gold side edges, sparkle particles, and a brief scale bounce settling at selected scale.

#### Scenario: Player selects a tile

- **WHEN** `set_selected(true)` is called on a free tile
- **THEN** `SelectionFrame` becomes visible with gold border and face overlay
- **AND** `SelectionSparkles` emits while selected
- **AND** the tile scale animates with back easing before settling above 1.0

### Requirement: Match elimination animation

The system SHALL animate matched pairs with a merge impact, shatter burst, debris particles, and fade-out before removing tiles from the scene.

#### Scenario: Player matches two tiles

- **WHEN** a valid pair is matched
- **THEN** both tiles move together and impact at the collision center
- **AND** `MatchCollisionEffect` spawns on `TileLayer` at the collision position
- **AND** tiles squash, burst apart with rotation, and fade out
- **AND** board state updates only after the shatter sequence completes

## ADDED Requirements

### Requirement: Match hint visual

When one tile is selected, other free matching tiles SHALL show a mint-green face overlay and thinner green border distinct from the gold selection style.

#### Scenario: Hint shown for matchable tile

- **WHEN** a tile is selected and another free tile shares the same `tile_type.id`
- **THEN** the other tile shows `HintFrame` with green overlay and border
- **AND** the hint is hidden if that tile becomes selected

### Requirement: Collision particle effect coordinate space

Collision visual effects SHALL be parented to `TileLayer` using tile-local collision coordinates so particles appear at the actual impact point after board scaling and centering.

#### Scenario: Effect at impact point

- **WHEN** `MatchCollisionEffect.spawn()` runs after a pair collision
- **THEN** the effect root is added as a child of `TileLayer`
- **AND** its position equals the collision center in tile-layer local space
