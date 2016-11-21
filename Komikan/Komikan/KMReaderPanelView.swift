//
//  KMReaderPanelView.swift
//  Komikan
//
//  Created by Seth on 2016-01-02.
//

import Cocoa

class KMReaderPanelView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Set it so we can have a CGLayer
        self.wantsLayer = true;
        
        // Set the corner radius to 10(Round)
        self.layer!.cornerRadius = 10;
    }
}
