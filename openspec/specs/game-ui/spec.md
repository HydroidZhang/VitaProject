# game-ui Specification

## Purpose

In-game and overlay UI behavior for combo feedback, result stats, and mobile-friendly settings controls.

## Requirements

### Requirement: Combo hint on match

During gameplay, the system SHALL show a single combo hint animation on the right side of the screen when combo count is at least 2, without duplicating combo text at the score pop location.

#### Scenario: Combo hint appears

- **WHEN** a match scores with `combo >= 2`
- **THEN** `GameHUD.ComboTip` shows "N连击!" on the right edge with fade/scale animation
- **AND** the score pop at the collision point shows only the points gained

### Requirement: Result overlay max combo stat

The result overlay SHALL display the highest combo achieved in the cleared level, not total match count.

#### Scenario: Result shows max combo

- **WHEN** `ResultOverlay.show_result()` is called after clearing a level
- **THEN** the combo stat label shows `max_combo`
- **AND** the caption reads "最高连击"

### Requirement: Result level progress

The result overlay SHALL show a colored progress bar for campaign progress (`关卡 X / 20`).

#### Scenario: Progress after clear

- **WHEN** a level is cleared and the result overlay opens
- **THEN** a green-filled progress bar reflects the cleared level index out of total levels

### Requirement: Mobile-friendly settings controls

The settings overlay SHALL use large touch targets for music toggle and a visible colored volume track.

#### Scenario: Music toggle

- **WHEN** the settings overlay is open
- **THEN** music is controlled by a large toggle button (approximately 220×72) with green "开启" and gray "关闭" states

#### Scenario: Volume slider

- **WHEN** the player adjusts volume
- **THEN** an orange-filled `ProgressBar` shows the current level behind a transparent `HSlider` in the same track
- **AND** the percentage label updates in sync
