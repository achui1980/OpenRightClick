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
              let appPath = defaults?.string(forKey: AppSettings.Keys.externalAppPath) else { return }
        let appURL = URL(fileURLWithPath: appPath)
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open(items, withApplicationAt: appURL, configuration: config)
    }
    
    @objc func copyPath(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else { return }
        let paths = items.map { $0.path }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
    }
    
    @objc func deleteItems(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else { return }
        
        let alert = NSAlert()
        alert.messageText = "Move to Trash?"
        let count = items.count
        if count == 1 {
            alert.informativeText = "Are you sure you want to move \"\(items[0].lastPathComponent)\" to the Trash?"
        } else {
            alert.informativeText = "Are you sure you want to move \(count) items to the Trash?"
        }
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Move to Trash")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            for url in items {
                try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
        }
    }
    
    @objc func toggleHidden(_ sender: NSMenuItem) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else { return }
        for item in items {
            var url = item
            let isHidden = (try? url.resourceValues(forKeys: [.isHiddenKey]).isHidden) ?? false
            var values = URLResourceValues()
            values.isHidden = !isHidden
            try? url.setResourceValues(values)
        }
    }
    
    @objc func createNewFile(_ sender: NSMenuItem) {
        guard let ext = sender.representedObject as? String,
              let target = FIFinderSyncController.default().targetedURL() else { return }
        
        let baseName = "Untitled"
        var fileURL = target.appendingPathComponent("\(baseName).\(ext)")
        
        // Avoid overwriting existing files
        var counter = 2
        while FileManager.default.fileExists(atPath: fileURL.path) {
            fileURL = target.appendingPathComponent("\(baseName) \(counter).\(ext)")
            counter += 1
        }
        
        switch ext {
        case "txt":
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        case "json":
            FileManager.default.createFile(atPath: fileURL.path, contents: "{}\n".data(using: .utf8))
        case "md":
            FileManager.default.createFile(atPath: fileURL.path, contents: "# Untitled\n".data(using: .utf8))
        case "docx":
            try? OfficeTemplateGenerator.createMinimalDocx(at: fileURL)
        case "pptx":
            try? OfficeTemplateGenerator.createMinimalPptx(at: fileURL)
        case "xlsx":
            try? OfficeTemplateGenerator.createMinimalXlsx(at: fileURL)
        default:
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
    }
    
    @objc func openQuickAccess(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? URL else { return }
        NSWorkspace.shared.open(url)
    }
}
