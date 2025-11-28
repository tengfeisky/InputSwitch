import AppKit
import SwiftUI

class AppIconProvider {
    static let shared = AppIconProvider()
    
    // Cache for app icons
    private var iconCache: [String: NSImage] = [:]
    // Cache for app names
    private var nameCache: [String: String] = [:]
    // Cache for app URLs
    private var urlCache: [String: URL] = [:]
    // Cache for input source icons
    private var inputSourceIconCache: [URL: NSImage] = [:]
    
    private let cacheQueue = DispatchQueue(label: "com.inputswitch.iconprovider", qos: .userInitiated)
    
    private init() {}
    
    func icon(for bundleID: String) -> NSImage? {
        // Check cache first
        if let cached = iconCache[bundleID] {
            return cached
        }
        
        // Cache miss, load synchronously (first time)
        if let url = appURL(for: bundleID) {
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            iconCache[bundleID] = icon
            return icon
        }
        return nil
    }
    
    func appURL(for bundleID: String) -> URL? {
        // Check cache first
        if let cached = urlCache[bundleID] {
            return cached
        }
        
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            urlCache[bundleID] = url
            return url
        }
        return nil
    }
    
    func appName(for bundleID: String) -> String {
        // Check cache first
        if let cached = nameCache[bundleID] {
            return cached
        }
        
        if let url = appURL(for: bundleID) {
            let name = FileManager.default.displayName(atPath: url.path)
            nameCache[bundleID] = name
            return name
        }
        
        // Return bundleID if not found
        return bundleID
    }
    
    func inputSourceIcon(for url: URL?) -> NSImage? {
        guard let url = url else { return nil }
        
        // Check cache first
        if let cached = inputSourceIconCache[url] {
            return cached
        }
        
        // Cache miss, load icon
        if let icon = NSImage(contentsOf: url) {
            inputSourceIconCache[url] = icon
            return icon
        }
        return nil
    }
    
    // Preload all configured app icons and names
    func preloadIcons(for bundleIDs: [String]) {
        cacheQueue.async { [weak self] in
            for bundleID in bundleIDs {
                _ = self?.icon(for: bundleID)
                _ = self?.appName(for: bundleID)
            }
        }
    }
    
    // Preload input source icons
    func preloadInputSourceIcons(from sources: [InputSource]) {
        cacheQueue.async { [weak self] in
            for source in sources {
                _ = self?.inputSourceIcon(for: source.iconURL)
            }
        }
    }
    
    // Clear cache
    func clearCache() {
        iconCache.removeAll()
        nameCache.removeAll()
        urlCache.removeAll()
        inputSourceIconCache.removeAll()
    }
}
