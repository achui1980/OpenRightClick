//
//  FinderSync.swift
//  OpenRightClickExtension
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    let defaults = UserDefaults(suiteName: AppSettings.suiteName)
    
    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    // MARK: - Menu

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "OpenRightClick")
        let selectedItems = FIFinderSyncController.default().selectedItemURLs() ?? []
        let sectionOrder = defaults?.stringArray(forKey: AppSettings.Keys.menuSectionOrder)
            ?? ["openWith", "copy", "destructive", "createFile", "quickAccess"]

        var needsSeparator = false
        for sectionId in sectionOrder {
            let added = buildSection(sectionId, into: menu, selectedItems: selectedItems, needsSeparator: needsSeparator)
            if added { needsSeparator = true }
        }
        return menu
    }

    /// Builds one menu section. Returns true if any items were added.
    @discardableResult
    private func buildSection(_ id: String, into menu: NSMenu, selectedItems: [URL], needsSeparator: Bool) -> Bool {
        switch id {
        case "openWith":    return buildOpenWith(into: menu, selectedItems: selectedItems, needsSeparator: needsSeparator)
        case "copy":        return buildCopy(into: menu, selectedItems: selectedItems, needsSeparator: needsSeparator)
        case "destructive": return buildDestructive(into: menu, selectedItems: selectedItems, needsSeparator: needsSeparator)
        case "createFile":  return buildCreateFile(into: menu, needsSeparator: needsSeparator)
        case "quickAccess": return buildQuickAccess(into: menu, needsSeparator: needsSeparator)
        default:            return false
        }
    }

    private func buildOpenWith(into menu: NSMenu, selectedItems: [URL], needsSeparator: Bool) -> Bool {
        guard defaults?.object(forKey: AppSettings.Keys.showOpenWith) as? Bool ?? true else { return false }
        guard !selectedItems.isEmpty else { return false }
        let apps = defaults?.stringArray(forKey: AppSettings.Keys.externalApps) ?? []
        // Fall back to legacy single-app key during migration window
        let legacyApps: [String]
        if apps.isEmpty, let legacy = defaults?.string(forKey: AppSettings.Keys.externalAppPath), !legacy.isEmpty {
            legacyApps = [legacy]
        } else {
            legacyApps = apps
        }
        guard !legacyApps.isEmpty else { return false }
        if needsSeparator { menu.addItem(NSMenuItem.separator()) }
        for (index, appPath) in legacyApps.enumerated() {
            let appName = URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent
            let item = NSMenuItem(title: "Open with \(appName)", action: #selector(openWithExternalApp(_:)), keyEquivalent: "")
            item.tag = 100 + index
            item.image = NSImage(systemSymbolName: "arrow.up.forward.app", accessibilityDescription: nil)
            menu.addItem(item)
        }
        return true
    }

    private func buildCopy(into menu: NSMenu, selectedItems: [URL], needsSeparator: Bool) -> Bool {
        guard defaults?.object(forKey: AppSettings.Keys.showCopyPath) as? Bool ?? true else { return false }
        guard !selectedItems.isEmpty else { return false }
        if needsSeparator { menu.addItem(NSMenuItem.separator()) }
        let item = NSMenuItem(title: "Copy Path", action: #selector(copyPath(_:)), keyEquivalent: "")
        item.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
        menu.addItem(item)
        return true
    }

    private func buildDestructive(into menu: NSMenu, selectedItems: [URL], needsSeparator: Bool) -> Bool {
        guard defaults?.object(forKey: AppSettings.Keys.showDestructive) as? Bool ?? true else { return false }
        guard !selectedItems.isEmpty else { return false }
        if needsSeparator { menu.addItem(NSMenuItem.separator()) }
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteItems(_:)), keyEquivalent: "")
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
        menu.addItem(deleteItem)
        let isHidden = (try? selectedItems.first?.resourceValues(forKeys: [.isHiddenKey]).isHidden) ?? false
        let hideItem = NSMenuItem(title: isHidden ? "Unhide" : "Hide", action: #selector(toggleHidden(_:)), keyEquivalent: "")
        hideItem.image = NSImage(systemSymbolName: isHidden ? "eye" : "eye.slash", accessibilityDescription: nil)
        menu.addItem(hideItem)
        return true
    }

    // NOTE: Finder Sync copies NSMenuItems and does NOT preserve representedObject.
    // Use tag (Int) to identify file types instead.
    // Tags 0-5: built-in types; tags 50+: custom extensions
    private func buildCreateFile(into menu: NSMenu, needsSeparator: Bool) -> Bool {
        guard defaults?.object(forKey: AppSettings.Keys.showCreateFile) as? Bool ?? true else { return false }
        let showTxt  = defaults?.object(forKey: AppSettings.Keys.showFileTxt)  as? Bool ?? true
        let showJson = defaults?.object(forKey: AppSettings.Keys.showFileJson) as? Bool ?? true
        let showMd   = defaults?.object(forKey: AppSettings.Keys.showFileMd)   as? Bool ?? true
        let showDocx = defaults?.object(forKey: AppSettings.Keys.showFileDocx) as? Bool ?? true
        let showPptx = defaults?.object(forKey: AppSettings.Keys.showFilePptx) as? Bool ?? true
        let showXlsx = defaults?.object(forKey: AppSettings.Keys.showFileXlsx) as? Bool ?? true
        let customExts = defaults?.stringArray(forKey: AppSettings.Keys.customFileExtensions) ?? []
        let builtIn: [(String, Int, Bool)] = [
            ("Plain Text (.txt)",         0, showTxt),
            ("JSON (.json)",              1, showJson),
            ("Markdown (.md)",            2, showMd),
            ("Word Document (.docx)",     3, showDocx),
            ("PowerPoint (.pptx)",        4, showPptx),
            ("Excel Spreadsheet (.xlsx)", 5, showXlsx),
        ]
        let createMenu = NSMenu(title: "Create New File")
        for (title, tag, visible) in builtIn where visible {
            let item = NSMenuItem(title: title, action: #selector(createNewFile(_:)), keyEquivalent: "")
            item.tag = tag
            createMenu.addItem(item)
        }
        for (index, ext) in customExts.enumerated() {
            let item = NSMenuItem(title: ".\(ext)", action: #selector(createNewFile(_:)), keyEquivalent: "")
            item.tag = 50 + index
            createMenu.addItem(item)
        }
        guard createMenu.items.count > 0 else { return false }
        if needsSeparator { menu.addItem(NSMenuItem.separator()) }
        let createItem = NSMenuItem(title: "Create New File", action: nil, keyEquivalent: "")
        createItem.submenu = createMenu
        createItem.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        menu.addItem(createItem)
        return true
    }

    // NOTE: Use tag instead of representedObject (not preserved by Finder Sync).
    // Tags: 20…(20+n-1) for custom folders
    private func buildQuickAccess(into menu: NSMenu, needsSeparator: Bool) -> Bool {
        guard defaults?.object(forKey: AppSettings.Keys.showQuickAccess) as? Bool ?? true else { return false }
        let folders = Self.loadCustomFolders(from: defaults)
        guard !folders.isEmpty else { return false }
        let quickMenu = NSMenu(title: "Quick Access")
        for (index, folder) in folders.enumerated() {
            let item = NSMenuItem(title: folder.displayName, action: #selector(openQuickAccess(_:)), keyEquivalent: "")
            item.tag = 20 + index
            item.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
            quickMenu.addItem(item)
        }
        if needsSeparator { menu.addItem(NSMenuItem.separator()) }
        let quickItem = NSMenuItem(title: "Quick Access", action: nil, keyEquivalent: "")
        quickItem.submenu = quickMenu
        quickItem.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: nil)
        menu.addItem(quickItem)
        return true
    }
    
    // MARK: - Actions
    
    @objc func openWithExternalApp(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("OpenRightClick: openWithExternalApp - no selected items")
            return
        }
        let apps = defaults?.stringArray(forKey: AppSettings.Keys.externalApps) ?? []
        let resolvedApps: [String]
        if apps.isEmpty, let legacy = defaults?.string(forKey: AppSettings.Keys.externalAppPath), !legacy.isEmpty {
            resolvedApps = [legacy]
        } else {
            resolvedApps = apps
        }
        let index = sender.tag - 100
        guard index >= 0, index < resolvedApps.count else {
            NSLog("OpenRightClick: openWithExternalApp - invalid tag %d", sender.tag)
            return
        }
        let appPath = resolvedApps[index]
        NSLog("OpenRightClick: openWithExternalApp - opening %d items with %@", items.count, appPath)
        let appURL = URL(fileURLWithPath: appPath)
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open(items, withApplicationAt: appURL, configuration: config)
    }
    
    @objc func copyPath(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("OpenRightClick: copyPath - no selected items")
            return
        }
        let paths = items.map { $0.path }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
        NSLog("OpenRightClick: copyPath - copied %d paths", items.count)
    }
    
    @objc func deleteItems(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("OpenRightClick: deleteItems - no selected items")
            return
        }
        NSLog("OpenRightClick: deleteItems - trashing %d items", items.count)
        for url in items {
            do {
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
                NSLog("OpenRightClick: trashed %@", url.path)
            } catch {
                NSLog("OpenRightClick: failed to trash %@: %@", url.path, error.localizedDescription)
            }
        }
    }
    
    @objc func toggleHidden(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("OpenRightClick: toggleHidden - no selected items")
            return
        }
        NSLog("OpenRightClick: toggleHidden - toggling %d items", items.count)
        for item in items {
            var url = item
            let isHidden = (try? url.resourceValues(forKeys: [.isHiddenKey]).isHidden) ?? false
            var values = URLResourceValues()
            values.isHidden = !isHidden
            do {
                try url.setResourceValues(values)
                NSLog("OpenRightClick: set hidden=%d for %@", !isHidden, url.path)
            } catch {
                NSLog("OpenRightClick: toggleHidden FAILED for %@: %@", url.path, error.localizedDescription)
            }
        }
    }
    
    @objc func createNewFile(_ sender: NSMenuItem) {
        let builtInExtensions = ["txt", "json", "md", "docx", "pptx", "xlsx"]
        let tag = sender.tag

        let ext: String
        if tag >= 50 {
            let customExts = defaults?.stringArray(forKey: AppSettings.Keys.customFileExtensions) ?? []
            let index = tag - 50
            guard index < customExts.count else {
                NSLog("OpenRightClick: createNewFile - invalid custom tag %d", tag)
                return
            }
            ext = customExts[index]
        } else {
            guard tag >= 0, tag < builtInExtensions.count else {
                NSLog("OpenRightClick: createNewFile - invalid tag %d", tag)
                return
            }
            ext = builtInExtensions[tag]
        }
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("OpenRightClick: createNewFile - no targetedURL")
            return
        }
        
        NSLog("OpenRightClick: createNewFile - ext=%@, target=%@", ext, target.path)
        
        let baseName = "Untitled"
        var fileURL = target.appendingPathComponent("\(baseName).\(ext)")
        
        // Avoid overwriting existing files
        var counter = 2
        while FileManager.default.fileExists(atPath: fileURL.path) {
            fileURL = target.appendingPathComponent("\(baseName) \(counter).\(ext)")
            counter += 1
        }
        
        NSLog("OpenRightClick: will create file at %@", fileURL.path)
        
        do {
            switch ext {
            case "txt":
                let success = FileManager.default.createFile(atPath: fileURL.path, contents: Data())
                NSLog("OpenRightClick: createFile txt result=%d", success)
            case "json":
                try "{}\n".data(using: .utf8)!.write(to: fileURL)
                NSLog("OpenRightClick: wrote json")
            case "md":
                try "# Untitled\n".data(using: .utf8)!.write(to: fileURL)
                NSLog("OpenRightClick: wrote md")
            case "docx":
                try OfficeTemplateGenerator.createMinimalDocx(at: fileURL)
                NSLog("OpenRightClick: wrote docx")
            case "pptx":
                try OfficeTemplateGenerator.createMinimalPptx(at: fileURL)
                NSLog("OpenRightClick: wrote pptx")
            case "xlsx":
                try OfficeTemplateGenerator.createMinimalXlsx(at: fileURL)
                NSLog("OpenRightClick: wrote xlsx")
            default:
                let success = FileManager.default.createFile(atPath: fileURL.path, contents: Data())
                NSLog("OpenRightClick: createFile default result=%d", success)
            }
        } catch {
            NSLog("OpenRightClick: createNewFile FAILED: %@", error.localizedDescription)
        }
    }
    
    @objc func openQuickAccess(_ sender: NSMenuItem) {
        let index = sender.tag - 20
        let folders = Self.loadCustomFolders(from: defaults)
        guard index >= 0, index < folders.count else {
            NSLog("OpenRightClick: openQuickAccess - invalid tag %d", sender.tag)
            return
        }
        let target = URL(fileURLWithPath: folders[index].path)
        NSLog("OpenRightClick: openQuickAccess - opening %@", target.path)
        NSWorkspace.shared.open(target)
    }

    // MARK: - Helpers

    private struct CustomFolderEntry: Codable {
        var id: String
        var path: String
        var displayName: String
    }

    private static func loadCustomFolders(from defaults: UserDefaults?) -> [(displayName: String, path: String)] {
        if let data = defaults?.data(forKey: AppSettings.Keys.customFolders),
           let entries = try? JSONDecoder().decode([CustomFolderEntry].self, from: data) {
            return entries.map { (displayName: $0.displayName, path: $0.path) }
        }
        // Fall back to legacy bool keys during migration window
        var result: [(String, String)] = []
        let fm = FileManager.default
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDownloads) as? Bool ?? true,
           let url = fm.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            result.append(("Downloads", url.path))
        }
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDesktop) as? Bool ?? true,
           let url = fm.urls(for: .desktopDirectory, in: .userDomainMask).first {
            result.append(("Desktop", url.path))
        }
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDocuments) as? Bool ?? true,
           let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            result.append(("Documents", url.path))
        }
        return result
    }
}
