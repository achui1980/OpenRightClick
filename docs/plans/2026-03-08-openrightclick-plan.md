# OpenRightClick Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS Finder context menu extension with 6 features: Open with External App, Copy Path, Delete, Hide, Create New Files, Quick Access Folders.

**Architecture:** SwiftUI main app (settings panel) + Finder Sync Extension. Shared config via App Groups UserDefaults. Two Xcode targets.

**Tech Stack:** Swift 5, SwiftUI, macOS 15+, FIFinderSyncProtocol, App Groups, NSWorkspace, NSFileManager

---

### Task 1: Create Shared Settings Infrastructure

**Files:**
- Create: `OpenRightClick/Models/AppSettings.swift`
- Create: `OpenRightClick/Services/SettingsService.swift`

Create `AppSettings` struct with constants for the App Group suite name and UserDefaults keys (externalAppPath, quickAccessDownloads, quickAccessDesktop, quickAccessDocuments).

Create `SettingsService` as an `ObservableObject` that reads/writes these values from `UserDefaults(suiteName: "group.com.achui.OpenRightClick")`. Use `@Published` properties with `didSet` to auto-persist.

**Commit:** `feat: add shared settings model and service with App Groups support`

---

### Task 2: Build Main App Settings UI

**Files:**
- Modify: `OpenRightClick/ContentView.swift`
- Modify: `OpenRightClick/OpenRightClickApp.swift`

Replace the default "Hello World" ContentView with a SwiftUI Form containing:
- Extension Status section: green/red circle + status text + "Open System Settings" button using `FIFinderSyncController.showExtensionManagementInterface()`
- External App section: display path + Browse button (NSOpenPanel with `.application` UTType) + Clear button
- Quick Access Folders section: Toggle for Downloads, Desktop, Documents
- About section: version text

Update OpenRightClickApp to create `@StateObject` SettingsService and inject via `.environmentObject()`. Add `.windowResizability(.contentSize)`.

**Commit:** `feat: build main app settings panel`

---

### Task 3: Create Entitlements for Main App

**Files:**
- Create: `OpenRightClick/OpenRightClick.entitlements`
- Modify: `OpenRightClick.xcodeproj/project.pbxproj` (add CODE_SIGN_ENTITLEMENTS)

Create entitlements plist with:
- `com.apple.security.app-sandbox` = true
- `com.apple.security.files.user-selected.read-write` = true
- `com.apple.security.application-groups` = ["group.com.achui.OpenRightClick"]

Update pbxproj to add `CODE_SIGN_ENTITLEMENTS = OpenRightClick/OpenRightClick.entitlements;` to both Debug and Release build settings for the main app target.

**Commit:** `feat: add App Sandbox and App Groups entitlements for main app`

---

### Task 4: Create Finder Sync Extension Source Files

**Files:**
- Create: `OpenRightClickExtension/FinderSync.swift` - Main FIFinderSync subclass with menu building and all 6 action handlers
- Create: `OpenRightClickExtension/SharedSettings.swift` - Duplicated AppSettings constants for extension target
- Create: `OpenRightClickExtension/Info.plist` - NSExtension config with FinderSync point identifier
- Create: `OpenRightClickExtension/OpenRightClickExtension.entitlements` - Sandbox + file access + App Groups

FinderSync.swift should:
- Set `directoryURLs = [URL(fileURLWithPath: "/")]` in init
- Build NSMenu in `menu(for:)` with all items, submenus, SF Symbols icons
- Implement action handlers: openWithExternalApp, copyPath, deleteItems, toggleHidden, createNewFile, openQuickAccess
- Read settings from shared UserDefaults
- Handle file naming collisions (Untitled, Untitled 2, etc.)
- Create .txt/.json/.md with minimal content, .docx/.pptx/.xlsx with minimal valid ZIP content

Extension entitlements need temporary exception for absolute path read-write since extension operates on arbitrary Finder-selected files.

**Commit:** `feat: create Finder Sync extension with all 6 context menu features`

---

### Task 5: Create Minimal Office Document Generator

**Files:**
- Create: `OpenRightClickExtension/OfficeTemplateGenerator.swift`

Create an enum `OfficeTemplateGenerator` with static methods to generate minimal valid .docx, .pptx, .xlsx files. These are ZIP-based Office Open XML formats. Each method should:
- Create the minimum required directory structure and XML files in a temp directory
- Use Foundation to create a ZIP archive from that structure
- Write the ZIP archive with the correct extension to the target URL

Minimum required files for each format:
- **docx:** `[Content_Types].xml`, `_rels/.rels`, `word/document.xml`, `word/_rels/document.xml.rels`
- **pptx:** `[Content_Types].xml`, `_rels/.rels`, `ppt/presentation.xml`, `ppt/_rels/presentation.xml.rels`, `ppt/slides/slide1.xml`, `ppt/slides/_rels/slide1.xml.rels`, `ppt/slideLayouts/slideLayout1.xml`, `ppt/slideMasters/slideMaster1.xml`
- **xlsx:** `[Content_Types].xml`, `_rels/.rels`, `xl/workbook.xml`, `xl/_rels/workbook.xml.rels`, `xl/worksheets/sheet1.xml`

**Commit:** `feat: add minimal Office document template generator`

---

### Task 6: Add Finder Sync Extension Target to Xcode Project

**Files:**
- Modify: `OpenRightClick.xcodeproj/project.pbxproj`

This is a complex pbxproj edit. Add:
1. `PBXFileReference` for `OpenRightClickExtension.appex`
2. `PBXFileSystemSynchronizedRootGroup` for `OpenRightClickExtension/` directory
3. `PBXNativeTarget` for `OpenRightClickExtension` with product type `com.apple.product-type.app-extension`
4. Build configurations (Debug/Release) with:
   - `PRODUCT_BUNDLE_IDENTIFIER = com.achui.OpenRightClick.Extension`
   - `CODE_SIGN_ENTITLEMENTS = OpenRightClickExtension/OpenRightClickExtension.entitlements`
   - `INFOPLIST_FILE = OpenRightClickExtension/Info.plist`
   - `SKIP_INSTALL = YES`
   - `GENERATE_INFOPLIST_FILE = YES`
   - `SWIFT_VERSION = 5.0`
   - Proper `LD_RUNPATH_SEARCH_PATHS` for extension
5. `PBXContainerItemProxy` and `PBXTargetDependency` from main app to extension
6. `PBXCopyFilesBuildPhase` in main app to embed extension in `PlugIns` (dstSubfolderSpec = 13)
7. Add extension target to project targets list
8. Add extension file group to main group children
9. `PBXBuildFile` for embedding the .appex in the copy phase

**Commit:** `feat: add Finder Sync Extension target to Xcode project`

---

### Task 7: Build and Verify

Run `xcodebuild build` and fix any compilation errors. Ensure:
- Both targets compile
- Extension is embedded in app bundle
- Entitlements are applied correctly

**Commit:** `fix: resolve any build errors` (if needed)
