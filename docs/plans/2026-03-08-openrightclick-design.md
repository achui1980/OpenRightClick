# OpenRightClick Design Document

**Date:** 2026-03-08
**Status:** Approved

## Overview

OpenRightClick is a macOS Finder context menu extension app with 6 features:
1. Open with External App (single configured app)
2. Copy File/Folder Path
3. Delete Files or Directories (with confirmation)
4. Hide/Unhide Files and Dirs
5. Create New Files (.txt, .json, .md, .docx, .pptx, .xlsx)
6. Quick Access Folders (Downloads, Desktop, Documents)

## Architecture

- **Approach:** Finder Sync Extension (FIFinderSyncProtocol)
- **Targets:** Main App (SwiftUI settings) + Finder Sync Extension
- **Platform:** macOS 15+ (Sequoia), Swift 5, SwiftUI
- **Shared State:** App Groups UserDefaults (`group.com.achui.OpenRightClick`)
- **No separate framework** -- scope is small enough for duplicated constants

## Project Structure

```
OpenRightClick/                          # Main App target (SwiftUI)
├── OpenRightClickApp.swift
├── Views/
│   └── ContentView.swift
├── Models/
│   └── AppSettings.swift
├── Services/
│   └── SettingsService.swift
├── Assets.xcassets
└── OpenRightClick.entitlements

OpenRightClickExtension/                 # Finder Sync Extension target
├── FinderSync.swift
├── SharedSettings.swift
├── Actions/
│   ├── OpenWithAppAction.swift
│   ├── CopyPathAction.swift
│   ├── DeleteAction.swift
│   ├── HideAction.swift
│   ├── CreateFileAction.swift
│   └── QuickAccessAction.swift
├── OfficeTemplateGenerator.swift
├── OpenRightClickExtension.entitlements
└── Info.plist
```

## Context Menu Structure

```
[Right-click in Finder]
└── OpenRightClick >
      ├── Open with [AppName]
      ├── Copy Path
      ├── ──────────
      ├── Delete
      ├── Hide / Unhide
      ├── ──────────
      ├── Create New File >
      │     ├── Plain Text (.txt)
      │     ├── JSON (.json)
      │     ├── Markdown (.md)
      │     ├── Word Document (.docx)
      │     ├── PowerPoint (.pptx)
      │     └── Excel Spreadsheet (.xlsx)
      ├── ──────────
      └── Quick Access >
            ├── Downloads
            ├── Desktop
            └── Documents
```

## Main App (Settings Panel)

Minimal SwiftUI settings window with:
- Extension Status indicator + "Open System Settings" button
- External App picker (NSOpenPanel for .app bundles)
- Quick Access Folders toggles
- About section

## Key Decisions

- Single configured external app (not multiple)
- App Groups UserDefaults for config sharing (no XPC needed)
- Minimal Office files generated programmatically (no bundled templates)
- Extension monitors all volumes (`/`) via FIFinderSyncController
- Delete uses `trashItem` with NSAlert confirmation
- Hide uses `URLResourceValues.isHidden`
