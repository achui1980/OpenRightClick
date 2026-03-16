//
//  SettingsService.swift
//  OpenRightClick
//

import Foundation
import Combine

struct CustomFolder: Codable, Identifiable {
    var id: UUID
    var path: String
    var displayName: String

    init(id: UUID = UUID(), path: String, displayName: String) {
        self.id = id
        self.path = path
        self.displayName = displayName
    }
}

class SettingsService: ObservableObject {
    private let defaults: UserDefaults?

    @Published var externalApps: [String] {
        didSet { defaults?.set(externalApps, forKey: AppSettings.Keys.externalApps) }
    }
    @Published var customFolders: [CustomFolder] {
        didSet { saveFolders() }
    }
    @Published var showOpenWith: Bool {
        didSet { defaults?.set(showOpenWith, forKey: AppSettings.Keys.showOpenWith) }
    }
    @Published var showCopyPath: Bool {
        didSet { defaults?.set(showCopyPath, forKey: AppSettings.Keys.showCopyPath) }
    }
    @Published var showDestructive: Bool {
        didSet { defaults?.set(showDestructive, forKey: AppSettings.Keys.showDestructive) }
    }
    @Published var showCreateFile: Bool {
        didSet { defaults?.set(showCreateFile, forKey: AppSettings.Keys.showCreateFile) }
    }
    @Published var showQuickAccess: Bool {
        didSet { defaults?.set(showQuickAccess, forKey: AppSettings.Keys.showQuickAccess) }
    }
    @Published var showFileTxt: Bool {
        didSet { defaults?.set(showFileTxt, forKey: AppSettings.Keys.showFileTxt) }
    }
    @Published var showFileJson: Bool {
        didSet { defaults?.set(showFileJson, forKey: AppSettings.Keys.showFileJson) }
    }
    @Published var showFileMd: Bool {
        didSet { defaults?.set(showFileMd, forKey: AppSettings.Keys.showFileMd) }
    }
    @Published var showFileDocx: Bool {
        didSet { defaults?.set(showFileDocx, forKey: AppSettings.Keys.showFileDocx) }
    }
    @Published var showFilePptx: Bool {
        didSet { defaults?.set(showFilePptx, forKey: AppSettings.Keys.showFilePptx) }
    }
    @Published var showFileXlsx: Bool {
        didSet { defaults?.set(showFileXlsx, forKey: AppSettings.Keys.showFileXlsx) }
    }
    @Published var customFileExtensions: [String] {
        didSet {
            defaults?.set(customFileExtensions, forKey: AppSettings.Keys.customFileExtensions)
        }
    }
    @Published var menuSectionOrder: [String] {
        didSet { defaults?.set(menuSectionOrder, forKey: AppSettings.Keys.menuSectionOrder) }
    }

    init() {
        self.defaults = UserDefaults(suiteName: AppSettings.suiteName)
        self.externalApps = Self.loadOrMigrateApps(from: defaults)
        self.showOpenWith = defaults?.object(forKey: AppSettings.Keys.showOpenWith) as? Bool ?? true
        self.showCopyPath = defaults?.object(forKey: AppSettings.Keys.showCopyPath) as? Bool ?? true
        self.showDestructive = defaults?.object(forKey: AppSettings.Keys.showDestructive) as? Bool ?? true
        self.showCreateFile = defaults?.object(forKey: AppSettings.Keys.showCreateFile) as? Bool ?? true
        self.showQuickAccess = defaults?.object(forKey: AppSettings.Keys.showQuickAccess) as? Bool ?? true
        self.showFileTxt = defaults?.object(forKey: AppSettings.Keys.showFileTxt) as? Bool ?? true
        self.showFileJson = defaults?.object(forKey: AppSettings.Keys.showFileJson) as? Bool ?? true
        self.showFileMd = defaults?.object(forKey: AppSettings.Keys.showFileMd) as? Bool ?? true
        self.showFileDocx = defaults?.object(forKey: AppSettings.Keys.showFileDocx) as? Bool ?? true
        self.showFilePptx = defaults?.object(forKey: AppSettings.Keys.showFilePptx) as? Bool ?? true
        self.showFileXlsx = defaults?.object(forKey: AppSettings.Keys.showFileXlsx) as? Bool ?? true
        self.customFileExtensions = defaults?.stringArray(forKey: AppSettings.Keys.customFileExtensions) ?? []
        self.menuSectionOrder = defaults?.stringArray(forKey: AppSettings.Keys.menuSectionOrder)
            ?? ["openWith", "copy", "destructive", "createFile", "quickAccess"]
        self.customFolders = Self.loadOrMigrateFolders(from: defaults)
    }

    // MARK: - Persistence

    private func saveFolders() {
        guard let data = try? JSONEncoder().encode(customFolders) else { return }
        defaults?.set(data, forKey: AppSettings.Keys.customFolders)
    }

    /// Loads customFolders from UserDefaults. On first launch (no customFolders key),
    /// migrates the old quickAccessDownloads/Desktop/Documents booleans.
    private static func loadOrMigrateFolders(from defaults: UserDefaults?) -> [CustomFolder] {
        if let data = defaults?.data(forKey: AppSettings.Keys.customFolders),
           let folders = try? JSONDecoder().decode([CustomFolder].self, from: data) {
            return folders
        }
        // Migration: convert legacy bool keys to CustomFolder entries
        var migrated: [CustomFolder] = []
        let fm = FileManager.default
        let showDownloads = defaults?.object(forKey: AppSettings.Keys.quickAccessDownloads) as? Bool ?? true
        let showDesktop   = defaults?.object(forKey: AppSettings.Keys.quickAccessDesktop)   as? Bool ?? true
        let showDocuments = defaults?.object(forKey: AppSettings.Keys.quickAccessDocuments) as? Bool ?? true
        if showDownloads, let url = fm.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            migrated.append(CustomFolder(path: url.path, displayName: "Downloads"))
        }
        if showDesktop, let url = fm.urls(for: .desktopDirectory, in: .userDomainMask).first {
            migrated.append(CustomFolder(path: url.path, displayName: "Desktop"))
        }
        if showDocuments, let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            migrated.append(CustomFolder(path: url.path, displayName: "Documents"))
        }
        return migrated
    }

    /// Loads externalApps from UserDefaults. On first launch migrates the old externalAppPath string.
    private static func loadOrMigrateApps(from defaults: UserDefaults?) -> [String] {
        if let apps = defaults?.stringArray(forKey: AppSettings.Keys.externalApps) {
            return apps
        }
        if let legacy = defaults?.string(forKey: AppSettings.Keys.externalAppPath), !legacy.isEmpty {
            return [legacy]
        }
        return []
    }
}
