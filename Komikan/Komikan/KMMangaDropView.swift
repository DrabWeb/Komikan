//
//  KMMangaGridCollectionView.swift
//  Komikan
//
//  Created by Seth on 2016-02-15.
//

import Cocoa

class KMMangaDropView: NSVisualEffectView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        // Register for dragging
        self.register(forDraggedTypes: NSArray(objects: NSFilenamesPboardType) as! [String]);
        
        // Set the material to dark
        self.material = NSVisualEffectMaterial.dark;
        
        // Hide the view
        self.alphaValue = 0;
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // Bring the app to the front
        NSApplication.shared().activate(ignoringOtherApps: true);
        
        // Animate in the add symbol and vibrancy
        self.animator().alphaValue = 1;
        
        return NSDragOperation.copy;
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy;
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo?) {
        // Fade out the view
        self.animator().alphaValue = 0;
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        // Fade out the view
        self.animator().alphaValue = 0;
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // Post the notification saying that we have dropped the files and to show the add / import popover with the files
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MangaGrid.DropFiles"), object: sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType"));
        
        return true;
    }
}
