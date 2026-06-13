# layout-template Specification

## Purpose
TBD - created by archiving change vita-mahjong-p1-layout. Update Purpose after archive.
## Requirements
### Requirement: Layout JSON format
The system SHALL define a layout template JSON format with `name` (string) and `cells` (array). Each cell SHALL contain integer fields `x`, `y`, and `layer` representing logical grid position and stacking layer.

#### Scenario: Valid layout file parsed
- **WHEN** a JSON file contains `name` and `cells` with valid integer `x`, `y`, `layer` per cell
- **THEN** the layout loader returns a list of cell data objects

#### Scenario: Missing required fields rejected
- **WHEN** a layout JSON file is missing `cells` or a cell is missing `x`, `y`, or `layer`
- **THEN** the layout loader reports an error and returns no layout

### Requirement: Layout cell count validation
The layout loader SHALL validate that the number of cells is greater than zero and that all coordinates are integers.

#### Scenario: Empty layout rejected
- **WHEN** a layout JSON file has an empty `cells` array
- **THEN** the layout loader reports an error and returns no layout

### Requirement: Layout file loading from res path
The system SHALL load layout templates from `res://Data/Layouts/` using Godot's resource path convention.

#### Scenario: Load existing layout by path
- **WHEN** `LayoutLoader.load("res://Data/Layouts/demo_12.json")` is called
- **THEN** the system returns the parsed cell list for that layout

#### Scenario: Missing file handled
- **WHEN** a layout path does not exist
- **THEN** the layout loader reports an error and returns no layout

