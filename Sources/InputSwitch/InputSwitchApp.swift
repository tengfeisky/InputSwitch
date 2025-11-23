import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var service: InputSwitchService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("App launched, initializing service...")
        service = InputSwitchService.shared
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

@main
struct InputSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appMonitor = AppMonitor.shared
    @StateObject var configManager = ConfigManager.shared
    
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        
        MenuBarExtra("InputSwitch", systemImage: "keyboard") {
            MenuBarContent()
        }
    }
}

