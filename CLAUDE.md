# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ScreenNote is a menu-bar macOS utility for drawing annotations (pen, shapes, arrows, text) on a
full-screen transparent overlay, toggled by a global keyboard shortcut. Target: macOS 15.0+,
Swift 6.2 (with `ExistentialAny` upcoming feature enabled).

## Build & Test

The app shell lives in `ScreenNote.xcodeproj` (source under `ScreenNote/`) and embeds the local Swift
Package `LocalPackage/`, which contains essentially all source code.

Fast loop (package only):

```
cd LocalPackage && swift build && swift test
```

Full build/tests through Xcode:

```
xcodebuild build -project ScreenNote.xcodeproj -scheme ScreenNote -destination 'platform=macOS,arch=arm64'
xcodebuild test  -project ScreenNote.xcodeproj -scheme ScreenNote -destination 'platform=macOS,arch=arm64'
```

Tests live only in the SPM package (`DataSourceTests`, `ModelTests`) and use Swift Testing
(`@Test`, `#expect`), run via the `ScreenNote` scheme's `UnitTest.xctestplan`. There are no UI
tests and no linter configured.

## Architecture (LUCA)

The codebase follows the [LUCA architecture](https://github.com/Kyome22/LUCA) — three SPM library
targets with strict layering:

- **`DataSource`** — leaf layer. Holds `Entities` (plain values: `AppState`, `AsyncStreamBundle`,
  `Object`, `CanvasState`, etc.), `Dependencies` (thin `Sendable` wrappers around system APIs),
  and `Repositories` (composed of dependencies). Every dependency conforms to `DependencyClient`
  and exposes `liveValue` + `testValue` so tests can inject overrides via
  `testDependency(of:injection:)`.
- **`Model`** — depends on `DataSource`. Holds `Services` (stateless workers wired in
  `AppDelegate`, e.g. canvas object editing and shortcut registration) and `Stores`
  (`@MainActor @Observable` view-models conforming to `Composable`). Also exposes
  `AppDependencies`, the bag of all dependency clients passed everywhere, plus the `AppDelegate`.
- **`UserInterface`** — depends on `DataSource` + `Model`. Holds SwiftUI `Scenes`, `Views`, and the
  AppKit panel bridge (`WorkspacePanelBridge`) that owns the overlay NSPanels. Localized strings
  and assets live in `UserInterface/Resources`.

Never invert these dependencies (UI must not be imported by Model; Model must not be imported by DataSource).

### Stores and the Composable pattern

Stores implement `Composable`: they expose an `Action` enum and a `reduce(_ action:)` async
function, with `send(_:)` calling `reduce` then forwarding to a parent-provided `action` closure.
This is the only way views mutate state. When adding a new screen, create a `Store` in
`Model/Stores/`, define its `Action`, and pair it with a SwiftUI `View` that calls `store.send(...)`.

### Cross-cutting state

Global app state flows through `AppStateClient` (an `AllocatedUnfairLock<AppState>`). Async
streams in `AppState` are produced by services and consumed by stores via `for await` loops
launched inside `reduce(.task)`. Canvas state, canvas visibility, and shortcut settings/commands
all flow through these streams.

`AppDependencies.shared` is the live singleton injected through the `\.appDependencies` SwiftUI
environment value; tests construct one via `AppDependencies.testDependencies(...)`, overriding
only the clients they care about.

## Code Conventions

`CODING_STYLE.md` defines the authoritative style rules (language, naming, comments, formatting) —
read and follow it when editing code.
