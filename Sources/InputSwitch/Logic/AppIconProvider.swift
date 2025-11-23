import AppKit
import SwiftUI

class AppIconProvider {
    static let shared = AppIconProvider()
    
    private init() {}
    
    func icon(for bundleID: String) -> NSImage? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return nil
    }
}
