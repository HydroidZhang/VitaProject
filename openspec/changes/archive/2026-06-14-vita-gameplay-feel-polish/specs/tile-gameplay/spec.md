## ADDED Requirements

### Requirement: Combo chain scoring

The system SHALL treat consecutive pair removals within `COMBO_WINDOW_SEC` (3 seconds) as a combo chain, track the maximum combo per level, and award bonus score for combo levels ≥ 2.

#### Scenario: Second match within window

- **WHEN** the player removes a pair and removes another pair within 3 seconds
- **THEN** `current_combo` becomes 2
- **AND** bonus score `(combo - 1) * COMBO_BONUS_PER_LEVEL` is added to the match total

#### Scenario: Combo window expires

- **WHEN** the player waits more than 3 seconds after a removal before the next removal
- **THEN** the next removal resets `current_combo` to 1
- **AND** no combo bonus is applied for that removal alone

#### Scenario: Level result reports max combo

- **WHEN** the board is cleared
- **THEN** `level_cleared` includes `max_combo` for the result overlay
