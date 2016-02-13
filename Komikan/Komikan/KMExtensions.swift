//
//  KMExtensions.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

extension NSWindow {
    /// Is the window fullscreen?
    func isFullscreen() -> Bool {
        // Return true/false depending on if the windows style mask contains NSFullScreenWindowMask(Im not actually sure what the & operation does or how it works, but I like it)
        return ((self.styleMask & NSFullScreenWindowMask) > 0);
    }
}

extension String {
    /// Converts the string to a bool
    func toBool() -> Bool {
        /// The boolean we will return at the end of the function
        var boolean : Bool = false;
        
        // If this string is either "y", "t", "yes" or "true"...
        if(self == "y" || self == "t" || self == "yes" || self == "true") {
            // Set the boolean to true
            boolean = true;
        }
        // If this string is either "n", "f", "no" or "false"...
        else if(self == "n" || self == "f" || self == "no" || self == "false") {
            // Set the boolean to false
            boolean = false;
        }
        
        // Return boolean
        return boolean;
    }
}