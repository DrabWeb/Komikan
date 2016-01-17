//
//  KMWindowDelegate.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

// This class ads basic functionality that I need for my windows, such as fullscreen selectors
class KMWindowDelegate: NSObject, NSWindowDelegate {
    // The selector to run when we enter fullscreen
    var didEnterFullscreenSelector : Selector!;
    
    // The selector to run when we exit fullscreen
    var didExitFullscreenSelector : Selector!;
    
    func windowDidEnterFullScreen(notification: NSNotification) {
        // Run the did enter fullscreen selector
        performSelector(didEnterFullscreenSelector);
    }
    
    func windowDidExitFullScreen(notification: NSNotification) {
        // Run the did exit fullscreen selector
        performSelector(didExitFullscreenSelector);
    }
}
