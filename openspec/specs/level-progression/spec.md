# level-progression Specification

## Purpose
TBD - created by archiving change vita-mahjong-p4-levels. Update Purpose after archive.
## Requirements
### Requirement: Level configuration loading
The system SHALL load level definitions from `res://Data/Levels/levels.json`, each with id, name, layout_path, tile_pool, and difficulty.

#### Scenario: Load level list
- **WHEN** `LevelRegistry.load_all()` is called
- **THEN** an ordered array of LevelData is returned

#### Scenario: Invalid level file handled
- **WHEN** levels.json is missing or malformed
- **THEN** the registry reports an error and returns empty list

### Requirement: Level select screen
The system SHALL display a level selection UI listing all levels with name and lock state.

#### Scenario: Show unlocked levels
- **WHEN** the main scene starts
- **THEN** level 1 is selectable and higher levels show locked until unlocked

#### Scenario: Start selected level
- **WHEN** the player clicks an unlocked level button
- **THEN** the board is built with that level's layout and tile pool

### Requirement: Progress persistence
The system SHALL save and load unlock progress to `user://vita_progress.json`.

#### Scenario: First launch
- **WHEN** no progress file exists
- **THEN** only level 1 is unlocked

#### Scenario: Unlock on clear
- **WHEN** the player clears level N and level N+1 exists
- **THEN** level N+1 becomes unlocked and progress is saved

### Requirement: Return to level select
The system SHALL allow returning to level select after clearing a level or pressing Esc during gameplay.

#### Scenario: Return after clear
- **WHEN** a level is cleared
- **THEN** the player can return to level select and see newly unlocked levels

#### Scenario: Esc during game
- **WHEN** the player presses Esc during gameplay
- **THEN** the board is hidden and level select is shown

### Requirement: Main scene starts at level select
The main scene SHALL show the level select screen first instead of immediately starting a single demo layout.

#### Scenario: Game start shows level select
- **WHEN** the user runs the main scene
- **THEN** the level select UI is visible and no board is shown until a level is chosen

