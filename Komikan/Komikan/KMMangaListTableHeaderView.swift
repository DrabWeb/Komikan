//
//  KMMangaListTableHeaderView.swift
//  Komikan
//
//  Created by Seth on 2016-02-29.
//

import Cocoa

class KMMangaListTableHeaderView: NSTableHeaderView {
    
    // Override the frame for a custom height
    override var frame: NSRect {
        set {
            // Set the frame to the new frame
            super.frame = newValue;
        }
        get {
            /// The current frame with our custom height that looks better
            var newFrame = super.frame;
            
            // Set the header height to 17, because its too thick by default
            newFrame.size.height = 17;
            
            // Return the modified frame
            return newFrame;
        }
    }
}
