//
//  KMMangaGridSelectionBox.swift
//  Komikan
//
//  Created by Seth on 2016-01-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridSelectionBox: NSBox {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.boxType = NSBoxType.Custom;
        self.borderType = NSBorderType.LineBorder;
        self.fillColor = NSColor.selectedControlColor();
    }
}
