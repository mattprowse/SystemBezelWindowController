//
//  SystemBezelWindowLevelIndicator.swift
//  AirVolume
//
//  Created by Matt Prowse on 5/08/2014.
//  Copyright © 2014 Cordless Dog. All rights reserved.
//

import Cocoa

private enum SystemBezelWindowLevelIndicatorColorKeys {
    case background, segment
}

internal class SystemBezelWindowLevelIndicator: NSView {
    // MARK: - Constants
    private let maxLevel: Int = 16

    // MARK: - Constants – Metrics
    private let segmentSize = NSSize(width: 9, height: 6)
    private let segmentSpacing: CGFloat = 1

    // MARK: - Constants – Colours
    private let drawColors: [SystemBezelWindowColorMode: [SystemBezelWindowLevelIndicatorColorKeys: NSColor]] = [
        .light: [.background: NSColor(deviceWhite: 0, alpha: 0.6), .segment: .controlBackgroundColor],
        .lightReducedTransparency: [.background: NSColor(deviceWhite: 0.50, alpha: 1.0), .segment: .white],
        .lightIncreasedContrast: [.background: NSColor(deviceWhite: 0.01, alpha: 1.0), .segment: .white],
        .dark: [.background: NSColor(deviceWhite: 0, alpha: 0.6), .segment: NSColor(deviceWhite: 1, alpha: 0.8)],
        .darkReducedTransparency: [.background: NSColor(deviceWhite: 0.01, alpha: 1.0), .segment: NSColor(deviceWhite: 0.49, alpha: 1.0)],
        .darkIncreasedContrast: [.background: NSColor(deviceWhite: 0.01, alpha: 1.0), .segment: NSColor(deviceWhite: 0.76, alpha: 1.0)],
    ]

    // MARK: - Properties – Computed
    private var backgroundColor: NSColor {
        return self.drawColors[self.colorMode]![.background]!
    }

    private var segmentColor: NSColor {
        return self.drawColors[self.colorMode]![.segment]!
    }

    // MARK: - Properties — Internal
    var level: Int = 0 {
        willSet {
            if newValue < 0 {
                self.level = 0
            } else if newValue > self.maxLevel {
                self.level = self.maxLevel
            }
        }
        didSet {
            self.needsDisplay = true
        }
    }

    var colorMode: SystemBezelWindowColorMode = .light {
        didSet {
            self.needsDisplay = true
        }
    }

    // MARK: - NSView
    override var allowsVibrancy: Bool {
        return false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.backgroundColor.set()
        NSRectFill(dirtyRect)

        var segmentIndex = 0
        var segmentXOffset: CGFloat = self.segmentSpacing

        self.segmentColor.set()
        while segmentIndex < self.level {
            let segmentRect = NSRect(x: segmentXOffset, y: 1, width: self.segmentSize.width, height: self.segmentSize.height)
            NSRectFill(segmentRect)
            segmentIndex += 1
            segmentXOffset += self.segmentSize.width + self.segmentSpacing
        }
    }
}
