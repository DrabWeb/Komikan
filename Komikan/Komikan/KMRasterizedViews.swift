//
//  KMFasterShadowImageView.swift
//  Komikan
//
//  Created by Seth on 2016-02-26.
//

import Cocoa

class KMRasterizedImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Rasterize the layer
        self.layer?.shouldRasterize = true;
    }
}

class KMRasterizedButton: NSButton {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        // Rasterize the layer
        self.layer?.shouldRasterize = true;
    }
}
