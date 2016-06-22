//
//  KMMangaGridSelectionBox.swift
//  Komikan
//
//  Created by Seth on 2016-01-05.
//

import Cocoa

class KMMangaGridSelectionBox: NSBox {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        // Set it to be a custom box
        self.boxType = NSBoxType.Custom;
        
        // Set the corner radius to 5
        self.cornerRadius = 5;
        
        // Set the alpha value to 0.2
        self.alphaValue = 0.2;
        
        // Set the box to have no border
        self.borderType = NSBorderType.NoBorder;
        
        // Set the background color to black
        self.fillColor = NSColor.blackColor();
    }
}
