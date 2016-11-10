//
//  NSImage+SystemBezelWindow.swift
//  AirVolume
//
//  Created by Matt Prowse on 7/08/2014.
//  Copyright © 2014 Cordless Dog. All rights reserved.
//

import Cocoa

extension NSImage {
    public func tintedImage(_ tintColor: NSColor) -> NSImage {
        let size = self.size
        let imageBounds = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        // Tint the image.
        let tintedImage = self.copy() as! NSImage
        tintedImage.lockFocus()
        tintColor.set()
        NSRectFillUsingOperation(imageBounds, .sourceAtop)
        tintedImage.unlockFocus()

        return tintedImage
    }
}
