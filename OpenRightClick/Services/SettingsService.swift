//
//  SettingsService.swift
//  OpenRightClick
//

import Foundation
import Combine

class SettingsService: ObservableObject {
    private let defaults: UserDefaults?
    
    @Published var externalAppPath: String? {
        didSet { defaults?.set(externalAppPath, forKey: AppSettings.Keys.externalAppPath) }
    }
    @Published var quickAccessDownloads: Bool {
        didSet { defaults?.set(quickAccessDownloads, forKey: AppSettings.Keys.quickAccessDownloads) }
    }
    @Published var quickAccessDesktop: Bool {
        didSet { defaults?.set(quickAccessDesktop, forKey: AppSettings.Keys.quickAccessDesktop) }
    }
    @Published var quickAccessDocuments: Bool {
        didSet { defaults?.set(quickAccessDocuments, forKey: AppSettings.Keys.quickAccessDocuments) }
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: AppSettings.suiteName)
        self.externalAppPath = defaults?.string(forKey: AppSettings.Keys.externalAppPath)
        self.quickAccessDownloads = defaults?.object(forKey: AppSettings.Keys.quickAccessDownloads) as? Bool ?? true
        self.quickAccessDesktop = defaults?.object(forKey: AppSettings.Keys.quickAccessDesktop) as? Bool ?? true
        self.quickAccessDocuments = defaults?.object(forKey: AppSettings.Keys.quickAccessDocuments) as? Bool ?? true
    }
}
