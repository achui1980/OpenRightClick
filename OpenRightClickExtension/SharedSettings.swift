//
//  SharedSettings.swift
//  OpenRightClickExtension
//

import Foundation

struct AppSettings {
    static let suiteName = "group.com.achui.OpenRightClick"
    
    enum Keys {
        static let externalAppPath = "externalAppPath"
        static let quickAccessDownloads = "quickAccessDownloads"
        static let quickAccessDesktop = "quickAccessDesktop"
        static let quickAccessDocuments = "quickAccessDocuments"
    }
}
