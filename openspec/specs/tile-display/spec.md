# tile-display Specification

## Purpose
TBD - created by archiving change vita-mahjong-p0-tile-setup. Update Purpose after archive.
## Requirements
### Requirement: Tile type registry
The system SHALL provide a registry of 34 mahjong tile types accessible by string id (e.g. `wan_1`, `wind_east`, `dragon_red`).

#### Scenario: Lookup existing tile
- **WHEN** `TileRegistry.get_tile("wan_1")` is called
- **THEN** a TileType is returned with display_name "一万" and WAN category

### Requirement: Single tile visual setup
The system SHALL configure a MahjongTile instance via `setup(tile_id)` to display the correct label text and category background color.

#### Scenario: Setup wan tile
- **WHEN** `tile.setup("tiao_5")` is called
- **THEN** the label shows "五条" with TIAO category green background

### Requirement: Selection visual state
The system SHALL support `set_selected(bool)` to visually highlight a selected tile.

#### Scenario: Tile selected
- **WHEN** `tile.set_selected(true)` is called
- **THEN** the tile face color is lightened compared to unselected state

