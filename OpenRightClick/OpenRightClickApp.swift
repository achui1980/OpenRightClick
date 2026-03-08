//
//  OpenRightClickApp.swift
//  OpenRightClick
//

import SwiftUI

@main
struct OpenRightClickApp: App {
    @StateObject private var settings = SettingsService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .windowResizability(.contentSize)
    }
}
