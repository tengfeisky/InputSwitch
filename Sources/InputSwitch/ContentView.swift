import SwiftUI
import UniformTypeIdentifiers
import AppKit
import Combine

// App config item with pre-cached name for filtering
struct AppConfigItem: Identifiable {
    let id: String // bundleID
    let sourceID: String
    let appName: String
    
    func matches(_ filter: String) -> Bool {
        if filter.isEmpty { return true }
        return appName.localizedCaseInsensitiveContains(filter) ||
               id.localizedCaseInsensitiveContains(filter)
    }
}

struct ContentView: View {
    @ObservedObject var configManager = ConfigManager.shared
    @ObservedObject var appMonitor = AppMonitor.shared
    @State private var availableSources: [InputSource] = []
    @State private var isLoading = true
    @State private var filterText = ""
    @State private var debouncedFilterText = ""
    @State private var configItems: [AppConfigItem] = []
    
    // Filtered config list - uses debounced text and pre-cached names
    private var filteredConfigs: [AppConfigItem] {
        if debouncedFilterText.isEmpty {
            return configItems
        }
        return configItems.filter { $0.matches(debouncedFilterText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if configManager.configs.isEmpty {
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
                        ForEach(filteredConfigs) { item in
                            AppConfigRow(
                                bundleID: item.id,
                                sourceID: item.sourceID,
                                appName: item.appName,
                                availableSources: availableSources,
                                configManager: configManager
                            )
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Input Switch")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    TextField("Filter apps...", text: $filterText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                        .frame(width: 150)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Menu {
                            Toggle("Show Toast", isOn: Binding(
                                get: { configManager.showToast },
                                set: { configManager.setShowToast($0) }
                            ))
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Button(action: selectApp) {
                            Label("Add App", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .task {
            await loadData()
        }
        .onChange(of: filterText) { _, newValue in
            // Debounce: delay 150ms before updating filter
            Task {
                try? await Task.sleep(nanoseconds: 150_000_000)
                if filterText == newValue {
                    debouncedFilterText = newValue
                }
            }
        }
        .onChange(of: configManager.configs) { _, _ in
            // Rebuild cached list when configs change
            updateConfigItems()
        }
    }
    
    private func updateConfigItems() {
        configItems = configManager.configs
            .sorted(by: { $0.key < $1.key })
            .map { bundleID, sourceID in
                AppConfigItem(
                    id: bundleID,
                    sourceID: sourceID,
                    appName: AppIconProvider.shared.appName(for: bundleID)
                )
            }
    }
    
    private func loadData() async {
        // Load data on background thread
        let sources = await Task.detached(priority: .userInitiated) {
            let sources = InputSourceManager.shared.availableInputSources()
            // Preload input source icons
            AppIconProvider.shared.preloadInputSourceIcons(from: sources)
            // Preload configured app icons and names
            let bundleIDs = Array(ConfigManager.shared.configs.keys)
            AppIconProvider.shared.preloadIcons(for: bundleIDs)
            return sources
        }.value
        
        await MainActor.run {
            availableSources = sources
            updateConfigItems()
            isLoading = false
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

// Extract row as separate view to avoid redundant calculations
struct AppConfigRow: View {
    let bundleID: String
    let sourceID: String
    let appName: String
    let availableSources: [InputSource]
    let configManager: ConfigManager
    
    // Use computed property to cache result
    private var appIcon: NSImage? {
        AppIconProvider.shared.icon(for: bundleID)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = appIcon {
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
                Text(appName)
                    .font(.headline)
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
                    InputSourcePickerItem(source: source)
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

// Input source picker item
struct InputSourcePickerItem: View {
    let source: InputSource
    
    var body: some View {
        HStack {
            Text(source.name)
            if let icon = AppIconProvider.shared.inputSourceIcon(for: source.iconURL) {
                Image(nsImage: icon)
            }
        }
    }
}
