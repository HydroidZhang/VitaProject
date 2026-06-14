## ADDED Requirements

### Requirement: Scrollable level list tap discrimination

The level select screen SHALL distinguish scrolling from tapping using centralized gesture handling on the `ScrollContainer`, not per-row touch interception.

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
