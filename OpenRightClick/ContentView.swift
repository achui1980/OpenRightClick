//
//  ContentView.swift
//  OpenRightClick
//

import SwiftUI
import FinderSync
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var settings: SettingsService
    
    private var appName: String? {
        guard let path = settings.externalAppPath else { return nil }
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }
    
    var body: some View {
        Form {
            Section("Extension Status") {
                HStack {
                    Circle()
                        .fill(FIFinderSyncController.isExtensionEnabled ? .green : .red)
                        .frame(width: 10, height: 10)
                    Text(FIFinderSyncController.isExtensionEnabled ? "Enabled" : "Not Enabled")
                    Spacer()
                    Button("Open System Settings") {
                        FIFinderSyncController.showExtensionManagementInterface()
                    }
                }
            }
            
            Section("External App") {
                HStack {
                    if let name = appName, let path = settings.externalAppPath {
                        Label(name, systemImage: "app")
                        Text(path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    } else {
                        Text("No app selected")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Browse...") {
                        let panel = NSOpenPanel()
                        panel.allowedContentTypes = [UTType.application]
                        panel.allowsMultipleSelection = false
                        panel.directoryURL = URL(fileURLWithPath: "/Applications")
                        if panel.runModal() == .OK, let url = panel.url {
                            settings.externalAppPath = url.path
                        }
                    }
                    if settings.externalAppPath != nil {
                        Button("Clear") {
                            settings.externalAppPath = nil
                        }
                    }
                }
            }
            
            Section("Quick Access Folders") {
                Toggle("Downloads", isOn: $settings.quickAccessDownloads)
                Toggle("Desktop", isOn: $settings.quickAccessDesktop)
                Toggle("Documents", isOn: $settings.quickAccessDocuments)
            }
            
            Section("About") {
                Text("OpenRightClick v1.0")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 450, minHeight: 320)
    }
}
