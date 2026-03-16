//
//  ContentView.swift
//  OpenRightClick
//

import SwiftUI
import FinderSync
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var settings: SettingsService
    @State private var newExtension = ""

    private static func sectionLabel(for id: String) -> String {
        switch id {
        case "openWith":    return "Open With"
        case "copy":        return "Copy Path"
        case "destructive": return "Delete / Hide"
        case "createFile":  return "Create New File"
        case "quickAccess": return "Quick Access"
        default:            return id
        }
    }

    private static func sectionIcon(for id: String) -> String {
        switch id {
        case "openWith":    return "arrow.up.forward.app"
        case "copy":        return "doc.on.clipboard"
        case "destructive": return "trash"
        case "createFile":  return "doc.badge.plus"
        case "quickAccess": return "folder.badge.gearshape"
        default:            return "square.grid.2x2"
        }
    }

    private func addCustomExtension() {
        let clean = newExtension
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: ".", with: "")
        guard !clean.isEmpty, !settings.customFileExtensions.contains(clean) else { return }
        settings.customFileExtensions = settings.customFileExtensions + [clean]
        newExtension = ""
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

            Section("External Apps") {
                ForEach(settings.externalApps, id: \.self) { appPath in
                    HStack {
                        Label(URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent,
                              systemImage: "app")
                        Spacer()
                        Text(appPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: 200)
                        Button {
                            settings.externalApps = settings.externalApps.filter { $0 != appPath }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button("Add App...") {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [UTType.application]
                    panel.allowsMultipleSelection = false
                    panel.directoryURL = URL(fileURLWithPath: "/Applications")
                    if panel.runModal() == .OK, let url = panel.url {
                        guard !settings.externalApps.contains(url.path) else { return }
                        settings.externalApps = settings.externalApps + [url.path]
                    }
                }
            }

            Section("Quick Access Folders") {
                ForEach($settings.customFolders) { $folder in
                    HStack {
                        Image(systemName: "folder")
                            .foregroundStyle(.secondary)
                        TextField("Display name", text: $folder.displayName)
                        Spacer()
                        Text(folder.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: 160)
                        Button {
                            settings.customFolders = settings.customFolders.filter { $0.id != folder.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button("Add Folder...") {
                    let panel = NSOpenPanel()
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url {
                        let name = url.lastPathComponent
                        settings.customFolders = settings.customFolders + [CustomFolder(path: url.path, displayName: name)]
                    }
                }
            }

            Section("Create New File") {
                Toggle("Plain Text (.txt)", isOn: $settings.showFileTxt)
                Toggle("JSON (.json)", isOn: $settings.showFileJson)
                Toggle("Markdown (.md)", isOn: $settings.showFileMd)
                Toggle("Word Document (.docx)", isOn: $settings.showFileDocx)
                Toggle("PowerPoint (.pptx)", isOn: $settings.showFilePptx)
                Toggle("Excel Spreadsheet (.xlsx)", isOn: $settings.showFileXlsx)
                if !settings.customFileExtensions.isEmpty {
                    ForEach(settings.customFileExtensions, id: \.self) { ext in
                        HStack {
                            Text(".\(ext)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                settings.customFileExtensions = settings.customFileExtensions.filter { $0 != ext }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                HStack {
                    TextField("Add extension (e.g. swift)", text: $newExtension)
                        .onSubmit { addCustomExtension() }
                    Button("Add") { addCustomExtension() }
                        .disabled(newExtension.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section("Menu Sections") {
                Toggle("Open With", isOn: $settings.showOpenWith)
                Toggle("Copy Path", isOn: $settings.showCopyPath)
                Toggle("Delete / Hide", isOn: $settings.showDestructive)
                Toggle("Create New File", isOn: $settings.showCreateFile)
                Toggle("Quick Access", isOn: $settings.showQuickAccess)
            }

            Section(header: Text("Menu Order"), footer: Text("Use the arrows to reorder sections in the right-click menu.")) {
                ForEach(Array(settings.menuSectionOrder.enumerated()), id: \.element) { index, sectionId in
                    HStack {
                        Label(Self.sectionLabel(for: sectionId), systemImage: Self.sectionIcon(for: sectionId))
                        Spacer()
                        Button {
                            guard index > 0 else { return }
                            var order = settings.menuSectionOrder
                            order.swapAt(index, index - 1)
                            settings.menuSectionOrder = order
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .buttonStyle(.plain)
                        .disabled(index == 0)
                        Button {
                            guard index < settings.menuSectionOrder.count - 1 else { return }
                            var order = settings.menuSectionOrder
                            order.swapAt(index, index + 1)
                            settings.menuSectionOrder = order
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .buttonStyle(.plain)
                        .disabled(index == settings.menuSectionOrder.count - 1)
                    }
                }
            }

            Section("About") {
                Text("OpenRightClick v1.0")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 450, minHeight: 480)
    }
}
