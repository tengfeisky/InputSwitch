import Cocoa
import SwiftUI

class ToastWindow: NSPanel {
    static let shared = ToastWindow()
    
    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 50),
            styleMask: [.nonactivatingPanel, .hudWindow, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
        
        self.center()
    }
    
    func show(message: String, duration: TimeInterval = 1.0) {
        let hostingView = NSHostingView(rootView: ToastView(message: message))
        self.contentView = hostingView
        
        // Resize to fit content
        self.setContentSize(hostingView.fittingSize)
        
        // Position at bottom center
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = self.frame
            
            let newX = screenRect.midX - (windowRect.width / 2)
            let newY = screenRect.minY + 100 // 100 points from bottom
            
            self.setFrameOrigin(NSPoint(x: newX, y: newY))
        } else {
            self.center()
        }
        
        self.orderFront(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.close()
        }
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
            )
            .shadow(radius: 4)
    }
}
