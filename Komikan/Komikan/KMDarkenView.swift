//
//  KMDarkenView.swift
//  Komikan
//
//  Created by Seth on 2016-01-31.
//

import Cocoa

class KMDarkenView: NSView {

    // How dark to make this view
    var opacity : CGFloat = 0.4;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Set this view to want a CG layer
        self.wantsLayer = true;
        
        // Set the layers background color
        self.layer?.backgroundColor = NSColor.black.cgColor;
        
        // Set the views opacity
        self.alphaValue = opacity;
    }
}
