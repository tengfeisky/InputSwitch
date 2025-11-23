import Foundation
import Carbon

struct InputSource: Identifiable, Hashable {
    let id: String
    let name: String
    let iconURL: URL?
}

class InputSourceManager {
    static let shared = InputSourceManager()
    
    private var cachedSources: [String: TISInputSource] = [:]
    private var cachedInputSources: [InputSource] = []
    
    private init() {
        refreshCache()
    }
    
    func refreshCache() {
        guard let sourceList = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource] else {
            return
        }
        
        var newCachedSources: [String: TISInputSource] = [:]
        var newCachedInputSources: [InputSource] = []
        
        for source in sourceList {
            // Filter for keyboard input modes and layouts
            guard let categoryPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceCategory) else { continue }
            let category = Unmanaged<CFString>.fromOpaque(categoryPtr).takeUnretainedValue()
            
            if category == kTISCategoryKeyboardInputSource {
                
                // Check if it's selectable
                guard let selectablePtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsSelectCapable) else { continue }
                let selectable = Unmanaged<CFBoolean>.fromOpaque(selectablePtr).takeUnretainedValue()
                
                if CFBooleanGetValue(selectable) {
                    guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
                    let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
                    
                    guard let namePtr = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else { continue }
                    let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
                    
                    var iconURL: URL? = nil
                    if let iconUrlPtr = TISGetInputSourceProperty(source, kTISPropertyIconImageURL) {
                         iconURL = Unmanaged<CFURL>.fromOpaque(iconUrlPtr).takeUnretainedValue() as URL
                    }

                    let inputSource = InputSource(id: id, name: name, iconURL: iconURL)
                    newCachedSources[id] = source
                    newCachedInputSources.append(inputSource)
                }
            }
        }
        
        self.cachedSources = newCachedSources
        self.cachedInputSources = newCachedInputSources
    }
    
    func availableInputSources() -> [InputSource] {
        // Return cached version
        if cachedInputSources.isEmpty {
            refreshCache()
        }
        return cachedInputSources
    }
    
    func currentInputSource() -> InputSource? {
        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        
        guard let idPtr = TISGetInputSourceProperty(currentSource, kTISPropertyInputSourceID) else { return nil }
        let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
        
        // Try to find in cache first to avoid extra TIS calls
        if let cached = cachedInputSources.first(where: { $0.id == id }) {
            return cached
        }
        
        guard let namePtr = TISGetInputSourceProperty(currentSource, kTISPropertyLocalizedName) else { return nil }
        let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
        
        var iconURL: URL? = nil
        if let iconUrlPtr = TISGetInputSourceProperty(currentSource, kTISPropertyIconImageURL) {
             iconURL = Unmanaged<CFURL>.fromOpaque(iconUrlPtr).takeUnretainedValue() as URL
        }
        
        return InputSource(id: id, name: name, iconURL: iconURL)
    }
    
    @discardableResult
    func setInputSource(id: String) -> Bool {
        if let source = cachedSources[id] {
            let status = TISSelectInputSource(source)
            return status == noErr
        }
        
        // Fallback if not in cache (maybe new source added?)
        refreshCache()
        if let source = cachedSources[id] {
            let status = TISSelectInputSource(source)
            return status == noErr
        }
        
        return false
    }
}
