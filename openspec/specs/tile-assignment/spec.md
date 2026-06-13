# tile-assignment Specification

## Purpose
TBD - created by archiving change vita-mahjong-p3-tile-assignment. Update Purpose after archive.
## Requirements
### Requirement: Random pair generation
The system SHALL generate tile id assignments by creating N/2 pairs from a tile pool and shuffling them to match the layout cell count.

#### Scenario: Generate for 12-cell layout
- **WHEN** `TileAssigner.assign(cells, pool)` is called with 12 cells
- **THEN** a 12-element tile id array is returned containing 6 matching pairs in random positions

#### Scenario: Odd cell count rejected
- **WHEN** the layout has an odd number of cells
- **THEN** the assigner reports an error and returns empty array

### Requirement: Solvability validation
The system SHALL verify tile assignments are solvable using DFS before starting a level.

#### Scenario: Solvable assignment accepted
- **WHEN** `TileAssigner.assign_solvable(cells, pool)` finds a solvable shuffle within max attempts
- **THEN** the returned tile ids pass `BoardSolver.is_solvable()`

#### Scenario: Solver confirms complete removal
- **WHEN** `BoardSolver.is_solvable(cells, tile_ids)` is called with a valid solvable assignment
- **THEN** the solver returns true indicating all tiles can be eliminated

### Requirement: Auto assignment on level start
The system SHALL automatically generate a solvable tile assignment when `start_level` is called without explicit tile ids.

#### Scenario: Random start
- **WHEN** `board.start_level(path, EMPTY_TILE_IDS, pool)` is called
- **THEN** the board is built with a randomly generated solvable tile assignment

### Requirement: Restart with reshuffle
The system SHALL allow the player to press R to restart the level with a new random solvable assignment.

#### Scenario: Press R to reshuffle
- **WHEN** the player presses R during gameplay
- **THEN** the board is cleared and rebuilt with a new random assignment

