# CODEBUDDY.md This file provides guidance to CodeBuddy Code when working with code in this repository.

## Build & Run Commands

```bash
# Build the project
xcodebuild -project 2048.xcodeproj -scheme 2048 -sdk iphonesimulator -configuration Debug build

# Run tests
xcodebuild test -project 2048.xcodeproj -scheme 2048Tests -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

This is an iOS 2048 game using **MVC pattern** with UIKit (programmatic, no Storyboard).

### Data Flow
1. **View** (GameView) detects swipe gestures and sends offset to Controller
2. **Controller** (ViewController) converts offset to Direction and calls Model
3. **Model** (Game) calculates game logic and returns `[Action]`
4. **Controller** passes actions to View
5. **View** executes animations based on actions

### Key Components

**Model Layer:**
- `Game.swift` - Core logic: 2D array storage (`world[row][col]`), move/merge calculations
- `Card.swift` - Value container with `upgrade()` method
- `Action.swift` - Enum describing game events: `.move`, `.upgrade`, `.new`, `.delete`, `.success`, `.failure`

**View Layer:**
- `GameView.swift` - Board layout, gesture handling, card positioning via `getRectOf(row:col:)`
- `CardView.swift` - Individual tile display with animations
- `TileView.swift` - Label for number display

**Controller Layer:**
- `ViewController.swift` - Orchestrates Game and GameView, handles game state

### Important Patterns

- CardView positions are tracked by **tag**: `tag = (row + 1) * 100 + col`
- Animation uses `UIViewPropertyAnimator.runningPropertyAnimator`
- Long press on cards triggers `CardLongPressed` notification with `position` and `value` in userInfo
- `Position` struct: `Position(row: Int, col: Int)`

### Adding New Features

When adding new Action types:
1. Add case to `Action.swift` enum
2. Handle in `GameView.performActions(_:)` switch statement
3. If it affects gameplay, handle in `Game.move(_:)` and return the action
