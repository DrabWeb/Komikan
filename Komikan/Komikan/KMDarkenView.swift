//
//  KMDarkenView.swift
//  Komikan
//
//  Created by Seth on 2016-01-31.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMDarkenView: NSView {

    // How dark to make this view
    var opacity : CGFloat = 0.4;
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        // Set this view to want a CG layer
        self.wantsLayer = true;
        
        // Set the layers background color
        self.layer?.backgroundColor = NSColor.blackColor().CGColor;
        
        // Set the views opacity
        self.alphaValue = opacity;
    }
}
