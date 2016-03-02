//
//  KMMangaListTableView.swift
//  Komikan
//
//  Created by Seth on 2016-03-01.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaListTableView: NSTableView {
    
    /// A reference to the manga list controller
    var mangaListController : KMMangaListController?;

    override func rightMouseDown(theEvent: NSEvent) {
        // Get the row index at the cursors position
        let row : Int = self.rowAtPoint(self.convertPoint(theEvent.locationInWindow, fromView: nil));
        
        // Select the row the mouse is over
        self.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false);
        
        // If the manga list has any items selected...
        if(self.selectedRow != -1) {
            // Open the popover for the selected item
            mangaListController!.openPopover(false, manga: mangaListController!.selectedManga());
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    func simulateClick(theEvent : NSEvent) {
        super.mouseDown(theEvent);
        super.mouseUp(theEvent);
    }
}
