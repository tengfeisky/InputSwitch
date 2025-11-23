import Foundation
import AppKit

class AppMonitor: ObservableObject {
    static let shared = AppMonitor()
    
    @Published var activeAppBundleID: String?
    @Published var activeAppName: String?
    
    private var observer: NSObjectProtocol?
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleID = app.bundleIdentifier else {
                return
            }
            
            self.activeAppBundleID = bundleID
            self.activeAppName = app.localizedName
            
            // Notify ConfigManager or handle switching here?
            // Better to let a coordinator handle it, but for simplicity, we can observe this in the main app or ConfigManager.
        }
        
        // Set initial state
        if let currentApp = NSWorkspace.shared.frontmostApplication {
            self.activeAppBundleID = currentApp.bundleIdentifier
            self.activeAppName = currentApp.localizedName
        }
    }
    
    func stopMonitoring() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
    }
}
