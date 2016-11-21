//
//  KMWindowDelegate.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//

import Cocoa

// This class ads basic functionality that I need for my windows, such as fullscreen selectors
class KMWindowDelegate: NSWindowController, NSWindowDelegate {
    // The selector to run when we enter fullscreen
    var didEnterFullscreenSelector : Selector!;
    
    // The selector to run when we exit fullscreen
    var didExitFullscreenSelector : Selector!;
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        // Run the did enter fullscreen selector
        perform(didEnterFullscreenSelector);
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        // Run the did exit fullscreen selector
        perform(didExitFullscreenSelector);
    }
}
