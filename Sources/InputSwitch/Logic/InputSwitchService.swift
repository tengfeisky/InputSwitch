import Foundation
import Combine
import SwiftUI

class InputSwitchService: ObservableObject {
    static let shared = InputSwitchService()
    
    private var cancellables = Set<AnyCancellable>()
    private var savedInputSourceID: String?
    
    private init() {
        setupBindings()
    }
    
    private func setupBindings() {
        AppMonitor.shared.$activeAppBundleID
            .sink { [weak self] bundleID in
                guard let self = self, let bundleID = bundleID else { return }
                self.handleAppChange(bundleID: bundleID)
            }
            .store(in: &cancellables)
    }
    
    private func handleAppChange(bundleID: String) {
        print("Service detected app change: \(bundleID)")
        let configManager = ConfigManager.shared
        let currentSource = InputSourceManager.shared.currentInputSource()
        
        if let targetSourceID = configManager.getInputSourceID(for: bundleID) {
            print("Target app has config: \(targetSourceID)")
            // Target app HAS a configuration
            
            // If we haven't saved a source yet, save the current one (before switching)
            if savedInputSourceID == nil {
                savedInputSourceID = currentSource?.id
                print("Saved previous source: \(savedInputSourceID ?? "nil")")
            }
            
            // Switch to target
            if currentSource?.id != targetSourceID {
                print("Switching to target source...")
                if InputSourceManager.shared.setInputSource(id: targetSourceID) {
                    if let source = InputSourceManager.shared.availableInputSources().first(where: { $0.id == targetSourceID }) {
                        DispatchQueue.main.async {
                            ToastWindow.shared.show(message: "Switched to \(source.name)")
                        }
                    }
                } else {
                    print("Failed to switch input source")
                }
            }
        } else {
            print("Target app has NO config")
            // Target app has NO configuration
            
            // If we have a saved source, restore it
            if let savedID = savedInputSourceID {
                print("Restoring saved source: \(savedID)")
                if currentSource?.id != savedID {
                    if InputSourceManager.shared.setInputSource(id: savedID) {
                        if let source = InputSourceManager.shared.availableInputSources().first(where: { $0.id == savedID }) {
                            DispatchQueue.main.async {
                                ToastWindow.shared.show(message: "Restored to \(source.name)")
                            }
                        }
                    } else {
                        print("Failed to restore input source")
                    }
                }
                // Reset saved source
                savedInputSourceID = nil
            }
        }
    }
}
