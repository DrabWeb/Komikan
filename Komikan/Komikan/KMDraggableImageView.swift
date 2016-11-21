//
//  KMDraggableImageView.swift
//  Komikan
//
//  Created by Seth on 2016-02-18.
//

import Cocoa

class KMDraggableImageView: NSImageView {

    // Override mouse down can move window so we can drag the image view and move the window
    override var mouseDownCanMoveWindow : Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
