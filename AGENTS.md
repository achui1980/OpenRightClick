# AGENTS.md — OpenRightClick

## Project Overview

macOS Finder context menu extension (right-click menu) built with **Swift 5** and **SwiftUI**.
Two Xcode targets: a main settings app and a Finder Sync Extension (`.appex`).
Platform: **macOS 15+ (Sequoia)**. No third-party dependencies.

## Build Commands

```bash
# Build both targets (main app + extension)
xcodebuild build -project OpenRightClick.xcodeproj -scheme OpenRightClick

# Build for specific configuration
xcodebuild build -project OpenRightClick.xcodeproj -scheme OpenRightClick -configuration Debug
xcodebuild build -project OpenRightClick.xcodeproj -scheme OpenRightClick -configuration Release

# Clean build
xcodebuild clean build -project OpenRightClick.xcodeproj -scheme OpenRightClick
```

**Note:** The `project.pbxproj` is gitignored. The project must be opened in Xcode to
regenerate it if missing. There is no `Package.swift`, no CocoaPods, and no Carthage.

## Tests

No test targets exist yet. The project plans to use **XCTest** with per-target unit tests
and integration tests. When tests are added:

```bash
# Run all tests
xcodebuild test -project OpenRightClick.xcodeproj -scheme OpenRightClick -destination 'platform=macOS'

# Run a single test class
xcodebuild test -project OpenRightClick.xcodeproj -scheme OpenRightClick \
  -destination 'platform=macOS' -only-testing:'OpenRightClickTests/TestClassName'

# Run a single test method
xcodebuild test -project OpenRightClick.xcodeproj -scheme OpenRightClick \
  -destination 'platform=macOS' -only-testing:'OpenRightClickTests/TestClassName/testMethodName'
```

## Linting / Formatting

No linting or formatting tools are currently configured. If SwiftLint is added:

```bash
swiftlint lint
swiftlint lint --fix
```

## Project Structure

```
OpenRightClick/                      # Main App target (SwiftUI settings panel)
  OpenRightClickApp.swift            # @main entry point
  ContentView.swift                  # Settings UI (SwiftUI Form)
  Models/AppSettings.swift           # Shared constants (suite name, UserDefaults keys)
  Services/SettingsService.swift     # ObservableObject for persisted settings

OpenRightClickExtension/             # Finder Sync Extension target
  FinderSync.swift                   # FIFinderSync subclass — all menu + action logic
  SharedSettings.swift               # Duplicated AppSettings constants
  OfficeTemplateGenerator.swift      # Base64-embedded minimal .docx/.xlsx/.pptx generator
  Info.plist                         # Extension configuration
```

**Two targets share state** via App Groups UserDefaults (`group.com.achui.OpenRightClick`).
`AppSettings` is duplicated in both targets (not a shared framework) — keep them in sync.

## Code Style Guidelines

### Imports

- One import per line, system/Apple frameworks only
- No sub-module imports; import the top-level framework
- Order: Foundation/Cocoa first, then domain frameworks (FinderSync, UniformTypeIdentifiers, etc.)

```swift
import SwiftUI
import FinderSync
import UniformTypeIdentifiers
```

### File Headers

Every file starts with the standard Xcode 4-line header:

```swift
//
//  FileName.swift
//  TargetName
//
```

No license headers, author names, or date stamps.

### Naming Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| Types (struct, class, enum, protocol) | PascalCase | `AppSettings`, `SettingsService`, `FinderSync` |
| Properties, variables, methods | camelCase | `externalAppPath`, `openWithExternalApp()` |
| Static constants | camelCase in `static let` | `AppSettings.suiteName` |
| Enum cases | camelCase | `TemplateError.invalidBase64` |
| Nested namespaces | PascalCase enum | `AppSettings.Keys` |

### Type Patterns

- **Structs** for value types and data models (`AppSettings`, `ContentView`)
- **Classes** for reference-semantic services (`SettingsService: ObservableObject`, `FinderSync: FIFinderSync`)
- **Caseless enums** as namespaces for static utility methods (`OfficeTemplateGenerator`)
- Prefer `guard let` / `if let` for optional unwrapping over force-unwrapping
- All types use Swift default `internal` access — no explicit `public`/`internal` modifiers

### SwiftUI Patterns

- `@StateObject` at app level, `@EnvironmentObject` in child views
- `Form` with `Section` for settings layout, `.formStyle(.grouped)`
- `.environmentObject()` for dependency injection from App to views

### Error Handling

- Use `do`/`catch` blocks; log errors with `NSLog`
- All log messages use prefix `"OpenRightClick: "` for filtering
- Use `NSLog` with Objective-C format strings: `NSLog("OpenRightClick: %@ - %@", context, message)`
- Custom errors conform to `Error` and `LocalizedError`
- No user-facing error alerts currently; errors are logged only

```swift
do {
    try FileManager.default.trashItem(at: url, resultingItemURL: nil)
    NSLog("OpenRightClick: trashed %@", url.path)
} catch {
    NSLog("OpenRightClick: failed to trash %@: %@", url.path, error.localizedDescription)
}
```

### Code Organization

- Use `// MARK: -` sections to organize code within files (`// MARK: - Menu`, `// MARK: - Actions`)
- Minimal doc comments — use `///` only for non-obvious public API or complex utilities
- `@objc` for Objective-C selector-based Finder Sync action handlers
- `override` for FIFinderSync protocol methods
- `private static` for internal constants (e.g., base64 template data)

### Property Patterns

- `@Published` properties with `didSet` observers for auto-persisting to UserDefaults:

```swift
@Published var externalAppPath: String? {
    didSet { defaults?.set(externalAppPath, forKey: AppSettings.Keys.externalAppPath) }
}
```

- Computed properties for derived values (no stored duplication)

### Commit Messages

Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, etc.

## Architecture Notes

- **App Sandbox** enabled on both targets
- Extension has `temporary-exception.files.absolute-path.read-write` for `/` (full filesystem access)
- Finder Sync Extension monitors all volumes: `directoryURLs = [URL(fileURLWithPath: "/")]`
- Office files (.docx/.xlsx/.pptx) are generated from base64-embedded ZIP data (no Process/NSTask — forbidden in sandbox)
- File naming collision avoidance: `Untitled.ext` -> `Untitled 2.ext` -> `Untitled 3.ext`
- Delete uses `FileManager.trashItem` (Trash, not permanent delete)
- Hide/unhide uses `URLResourceValues.isHidden`

## Copilot Instructions

This repository includes `.github/copilot-instructions.md` which defines an **AI-DLC
(AI Development Lifecycle)** workflow with Inception, Construction, and Operations phases.
That file governs multi-phase software development workflows for GitHub Copilot and
is not project-specific coding guidance. Refer to it when performing structured,
multi-stage development work through the AI-DLC framework.

## Key Gotchas

1. **`project.pbxproj` is gitignored** — Xcode project config is not in version control
2. **`AppSettings` is duplicated** in both targets — changes must be mirrored manually
3. **CI workflow (`.github/workflows/ci.yml`) is misconfigured** — it runs Python/pytest instead of xcodebuild
4. **No confirmation dialogs** exist for destructive actions (Delete, Hide) despite the design doc specifying them
5. **`aidlc-docs/` is gitignored** — AI-DLC documentation is local-only
