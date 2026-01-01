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
        Window("InputSwitch", id: "main") {
            ContentView()
        }
        
        MenuBarExtra {
            MenuBarContent()
        } label: {
            MenuBarIconView()
        }
    }
    
    private struct MenuBarIconView: View {
        var body: some View {
            let iconPath = Bundle.module.path(forResource: "menubar_22", ofType: "png", inDirectory: "Assets.xcassets/MenuBarIcon.imageset")
            if let path = iconPath, let nsImage = NSImage(contentsOfFile: path) {
                Image(nsImage: nsImage)
            } else {
                Image(systemName: "keyboard")
            }
        }
    }
}

