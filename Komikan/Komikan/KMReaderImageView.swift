//
//  KMReaderImageView.swift
//  Komikan
//
//  Created by Seth on 2016-03-26.
//

import Cocoa

class KMReaderImageView: KMDraggableImageView {

    override func draw(_ dirtyRect: NSRect) {
        // Set the image rendering to be the highest of qualities
        NSGraphicsContext.current()?.imageInterpolation = NSImageInterpolation.high;
        
        super.draw(dirtyRect);
    }
}
