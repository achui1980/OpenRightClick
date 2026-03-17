//
//  AppSettings.swift
//  OpenRightClick
//

import Foundation

struct AppSettings {
    static let suiteName = "group.com.achui.OpenRightClick"
    
    enum Keys {
        static let externalAppPath = "externalAppPath"
        static let quickAccessDownloads = "quickAccessDownloads"
        static let quickAccessDesktop = "quickAccessDesktop"
        static let quickAccessDocuments = "quickAccessDocuments"

        // Menu section visibility
        static let showOpenWith = "showOpenWith"
        static let showCopyPath = "showCopyPath"
        static let showDestructive = "showDestructive"
        static let showCreateFile = "showCreateFile"
        static let showQuickAccess = "showQuickAccess"

        // Custom Quick Access folders (replaces the three individual bool keys)
        static let customFolders = "customFolders"

        // Create New File type visibility
        static let showFileTxt = "showFileTxt"
        static let showFileJson = "showFileJson"
        static let showFileMd = "showFileMd"
        static let showFileDocx = "showFileDocx"
        static let showFilePptx = "showFilePptx"
        static let showFileXlsx = "showFileXlsx"
        static let customFileExtensions = "customFileExtensions"
        static let customFileTypes = "customFileTypes"

        // Menu section ordering
        static let menuSectionOrder = "menuSectionOrder"

        // Multiple external apps (replaces the single externalAppPath key)
        static let externalApps = "externalApps"
    }
}
