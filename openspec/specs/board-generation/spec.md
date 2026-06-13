# board-generation Specification

## Purpose
TBD - created by archiving change vita-mahjong-p1-layout. Update Purpose after archive.
## Requirements
### Requirement: Grid to world coordinate conversion
The system SHALL convert logical grid coordinates to world pixel positions using `TileConstants.TILE_SIZE`, where one logical x unit equals half the tile width and one logical y unit equals one-third the tile height.

#### Scenario: Bottom-layer tile positioned correctly
- **WHEN** a cell has `x=0`, `y=0`, `layer=0`
- **THEN** the resulting world position places the tile at the board origin offset for that grid cell

#### Scenario: Half-offset tile positioned correctly
- **WHEN** a cell has `x=1` (odd), `y=0`, `layer=1`
- **THEN** the resulting world position is horizontally offset by half a tile width relative to even-x cells

### Requirement: Layer z-index ordering
The system SHALL assign `z_index` to each tile instance so that higher `layer` values render above lower layers, with `grid_y` as secondary sort within the same layer.

#### Scenario: Upper layer renders above lower
- **WHEN** two tiles occupy overlapping screen areas with `layer=0` and `layer=1`
- **THEN** the tile with `layer=1` has a higher `z_index` and appears on top

### Requirement: Board generation from layout and tile list
The system SHALL instantiate one `Mahjong.tscn` per layout cell, call `setup(tile_id)` with the corresponding tile id from a parallel tile list, and parent all instances under a `Board` node.

#### Scenario: Full board built from demo level
- **WHEN** `BoardBuilder.build()` is called with a valid 12-cell layout and a 12-entry tile id list
- **THEN** exactly 12 `MahjongTile` instances are created as children of the Board node, each displaying the assigned tile type

#### Scenario: Mismatched cell and tile count rejected
- **WHEN** the layout cell count does not equal the tile id list length
- **THEN** the board builder reports an error and creates no tiles

### Requirement: Demo level on main scene start
The main scene SHALL load the demo layout (`demo_12.json`) with a pre-defined tile id list and display the complete board when the game starts.

#### Scenario: Game start shows full board
- **WHEN** the user runs the main scene
- **THEN** a multi-layer board of 12 tiles is visible instead of the previous 6-tile horizontal demo row

### Requirement: Preserve P0 tile setup API
Board generation SHALL use the existing `MahjongTile.setup(tile_id)` method without modifying its public interface.

#### Scenario: Generated tiles use setup API
- **WHEN** the board builder creates a tile with id `wan_1`
- **THEN** the tile displays "一万" with the WAN category background color via `setup()`

