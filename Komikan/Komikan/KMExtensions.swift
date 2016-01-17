//
//  KMExtensions.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

extension NSWindow {
    // Use this to see if the window is fullscreen
    func isFullscreen() -> Bool {
        // Return true/false depending on if the windows style mask contains NSFullScreenWindowMask(Im not actually sure what the & operation does or how it works, but I like it)
        return ((self.styleMask & NSFullScreenWindowMask) > 0);
    }
}