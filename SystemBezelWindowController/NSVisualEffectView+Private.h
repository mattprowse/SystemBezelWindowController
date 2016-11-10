//
//  NSVisualEffectView+Private.h
//  AirVolume
//
//  Created by Matt Prowse on 7/08/2014.
//  Copyright © 2014 Cordless Dog. All rights reserved.
//


#import <AppKit/AppKit.h>

// TODO: This is no longer required on macOS 10.12 and above, but has to be left in until support for earlier versions is dropped. 
@interface NSVisualEffectView (Private)

- (long long)_internalMaterialType;
- (void)_setInternalMaterialType:(long long)arg1;

@end
