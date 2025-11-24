import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    private let kConfigKey = "AppInputConfigs"
    private let kShowToastKey = "ShowToast"
    
    @Published var configs: [String: String] = [:] // BundleID -> InputSourceID
    @Published var showToast: Bool = true
    
    private init() {
        loadConfigs()
    }
    
    func loadConfigs() {
        if let saved = UserDefaults.standard.dictionary(forKey: kConfigKey) as? [String: String] {
            self.configs = saved
        }
        
        if UserDefaults.standard.object(forKey: kShowToastKey) != nil {
            self.showToast = UserDefaults.standard.bool(forKey: kShowToastKey)
        } else {
            self.showToast = true // Default true
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
    
    func setShowToast(_ enabled: Bool) {
        showToast = enabled
        UserDefaults.standard.set(enabled, forKey: kShowToastKey)
    }
    
    func getInputSourceID(for bundleID: String) -> String? {
        return configs[bundleID]
    }
}
