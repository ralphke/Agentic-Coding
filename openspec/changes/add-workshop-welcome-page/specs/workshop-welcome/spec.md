# Workshop Welcome

## Purpose

Provide workshop participants with a simple welcome page they can open locally
and use as a starting point for the beginner exercise.

## ADDED Requirements

### Requirement: Workshop introduction
The page SHALL display a clear heading and a short paragraph introducing the
workshop when opened locally.

#### Scenario: Open the page
- **WHEN** a participant opens the HTML file in a browser
- **THEN** the heading and workshop introduction are visible without a server

### Requirement: Workshop logo
The page SHALL display the existing local workshop logo in its header with
appropriate alternative text.

#### Scenario: View the logo
- **WHEN** a participant opens the page with the repository files available locally
- **THEN** the workshop logo is displayed in the header

### Requirement: Workshop roadmap link
The page SHALL provide a visible, keyboard-accessible link to the local workshop
roadmap.

#### Scenario: Navigate to the roadmap
- **WHEN** a participant activates the roadmap link by mouse or keyboard
- **THEN** the browser opens the existing workshop roadmap file

### Requirement: Readable presentation
The page SHALL use styling that keeps its content readable on narrow and wide
screens without relying on remotely hosted assets or a backend.

#### Scenario: View on different screen sizes
- **WHEN** the page is opened at a narrow or wide viewport
- **THEN** the introduction and link remain readable and usable without horizontal scrolling
