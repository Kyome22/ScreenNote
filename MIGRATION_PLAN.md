# MIGRATION_PLAN — ScreenNote → RunCatNeo-style LUCA

Primary precedent: **ScreenPointer** (same app shape: menu-bar app + SpiceKey global shortcut +
shortcut intro panel + full-screen overlay NSPanel + Settings tabs). Copy its component shapes
(clients, AsyncStreamBundle with `replaysLatestValue:`, panel bridge in UserInterface,
`<App>AppDelegate` wrapper) wherever they fit; they incorporate the post-review template fixes.

## Phase Status
- [x] Phase 0 — Inventory (user approved)
- [x] Phase 1 — Scaffold
- [x] Phase 2 — DataSource
- [x] Phase 3 — Model
- [x] Phase 4 — UserInterface
- [ ] Phase 5 — Cutover (user smoke test passed)
- [ ] Phase 6 — Cleanup

## App facts
| Item | Value |
|---|---|
| Bundle ID | com.kyome.ScreenNote |
| Display name | ScreenNote |
| Deployment target | 13.0 → **15.0** (user decision) |
| App type | menu-bar (LSUIElement = YES) + Settings window + overlay panels |
| Sandbox & capabilities | Entitlements file: app-sandbox = true, files.user-selected.read-only = true (source of truth; old `ENABLE_APP_SANDBOX = NO` build setting is contradicted). Hardened runtime YES. |
| Entitlements file | ScreenNote/ScreenNote.entitlements (carry verbatim to App/ScreenNote.entitlements) |
| IAP | none |
| License / header type | proprietary (no LICENSE file, "All rights reserved" headers) → `header-proprietary` |
| Error prefix | `SN` (no user-actionable failure cases found → `SNError` may stay minimal/empty; recoverable failures are log events) |
| Localizations | en (source), ja |
| External packages | SpiceKey 5.3.0 exact (keep); add swift-log 1.13.2, AllocatedUnfairLock 1.0.0. No swift-async-algorithms (hand-rolled AsyncStreamBundle per ScreenPointer). No LicenseList (no licenses screen) → plain `swift build`/`swift test` works in all phases. |
| Versions | CURRENT_PROJECT_VERSION = 4.4.0, MARKETING_VERSION = 4.4 |
| App category | public.app-category.utilities |

## Features & screens (smoke-test checklist for Phase 5)
- [ ] Menu bar icon appears (StatusIcon, displayScale 2.0); menu shows Show/Hide Canvas, Settings, About, Report an Issue, Quit
- [ ] Global shortcut toggles canvas: long-press modifier key (configured seconds) AND press-both-side-modifier-keys methods
- [ ] Shortcut intro panel fades in at launch when "show toggle method" is on; fades out when canvas opens and at app termination
- [ ] Canvas overlay covers the visible screen frame, joins all Spaces / full-screen apps, background tint follows background color+opacity settings
- [ ] Toolbar appears at the configured edge (top/right/bottom/left; horizontal/vertical layout)
- [ ] Drawing: pen, line, arrow, fill/line rect, fill/line oval; tools switch via toolbar and key shortcuts (t/p/l/a/r/R/o/O/s)
- [ ] Text tool: click → inline TextField, submit places text; click existing text re-edits; empty text deletes; Cmd+X/C/V/A/Z work inside the field
- [ ] Select tool: rectangle select, click-select, move, resize via 8 anchors; degenerate (size-zero) selection moves instead of resizes
- [ ] Object operations on selection: color, opacity, line width, arrange (front/back), align (6), flip (2, mirrors text), rotate (2, rotates text), duplicate (Cmd-free, offset +20), delete (⌫), clear (Cmd+⌫), select all (Cmd+A)
- [ ] Undo/redo (Cmd+Z / Shift+Cmd+Z), 15 levels, history survives canvas hide/show; aborted drags don't pollute history
- [ ] Settings → General: toggle method radio + long-press seconds slider (0.5–1.5), modifier key picker, toolbar position, intro panel toggle, launch at login
- [ ] Settings → Canvas: clear-all-objects-on-show toggle, default object type, default color (palette popover), default opacity, default line width, background color (white/black), background opacity
- [ ] New defaults apply on next canvas show (resetDefaultSettings); clearAllObjects clears objects and history on show
- [ ] Report an Issue opens a compose-email sheet with environment info
- [ ] Old preferences survive the update (UserDefaults continuity)

