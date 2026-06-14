# tile-visuals

## ADDED Requirements

### Requirement: Procedural tile face textures

The system SHALL render each mahjong tile face using a generated `ImageTexture` keyed by `tile_id`, with category-colored header and suit pips where applicable.

#### Scenario: Tile setup assigns texture

- **WHEN** `MahjongTile.setup()` is called with a valid `tile_id`
- **THEN** the face sprite displays the cached texture for that tile type

### Requirement: Selection animation

The system SHALL play a brief scale bounce when a free tile becomes selected.

#### Scenario: Player selects a tile

- **WHEN** `set_selected(true)` is called on a free tile
- **THEN** the tile scale animates with a back easing before settling at the selected scale

### Requirement: Match elimination animation

The system SHALL animate matched tile pairs with scale-up and fade-out before removing them from the scene.

#### Scenario: Player matches two tiles

- **WHEN** a valid pair is matched
- **THEN** both tiles play the elimination animation
- **AND** board state updates only after both animations complete

### Requirement: Game sound effects

The system SHALL play distinct sounds for tile click, successful match, level clear, and shuffle actions.

#### Scenario: Tile click

- **WHEN** the player presses a free tile
- **THEN** a click sound plays

#### Scenario: Successful match

- **WHEN** the player matches two tiles
- **THEN** a match sound plays


When the player taps a blocked tile, the system SHALL show a floating tip below the top HUD bar (not persistent side marks on tiles).

#### Scenario: Tile covered

- **WHEN** the player taps a tile covered by an upper layer
- **THEN** a floating message "该麻将被盖住" appears below the stats bar with fade-in and upward drift animation

#### Scenario: Tile side blocked

- **WHEN** the player taps a tile blocked on both sides
- **THEN** a floating message "两边被锁住" appears with the same animation

