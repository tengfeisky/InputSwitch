import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    private let kConfigKey = "AppInputConfigs"
    
    @Published var configs: [String: String] = [:] // BundleID -> InputSourceID
    
    private init() {
        loadConfigs()
    }
    
    func loadConfigs() {
        if let saved = UserDefaults.standard.dictionary(forKey: kConfigKey) as? [String: String] {
            self.configs = saved
        }
    }
    
    func saveConfig(bundleID: String, inputSourceID: String) {
        configs[bundleID] = inputSourceID
        UserDefaults.standard.set(configs, forKey: kConfigKey)
    }
    
    func removeConfig(for bundleID: String) {
        configs.removeValue(forKey: bundleID)
        UserDefaults.standard.set(configs, forKey: kConfigKey)
    }
    
    func getInputSourceID(for bundleID: String) -> String? {
        return configs[bundleID]
    }
}
