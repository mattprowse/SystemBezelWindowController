//
//  NSAppearance+UserInterfacePreferences.swift
//  AirVolume
//
//  Created by Matt Prowse on 8/02/2016.
//  Copyright © 2016 Cordless Dog. All rights reserved.
//

import Cocoa

extension NSAppearance {
    // MARK: - User Interface Preferences
    public static var darkModeEnabled: Bool {
        if let darkModeString = CFPreferencesCopyAppValue(("AppleInterfaceStyle" as NSString as CFString), ("NSGlobalDomain" as NSString as CFString)) as? String {
            return darkModeString == "Dark"
        }
        return false
    }

    public static var reduceTransparencyEnabled: Bool {
        return CFPreferencesGetAppBooleanValue(("reduceTransparency" as NSString as CFString), ("com.apple.universalaccess" as NSString as CFString), nil)
    }

    public static var increaseContrastEnabled: Bool {
        return CFPreferencesGetAppBooleanValue(("increaseContrast" as NSString as CFString), ("com.apple.universalaccess" as NSString as CFString), nil)
    }
}
