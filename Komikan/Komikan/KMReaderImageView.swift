//
//  KMReaderImageView.swift
//  Komikan
//
//  Created by Seth on 2016-03-26.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderImageView: KMDraggableImageView {

    override func drawRect(dirtyRect: NSRect) {
        // Set the image rendering to be the highest of qualities
        NSGraphicsContext.currentContext()?.imageInterpolation = NSImageInterpolation.High;
        
        super.drawRect(dirtyRect)
    }
}