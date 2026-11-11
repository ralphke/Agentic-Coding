# Proposal

## Why

The beginner lab starts with a small, working page, but the workshop's target
HTML file is currently empty. A welcome page gives participants an approachable
first example they can open locally and adapt.

## What Changes

- Add a workshop welcome page with a heading, short paragraph,
  styled link, and simple responsive styling.
- Link to the local workshop roadmap so the call to action has a real destination.
- Keep the page independent of a backend, framework, or remotely hosted assets.
- Add the existing `image/Agentic-coding.png` logo in the header.


## Capabilities

### New Capabilities

- `workshop-welcome`: A locally viewable welcome page for workshop participants.

### Modified Capabilities

None.

## Impact

- The existing `src/hello-copilot.html` file will contain the page.
- The link will point to the existing `doc/workshop-roadmap.md` file.
- The page will use the existing `image/Agentic-coding.png` file.
- No dependencies or APIs are required.

## Acceptance Criteria

- Opening the HTML file locally displays a heading and a short workshop description.
- A visible, keyboard-accessible link opens the workshop roadmap.
- The header displays the local workshop logo.
- The layout remains readable on narrow and wide screens without remotely hosted resources.
