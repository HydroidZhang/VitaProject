## ADDED Requirements

### Requirement: Free tile detection
The system SHALL mark a tile as free only when it is not covered by a higher-layer overlapping tile AND has at least one open side (left or right not blocked on the same layer).

#### Scenario: Edge tile is free
- **WHEN** a tile on the bottom layer has no tile above it and its left side has no same-layer neighbor
- **THEN** `FreeTileChecker.is_free()` returns true

#### Scenario: Center tile blocked on both sides
- **WHEN** a same-layer tile exists at both x-2 and x+2 grid positions
- **THEN** `FreeTileChecker.is_free()` returns false

### Requirement: Click to select
The system SHALL allow the player to click a free tile to select it, showing a gold selection border and scale-up effect.

#### Scenario: Select free tile
- **WHEN** the player clicks a free tile
- **THEN** the tile shows selection visual and emits `pressed` signal

#### Scenario: Locked tile not clickable
- **WHEN** the player clicks a non-free tile
- **THEN** no selection occurs

### Requirement: Pair matching and removal
The system SHALL remove two selected free tiles when they have the same tile type id.

#### Scenario: Successful match
- **WHEN** the player selects tile A then clicks free tile B with the same tile_type.id
- **THEN** both tiles are removed and free states are recalculated

#### Scenario: Mismatch switches selection
- **WHEN** the player selects tile A then clicks free tile B with a different type
- **THEN** selection moves to tile B

### Requirement: Match hint on selection
The system SHALL highlight other free matching tiles with a green border when one tile is selected.

#### Scenario: Hint shown
- **WHEN** a tile is selected
- **THEN** all other free tiles with the same type show match hint visual

### Requirement: Board cleared
The system SHALL display a cleared message when all tiles are removed.

#### Scenario: Win condition
- **WHEN** the last pair is removed
- **THEN** the status label shows "通关！"
