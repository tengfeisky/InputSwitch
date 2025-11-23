import SwiftUI

struct MenuBarContent: View {
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        Button("Open Settings") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}
