# level-progression Specification

## Purpose

Multi-level progression for Vita Mahjong: level config loading, level select UI, unlock persistence, and scroll-safe tap handling on the level list.

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

### Requirement: Scrollable level list tap discrimination

The level select screen SHALL distinguish scrolling from tapping using centralized gesture handling on the `ScrollContainer`, not per-row touch interception.

Implementation: `Scripts/ui/scroll_list_tap.gd` bound to `LevelScroll`; level rows use `mouse_filter=IGNORE` and `trigger_tap()` on confirmed tap.

#### Scenario: Scroll on a level row

- **WHEN** the player drags vertically on a level row beyond the touch slop or the list scroll offset changes
- **THEN** the list scrolls
- **AND** no level is started

#### Scenario: Tap on an unlocked level row

- **WHEN** the player releases touch on an unlocked level row without exceeding touch slop and without meaningful list scroll
- **THEN** that level starts

#### Scenario: Level rows do not block scroll

- **WHEN** the player begins a drag on a level row
- **THEN** the row uses `mouse_filter=IGNORE` so `ScrollContainer` receives the gesture

### Requirement: Level row label alignment

Level row labels SHALL be vertically centered within the row button artwork in `LevelButton.tscn`.

#### Scenario: Row text visually centered

- **WHEN** the level select list is shown
- **THEN** level id, name, and stars appear vertically centered relative to the row background

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