## State inventory (compatibility contract)
| UserDefaults key (literal) | Type | Default | Read/written by (old) | New home |
|---|---|---|---|---|
| `toggleMethod` | Int (ToggleMethod raw) | 0 (.longPressKey) | UserDefaultsRepositoryImpl | UserDefaultsRepository |
| `modifierFlag` | Int (SpiceKey ModifierFlag raw) | ModifierFlag.control.rawValue | 〃 | 〃 |
| `longPressSeconds` | Double | 0.5 | 〃 | 〃 |
| `toolBarPosition` | Int (ToolBarPosition raw) | 0 (.top) | 〃 | 〃 |
| `showToggleMethod` | Bool | true | 〃 | 〃 |
| `clearAllObjects` | Bool | false | 〃 | 〃 |
| `defaultObjectType` | Int (ObjectType raw) | 2 (.pen) | 〃 | 〃 |
| `defaultColorIndex` | Int | 0 | 〃 | 〃 |
| `defaultOpacity` | Double | 0.8 | 〃 | 〃 |
| `defaultLineWidth` | Double | 4.0 | 〃 | 〃 |
| `backgroundColorIndex` | Int | 0 | 〃 | 〃 |
| `backgroundOpacity` | Double | 0.02 | 〃 | 〃 |

Other persisted state: none (no files, bookmarks, keychain).
Key constants go to `DataSource/Extensions/String+Extension.swift`; defaults registered in
`UserDefaultsRepository.init`; `ResetUserDefaults` / `ShowAllData` launch arguments replace the
old `RESET_USER_DEFAULTS` flag and `showAllData()`. A test pins all 12 literal key strings.

## System-API touchpoints → clients
| API | Old call sites | New client | Copy from? |
|---|---|---|---|
| UserDefaults | UserDefaultsRepositoryImpl | UserDefaultsClient | template |
| SpiceKey register/unregister | ShortcutModelImpl | SpiceKeyClient | ScreenPointer |
| SMAppService.mainApp | LaunchAtLoginRepositoryImpl | SMAppServiceClient | ScreenPointer/RunCatNeo |
| NSApp activate/terminate | MenuViewModelImpl | NSApplicationClient | ScreenPointer |
| NSApp.orderFrontStandardAboutPanel | WindowModelImpl.openAbout | NSApplicationClient | ScreenPointer |
| NSSharingService(composeEmail) | IssueReporterModelImpl | NSSharingServiceClient | new (ScreenPointer has an issue-report shape in Menu) |
| Logging | logput() | LoggingSystemClient + LogService | template |
| NSScreen / NSPanel / NSHostingView / NSAnimationContext | ShortcutPanel, WorkspacePanel, WindowModelImpl | stays inside WorkspacePanelBridge (UserInterface root) — bridges, not clients | ScreenPointer PointerPanelBridge |
| NotificationCenter didFinishLaunching/willTerminate | ScreenNoteAppModelImpl | AppDelegate lifecycle methods | ScreenPointer ScreenNoteAppDelegate wrapper |
| UndoManager | ObjectModelImpl | replaced by snapshot undo/redo stacks in AppState (no client) | — |
| NSApp.sendAction(showSettingsWindow) | WindowModelImpl.openSettings | dropped — macOS 15 always uses SettingsLink | — |

`Date()` / `UUID()`: only `Object.id = UUID().uuidString` (entity identity) → stays a direct call.

## Cross-layer streams (AppState.AsyncStreamBundle fields)
| Stream | T | Producer | Consumers |
|---|---|---|---|
| `canvasState` | CanvasState (objects, objectType, objectProperties, inputTextProperties, selectedObjectsBounds, isSelecting — one entity to avoid mixed-state frames) | ObjectService | Workspace store |
| `canvasVisible` | CanvasVisible | WorkspacePanelBridge | Menu store |
| `shortcutSettings` | Void (no replay) | UserDefaultsRepository setters (toggleMethod/modifierFlag/longPressSeconds) | AppDelegate observer → ShortcutService.setShortcut() |
| `shortcutCommand` | Void (no replay; toggle only) | SpiceKeyClient handler (via ShortcutService) | WorkspacePanelBridge (show/hide canvas) |

Plain AppState fields (not streamed): `undoStack: [[Object]]`, `redoStack: [[Object]]` (cap 15).

