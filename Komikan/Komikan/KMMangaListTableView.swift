//
//  KMMangaListTableView.swift
//  Komikan
//
//  Created by Seth on 2016-03-01.
//

import Cocoa

class KMMangaListTableView: NSTableView {
    
    /// A reference to the manga list controller
    var mangaListController : KMMangaListController?;

    override func rightMouseDown(with theEvent: NSEvent) {
        // Get the row index at the cursors position
        let row : Int = self.row(at: self.convert(theEvent.locationInWindow, from: nil));
        
        // Select the row the mouse is over
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false);
        
        // If the manga list has any items selected...
        if(self.selectedRow != -1) {
            // Open the popover for the selected item
            mangaListController!.openPopover(false, manga: mangaListController!.selectedManga());
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func simulateClick(_ theEvent : NSEvent) {
        super.mouseDown(with: theEvent);
        super.mouseUp(with: theEvent);
    }
}
