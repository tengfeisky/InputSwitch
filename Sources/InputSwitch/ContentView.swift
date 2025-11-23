import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @ObservedObject var configManager = ConfigManager.shared
    @ObservedObject var appMonitor = AppMonitor.shared
    @State private var availableSources: [InputSource] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if configManager.configs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Apps Configured")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add an application to set its default input source.")
                            .foregroundColor(.secondary)
                        Button("Add App", action: selectApp)
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(configManager.configs.sorted(by: { $0.key < $1.key }), id: \.key) { bundleID, sourceID in
                            HStack(spacing: 12) {
                                if let icon = AppIconProvider.shared.icon(for: bundleID) {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                } else {
                                    Image(systemName: "app.dashed")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading) {
                                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                                        Text(FileManager.default.displayName(atPath: url.path))
                                            .font(.headline)
                                    } else {
                                        Text(bundleID)
                                            .font(.headline)
                                    }
                                    Text(bundleID)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Picker("", selection: Binding(
                                    get: { sourceID },
                                    set: { newValue in
                                        configManager.saveConfig(bundleID: bundleID, inputSourceID: newValue)
                                    }
                                )) {
                                    ForEach(availableSources) { source in
                                        HStack {
                                            Text(source.name)
                                            if let iconURL = source.iconURL, let icon = NSImage(contentsOf: iconURL) {
                                                Image(nsImage: icon)
                                            }
                                        }
                                        .tag(source.id)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 180)
                                
                                Button(action: {
                                    configManager.removeConfig(for: bundleID)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Input Switch")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: selectApp) {
                        Label("Add App", systemImage: "plus")
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            availableSources = InputSourceManager.shared.availableInputSources()
        }
    }
    
    func selectApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier {
                    DispatchQueue.main.async {
                        if configManager.getInputSourceID(for: bundleID) == nil {
                            // Default to current source or empty
                            let current = InputSourceManager.shared.currentInputSource()?.id ?? ""
                            configManager.saveConfig(bundleID: bundleID, inputSourceID: current)
                        }
                    }
                }
            }
        }
    }
}