## File mapping (every old file)
| Old path (ScreenNote/) | Action | New path / reason |
|---|---|---|
| Data/Entity/AlignMethod.swift | split ✅(DataSource side) | DataSource/Entities/AlignMethod.swift (+Codable raw enum); symbolName/help → UserInterface/Extensions/AlignMethod+Extension.swift |
| Data/Entity/Anchor.swift | port ✅(DataSource side) | DataSource/Entities/Anchor.swift (pure CG logic) |
| Data/Entity/ArrangeMethod.swift | split ✅(DataSource side) | DataSource/Entities/ArrangeMethod.swift; UI props → UserInterface/Extensions/ArrangeMethod+Extension.swift |
| Data/Entity/CanvasVisible.swift | split ✅(DataSource side) | DataSource/Entities/CanvasVisible.swift; label → UserInterface/Extensions/CanvasVisible+Extension.swift |
| Data/Entity/Curve.swift | port ✅(DataSource side) | DataSource/Entities/Curve.swift |
| Data/Entity/FlipMethod.swift | split ✅(DataSource side) | DataSource/Entities/FlipMethod.swift; UI props → UserInterface/Extensions/FlipMethod+Extension.swift |
| Data/Entity/InputTextProperties.swift | port ✅(DataSource side) | DataSource/Entities/InputTextProperties.swift |
| Data/Entity/Line.swift | port ✅(DataSource side) | DataSource/Entities/Line.swift |
| Data/Entity/Object.swift | split/rewrite ✅(DataSource side) | DataSource/Entities/Object.swift — `paletteIndex: Int` replaces `color_: Color`; bounds/isHit/copy/fontSize stay (hit-testing via CGPath); SwiftUI `path`/`strokeStyle`/`color` → UserInterface/Extensions/Object+Extension.swift |
| Data/Entity/ObjectProperties.swift | port/rewrite ✅(DataSource side) | DataSource/Entities/ObjectProperties.swift (paletteIndex instead of Color) |
| Data/Entity/ObjectType.swift | split ✅(DataSource side) | DataSource/Entities/ObjectType.swift; symbolName/label/help → UserInterface/Extensions/ObjectType+Extension.swift |
| Data/Entity/RotateMethod.swift | split ✅(DataSource side) | DataSource/Entities/RotateMethod.swift (keep `angle`); UI props → UserInterface/Extensions/RotateMethod+Extension.swift |
| Data/Entity/SettingsTabType.swift | port ✅(DataSource side) | DataSource/Entities/SettingsTabType.swift |
| Data/Entity/TextOrientation.swift | split ✅(DataSource side) | DataSource/Entities/TextOrientation.swift (rotate/flip/size/endPosition); angle/scale/angle3D/axis → UserInterface/Extensions/TextOrientation+Extension.swift |
| Data/Entity/ToggleMethod.swift | split ✅(DataSource side) | DataSource/Entities/ToggleMethod.swift; label/panelWidth → UserInterface/Extensions/ToggleMethod+Extension.swift |
| Data/Entity/ToolBarDirection.swift | port ✅(DataSource side) | DataSource/Entities/ToolBarDirection.swift |
| Data/Entity/ToolBarPosition.swift | split ✅(DataSource side) | DataSource/Entities/ToolBarPosition.swift; label → UserInterface/Extensions/ToolBarPosition+Extension.swift |
| Data/Repository/UserDefaultsRepository.swift | rewrite ✅(DataSource side) | DataSource/Repositories/UserDefaultsRepository.swift (client-composed struct; persists + sends `shortcutSettings`) |
| Data/Repository/LaunchAtLoginRepository.swift | rewrite ✅(DataSource side) | SMAppServiceClient + logic in GeneralSettings store (drop protocol) |
| Domain/ScreenNoteAppModel.swift | split ✅(Model side) | Model/AppDelegate.swift (lifecycle, observers) + Model/AppDependencies.swift (composition); `settingsTab` → local @State in SettingsView |
| Domain/Model/ObjectModel.swift | split ✅ | state → DataSource/Entities/CanvasState.swift + AppState; behavior → Model/Services/ObjectService.swift; undo → AppState snapshot stacks |
| Domain/Model/ShortcutModel.swift | rewrite ✅ | Model/Services/ShortcutService.swift + SpiceKeyClient |
| Domain/Model/IssueReportModel.swift | rewrite ✅(MailClient + Menu store; strings from UserInterface in Phase 4) | Model/Services/IssueReportService.swift + NSSharingServiceClient |
| Domain/ViewModel/CanvasSettingsViewModel.swift | rewrite ✅ | Model/Stores/CanvasSettings.swift |
| Domain/ViewModel/CanvasViewModel.swift | merge ✅ | Model/Stores/Workspace.swift |
| Domain/ViewModel/GeneralSettingsViewModel.swift | rewrite ✅ | Model/Stores/GeneralSettings.swift |
| Domain/ViewModel/MenuViewModel.swift | rewrite ✅ | Model/Stores/Menu.swift |
| Domain/ViewModel/ToolBarModel.swift | merge ✅ | Model/Stores/Workspace.swift |
| Domain/ViewModel/WindowModel.swift | rewrite | UserInterface/WorkspacePanelBridge.swift (panel fleet + NSWindowDelegate, per ScreenPointer) |
| Domain/ViewModel/WorkspaceViewModel.swift | drop ✅ | composition handled by Workspace store + bridge |
| Helper/AppKit+Extensions.swift | split ✅ | NSTextField/NSTextView overrides → UserInterface/Extensions/NSTextField+Extension.swift, NSTextView+Extension.swift; `String.calculateSize` → DataSource/Extensions/String+Extension.swift (NSFont text measurement, needed by Object.fontSize/endEditing logic); NSColor.primaries → UserInterface/Extensions/NSColor+Extension.swift; NSStatusItem/NSMenu/NSMenuItem helpers → drop (dead since MenuBarExtra) |
| Helper/Color+Extensions.swift | port ✅ | UserInterface/Extensions/Color+Extension.swift (palette) |
| Helper/CoreGraphics+Extensions.swift | port ✅(DataSource side) | DataSource/Extensions/CGPoint+Extension.swift, CGSize+Extension.swift |
| Helper/ModifierFlag+Extensions.swift | port ✅ | UserInterface/Extensions/ModifierFlag+Extension.swift (mind SpiceKey type-name collisions) |
| Helper/Path+Extensions.swift | rewrite ✅(DataSource side) | DataSource/Extensions/CGPath+Extension.swift (allPoints/intersects/anchor rects on CGPath); SwiftUI Path conversion → UserInterface/Extensions/Path+Extension.swift |
| Helper/String+Extensions.swift | drop ✅(DataSource side) | replaced by Bundle+Extension template |
| Helper/Utils.swift | split ✅ | CGPoint/CGSize operators → DataSource/Extensions; logput → LogService; PreviewMock/NOT_IMPLEMENTED → drop |
| Presentation/ScreenNoteApp.swift | rewrite ✅ | App/ScreenNoteApp.swift (shell) + UserInterface/Scenes/MenuBarScene.swift, SettingsScene.swift + UserInterface/ScreenNoteAppDelegate.swift (wraps Model AppDelegate + owns WorkspacePanelBridge) |
| Presentation/View/CanvasView.swift | rewrite ✅ | UserInterface/Views/Workspace/CanvasView.swift (store-driven) |
| Presentation/View/MenuView.swift | rewrite ✅ | UserInterface/Views/Menu/MenuView.swift |
| Presentation/View/PreActionButtonStyle.swift | port ✅ | UserInterface/Views/Components/PreActionButtonStyle.swift (drop #available) |
| Presentation/View/ShortcutPanel.swift | port ✅ | UserInterface/Views/Shortcut/ShortcutPanel.swift (per ScreenPointer) |
| Presentation/View/ShortcutView.swift | port ✅ | UserInterface/Views/Shortcut/ShortcutView.swift |
| Presentation/View/WorkspacePanel.swift | rewrite ✅ | panel class → UserInterface/Views/Workspace/WorkspacePanel.swift; ownership/fade logic → WorkspacePanelBridge |
| Presentation/View/WorkspaceView.swift | rewrite ✅ | UserInterface/Views/Workspace/WorkspaceView.swift |
| Presentation/View/Settings/CanvasSettingsView.swift | rewrite ✅ | UserInterface/Views/Settings/CanvasSettingsView.swift |
| Presentation/View/Settings/ColorButtonStyle.swift | port ✅ | UserInterface/Views/Settings/ColorButtonStyle.swift |
| Presentation/View/Settings/GeneralSettingsView.swift | rewrite ✅ | UserInterface/Views/Settings/GeneralSettingsView.swift |
| Presentation/View/Settings/SelectableColorButtonStyle.swift | port ✅ | UserInterface/Views/Settings/SelectableColorButtonStyle.swift |
| Presentation/View/Settings/SettingsView.swift | rewrite ✅ | UserInterface/Views/Settings/SettingsView.swift (tab selection = local @State) |
| Presentation/View/ToolBar/*.swift (popovers, styles, H/V toolbar) | rewrite ✅ | UserInterface/Views/Workspace/ToolBar/ (store-driven; popovers keep closure/Binding APIs where they only relay) |
| Localizable.xcstrings | copy ✅ | UserInterface/Resources/Localizable.xcstrings |
| Assets.xcassets | split ✅ | colors + StatusIcon → UserInterface/Resources/Media.xcassets; AppIcon → App/ shell |
| Preview Content/ | drop ✅ | no #Preview in new code |
| Info.plist | port | App/Info.plist (ITSAppUsesNonExemptEncryption only; GENERATE_INFOPLIST_FILE covers the rest) |
| ScreenNote.entitlements | copy verbatim | App/ScreenNote.entitlements |

## Tricky items
### Canvas state + undo history outliving the panel
Objects, tool, and undo history live app-wide (canvas hide/show recreates the panel but keeps state;
`clearAllObjects` optionally resets on show). Old: ObjectModel singleton + UndoManager(15).
New: `CanvasState` entity streamed via AppState (single bundle → no mixed-state frames,
ScreenPointer CanvasInfo precedent); behavior in `ObjectService` (stateless, `withLock` + send);
undo/redo as `[[Object]]` snapshot stacks in AppState, cap 15 — pure and testable, replaces
UndoManager (AnimatedImageMaker precedent, adapted because history must outlive any store).
The old code pushes history *before* mutating and pops via `undo()` for no-op drags — replicate
exactly (pushHistory clears redoStack; aborted drag = pop without apply).

### Full-screen overlay + shortcut intro panels (NSPanel fleet)
Precedent: ScreenPointer `PointerPanelBridge` (UserInterface root, @MainActor, public).
`WorkspacePanelBridge` owns WorkspacePanel + ShortcutPanel, is NSWindowDelegate, consumes
`shortcutCommand` stream, sends `canvasVisible`, applies background color/opacity and
clearAllObjects/resetDefaultSettings on show, fades panels. Owned by `ScreenNoteAppDelegate`
(UserInterface) wrapping Model's AppDelegate. `WorkspaceHostingView.acceptsFirstMouse` override stays.

### Object carries SwiftUI Color / Path
Precedent: ScreenPointer (CGPath in DataSource, SwiftUI conversion in UI extension).
`Object.paletteIndex: Int` (0–39, index = column + 8×row, same encoding as `defaultColorIndex`)
replaces stored `Color`; hit-testing rewritten on CGPath (`CGPath.applyWithBlock` mirrors the old
`Path.cgPath` walk); `path`/`strokeStyle`/`color` become UserInterface computed extensions.
Toolbar/settings color buttons select by index, ending the old Color-equality comparison.

### Text measurement (Object.fontSize, endEditing)
`String.calculateSize(using: NSFont)` feeds entity logic (font-size estimation, text end position),
so it stays in DataSource as an extension (`import AppKit` for the NSFont value type only —
no UI, deterministic, testable). Precedent: none — judgment call.

### NSTextField/NSTextView global overrides
`performKeyEquivalent` (Cmd+X/C/V/A/Z in the borderless non-activating panel) and
`insertionPointColor` are app-wide `open override`s in extensions. Port verbatim to
UserInterface/Extensions; without them the text tool loses edit shortcuts. Precedent: none.

### Issue-report email with localized body
Old: `String(localized:)` in Domain. New: localized strings belong to UserInterface resources, so
the Menu store action gets the composed strings from… **decide in Phase 3 against ScreenPointer's
Menu store** (it has the same feature); follow its split exactly.

### SpiceKey on Swift 6 / macOS 15
ScreenPointer ships SpiceKey 5.3.0 exact under the same toolchain — copy its SpiceKeyClient and
the `modifierFlagsArray`-style indirection (ScreenPointer lesson: never name `SpiceKey.ModifierFlags`
bare in tests). Note old key `modifierFlag` stores SpiceKey's `ModifierFlag` rawValue — check 5.3.0's
type names (`ModifierFlag` vs `ModifierFlags`) at port time; the persisted rawValue must keep meaning.

### Store granularity for the workspace
One screen = one store: `Workspace` absorbs ToolBarModel + CanvasViewModel + WorkspaceViewModel
(toolbar and canvas are subviews of one panel sharing selection/tool state). H/V toolbars and
CanvasView all receive the same store instance.

## Build settings extract
| Placeholder | Value |
|---|---|
| BUNDLE_ID | com.kyome.ScreenNote |
| DISPLAY_NAME | ScreenNote |
| MACOS_DEPLOYMENT_TARGET | 15.0 |
| BUILD_VERSION | 4.4.0 |
| MARKETING_VERSION | 4.4 |
| APP_CATEGORY | public.app-category.utilities |
| LS_UI_ELEMENT | YES |
| KNOWN_REGIONS | en, Base, ja |
| DEVELOPMENT_TEAM | VJ5N2X84K8 |
| Other | ENABLE_HARDENED_RUNTIME = YES; sandbox per entitlements file; INFOPLIST_KEY_NSHumanReadableCopyright = "© 2019-2024 Takuto Nakamura"; ITSAppUsesNonExemptEncryption = NO (Info.plist); old SWIFT_VERSION 5.0 → 6.2 via package tools-version |
