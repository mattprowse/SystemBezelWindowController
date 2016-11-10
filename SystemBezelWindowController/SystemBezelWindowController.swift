//
//  SystemBezelWindowController.swift
//  AirVolume
//
//  Created by Matt Prowse on 27/10/2014.
//  Copyright © 2014 Cordless Dog. All rights reserved.
//

import Cocoa
import CoreGraphics

// MARK: - Enum – Color Modes
public enum SystemBezelWindowColorMode {
    case light, lightReducedTransparency, lightIncreasedContrast
    case dark, darkReducedTransparency, darkIncreasedContrast
}

public class SystemBezelWindowController: NSWindowController {
    // MARK: - Frame Constants

    // Main Window
    private class var windowFrameRect: NSRect {
        return NSRect(x: 0, y: 140, width: 200, height: 200)
    }

    private class var windowCornerRadius: CGFloat {
        return 19
    }

    // Image View
    private class var imageViewFrameRect: NSRect {
        return NSRect(x: 50, y: 62, width: 100, height: 100)
    }

    private class var centredImageViewFrameRect: NSRect {
        return NSRect(x: 50, y: 50, width: 100, height: 100)
    }

    // Level Indicator
    private class var levelIndicatorFrameRect: NSRect {
        return NSRect(x: 20, y: 20, width: 161, height: 8)
    }

    private var activeColorMode: SystemBezelWindowColorMode {
        if NSAppearance.increaseContrastEnabled {
            return NSAppearance.darkModeEnabled ? .darkIncreasedContrast : .lightIncreasedContrast
        }

        if NSAppearance.reduceTransparencyEnabled {
            return NSAppearance.darkModeEnabled ? .darkReducedTransparency : .lightReducedTransparency
        }

        return NSAppearance.darkModeEnabled ? .dark : .light
    }

    // MARK: - Embedded Views
    // Effect View
    private let effectView: NSVisualEffectView

    // Image View
    private let imageView: NSImageView

    // Level Indicator
    private let levelIndicator: SystemBezelWindowLevelIndicator

    // MARK: - Hide Window Timer
    private var hideWindowTimer: Timer? {
        willSet {
            if let currentTimer = self.hideWindowTimer {
                if !(currentTimer === newValue) {
                    currentTimer.invalidate()
                }
            }
        }
    }

    // MARK: - Properties — Public
    public var image: NSImage! {
        set(newImage) {
            self.imageView.image = newImage // .imageAsHUDOverlay()
        }
        get {
            return self.imageView.image
        }
    }

    public var levelIndicatorHidden: Bool {
        get {
            return self.levelIndicator.isHidden
        }
        set {
            self.levelIndicator.isHidden = newValue
            if newValue {
                self.imageView.frame = SystemBezelWindowController.centredImageViewFrameRect
            } else {
                self.imageView.frame = SystemBezelWindowController.imageViewFrameRect
            }
        }
    }

    public var indicatedLevel: Int {
        get {
            return self.levelIndicator.level
        }
        set {
            return self.levelIndicator.level = newValue
        }
    }

    public var delaysOnClose = true

    // MARK: - Initialisers
    public override init(window: NSWindow?) {
        self.effectView = NSVisualEffectView(frame: NSRect(origin: .zero, size: SystemBezelWindowController.windowFrameRect.size))
        self.imageView = NSImageView(frame: SystemBezelWindowController.imageViewFrameRect)
        self.levelIndicator = SystemBezelWindowLevelIndicator(frame: SystemBezelWindowController.levelIndicatorFrameRect)
        let systemBezelWindow = NSWindow(contentRect: SystemBezelWindowController.windowFrameRect, styleMask: .borderless, backing: .buffered, defer: false)
        super.init(window: systemBezelWindow)
        self.configureWindowAndViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    private func configureWindowAndViews() {
        // Configure the window
        if let window = self.window {
            window.ignoresMouseEvents = true
            window.backgroundColor = NSColor.clear
            window.level = Int(CGWindowLevelKey.overlayWindow.rawValue)
            window.isOpaque = false
        }

        // Configure the visual effect view
        self.effectView.state = .active

        // Set a mask on the visual effect view to round the corners
        // This is currently disabled because it breaks when reduced transparency is turned on (it shows a black box where the view is masked out.
        let bounds = self.effectView.bounds
        self.effectView.maskImage = NSImage(size: bounds.size, flipped: true) { (rect: NSRect) -> Bool in
            let path = NSBezierPath(roundedRect: bounds, xRadius: SystemBezelWindowController.windowCornerRadius, yRadius: SystemBezelWindowController.windowCornerRadius)
            path.fill()
            return true
        }

        // Configure the window's content view
        if let contentView = window?.contentView {
            contentView.wantsLayer = true

            // Add subviews
            contentView.addSubview(effectView)
            effectView.addSubview(self.imageView)
            effectView.addSubview(self.levelIndicator)
        }
    }

    // MARK: - Actions – Internal
    private func updateAppearance() {
        if NSAppearance.darkModeEnabled {
            self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            self.effectView.material = .dark
            if self.effectView.responds(to: #selector(NSVisualEffectView._setInternalMaterialType(_:))) {
                self.effectView._setInternalMaterialType(4)
            }
        } else {
            self.window?.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            self.effectView.material = .light
            if self.effectView.responds(to: #selector(NSVisualEffectView._setInternalMaterialType(_:))) {
                self.effectView._setInternalMaterialType(0)
            }
        }

        self.effectView.blendingMode = self.activeColorMode == .light ? .withinWindow : .behindWindow

        self.levelIndicator.colorMode = self.activeColorMode
    }

    private func centreBezelHorizontallyOnCurrentScreen() {
        if let mainScreen = NSScreen.main() {
            let screenHorizontalMidPoint = mainScreen.frame.size.width / 2
            if let window = self.window {
                var newFrame = window.frame
                newFrame.origin.x = screenHorizontalMidPoint - (window.frame.size.width / 2)
                window.setFrame(newFrame, display: true, animate: false)
            }
        }
    }

    // It's not possible to call super from an animation completion handler, so we wrap the call to super an instance method.
    private func superClassClose() {
        super.close()
    }

    // This method will be called by a timer by default, so its visibility cannot be private.
    internal func performCloseWithFadeOut(_ timer: Timer!) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.7
            self.window?.animator().alphaValue = 0
        }, completionHandler: {
            self.superClassClose()
        })
    }

    // It's not possible to call super from an animation completion handler, so we wrap the call to super in an instance method.
    private func superClassShowWindow(_ sender: Any!) {
        super.showWindow(sender)
    }

    // MARK: - Actions – Public
    public override func showWindow(_ sender: Any!) {
        self.hideWindowTimer = nil

        // This is wrapped in an animation block so that it cancels the fadeout animation if required.
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.01
            self.window?.alphaValue = 1
        }, completionHandler: { () in
            self.updateAppearance()
            self.centreBezelHorizontallyOnCurrentScreen()
            self.superClassShowWindow(sender)
        })
    }

    public override func close() {
        if self.delaysOnClose {
            self.hideWindowTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SystemBezelWindowController.performCloseWithFadeOut(_:)), userInfo: nil, repeats: false)
        } else {
            self.performCloseWithFadeOut(nil)
        }
    }
}
