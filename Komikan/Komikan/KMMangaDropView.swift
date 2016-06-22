//
//  KMMangaGridCollectionView.swift
//  Komikan
//
//  Created by Seth on 2016-02-15.
//

import Cocoa

class KMMangaDropView: NSVisualEffectView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        // Register for dragging
        self.registerForDraggedTypes(NSArray(objects: NSFilenamesPboardType) as! [String]);
        
        // Set the material to dark
        self.material = NSVisualEffectMaterial.Dark;
        
        // Hide the view
        self.alphaValue = 0;
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        // Bring the app to the front
        NSApplication.sharedApplication().activateIgnoringOtherApps(true);
        
        // Animate in the add symbol and vibrancy
        self.animator().alphaValue = 1;
        
        return NSDragOperation.Copy;
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy;
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        // Fade out the view
        self.animator().alphaValue = 0;
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        // Fade out the view
        self.animator().alphaValue = 0;
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        // Post the notification saying that we have dropped the files and to show the add / import popover with the files
        NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.DropFiles", object: sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType"));
        
        return true;
    }
}
