//
//  KMReaderPanelView.swift
//  Komikan
//
//  Created by Seth on 2016-01-02.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderPanelView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        self.wantsLayer = true
        self.layer!.cornerRadius = 10;
    }
}
