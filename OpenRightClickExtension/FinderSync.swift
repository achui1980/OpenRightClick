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
        
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              !items.isEmpty else {
            return menu
        }
        
        // Open with External App
        if let appPath = defaults?.string(forKey: AppSettings.Keys.externalAppPath),
           !appPath.isEmpty {
            let appName = URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent
            let openItem = NSMenuItem(title: "Open with \(appName)", action: #selector(openWithExternalApp(_:)), keyEquivalent: "")
            openItem.image = NSImage(systemSymbolName: "arrow.up.forward.app", accessibilityDescription: nil)
            menu.addItem(openItem)
        }
        
        // Copy Path
        let copyItem = NSMenuItem(title: "Copy Path", action: #selector(copyPath(_:)), keyEquivalent: "")
        copyItem.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
        menu.addItem(copyItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Delete
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteItems(_:)), keyEquivalent: "")
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
        menu.addItem(deleteItem)
        
        // Hide/Unhide
        let isHidden = (try? items.first?.resourceValues(forKeys: [.isHiddenKey]).isHidden) ?? false
        let hideTitle = isHidden ? "Unhide" : "Hide"
        let hideItem = NSMenuItem(title: hideTitle, action: #selector(toggleHidden(_:)), keyEquivalent: "")
        hideItem.image = NSImage(systemSymbolName: isHidden ? "eye" : "eye.slash", accessibilityDescription: nil)
        menu.addItem(hideItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Create New File submenu
        let createMenu = NSMenu(title: "Create New File")
        let fileTypes: [(String, String)] = [
            ("Plain Text (.txt)", "txt"),
            ("JSON (.json)", "json"),
            ("Markdown (.md)", "md"),
            ("Word Document (.docx)", "docx"),
            ("PowerPoint (.pptx)", "pptx"),
            ("Excel Spreadsheet (.xlsx)", "xlsx"),
        ]
        for (title, ext) in fileTypes {
            let item = NSMenuItem(title: title, action: #selector(createNewFile(_:)), keyEquivalent: "")
            item.representedObject = ext
            createMenu.addItem(item)
        }
        let createItem = NSMenuItem(title: "Create New File", action: nil, keyEquivalent: "")
        createItem.submenu = createMenu
        createItem.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: nil)
        menu.addItem(createItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quick Access submenu
        let quickMenu = NSMenu(title: "Quick Access")
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDownloads) as? Bool ?? true {
            let item = NSMenuItem(title: "Downloads", action: #selector(openQuickAccess(_:)), keyEquivalent: "")
            item.representedObject = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            item.image = NSImage(systemSymbolName: "arrow.down.circle", accessibilityDescription: nil)
            quickMenu.addItem(item)
        }
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDesktop) as? Bool ?? true {
            let item = NSMenuItem(title: "Desktop", action: #selector(openQuickAccess(_:)), keyEquivalent: "")
            item.representedObject = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            item.image = NSImage(systemSymbolName: "menubar.dock.rectangle", accessibilityDescription: nil)
            quickMenu.addItem(item)
        }
        if defaults?.object(forKey: AppSettings.Keys.quickAccessDocuments) as? Bool ?? true {
            let item = NSMenuItem(title: "Documents", action: #selector(openQuickAccess(_:)), keyEquivalent: "")
            item.representedObject = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            item.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
            quickMenu.addItem(item)
        }
        if quickMenu.items.count > 0 {
            let quickItem = NSMenuItem(title: "Quick Access", action: nil, keyEquivalent: "")
            quickItem.submenu = quickMenu
            quickItem.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: nil)
            menu.addItem(quickItem)
        }
        
        return menu
    }
    
    // MARK: - Actions
    
    @objc func openWithExternalApp(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              let appPath = defaults?.string(forKey: AppSettings.Keys.externalAppPath) else {
            NSLog("OpenRightClick: openWithExternalApp - missing items or appPath")
            return
        }
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
        guard let ext = sender.representedObject as? String else {
            NSLog("OpenRightClick: createNewFile - no extension in representedObject")
            return
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
        guard let url = sender.representedObject as? URL else {
            NSLog("OpenRightClick: openQuickAccess - no URL in representedObject")
            return
        }
        NSLog("OpenRightClick: openQuickAccess - opening %@", url.path)
        NSWorkspace.shared.open(url)
    }
}
