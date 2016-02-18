//
//  KMDraggableImageView.swift
//  Komikan
//
//  Created by Seth on 2016-02-18.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMDraggableImageView: NSImageView {

    // Override mouse down can move window so we can drag the image view and move the window
    override var mouseDownCanMoveWindow : Bool {
        return true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
