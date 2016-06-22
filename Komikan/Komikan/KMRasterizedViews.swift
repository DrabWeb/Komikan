//
//  KMFasterShadowImageView.swift
//  Komikan
//
//  Created by Seth on 2016-02-26.
//

import Cocoa

class KMRasterizedImageView: NSImageView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        // Rasterize the layer
        self.layer?.shouldRasterize = true;
    }
}

class KMRasterizedButton: NSButton {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        // Rasterize the layer
        self.layer?.shouldRasterize = true;
    }
}