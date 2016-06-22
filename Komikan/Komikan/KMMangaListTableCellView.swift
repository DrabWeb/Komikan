//
//  KMMangaListTableCellView.swift
//  Komikan
//
//  Created by Seth on 2016-03-12.
//

import Cocoa

class KMMangaListTableCellView: NSTableCellView {
    
    override var acceptsFirstResponder : Bool { return true }
    
    /// A reference to the manga list controller
    var mangaListController : KMMangaListController = KMMangaListController();
    
    /// The image we will show when the user hovers the title
    var thumbnailImage : NSImage = NSImage();
    
    /// The thumbnail controller to use to display thumbnailImage
    var thumbnailImageHoverController : KMThumbnailImageHoverController = KMThumbnailImageHoverController();
    
    override func mouseEntered(theEvent: NSEvent) {
        // If the window is frontmost...
        if(self.window!.keyWindow) {
            // If the edit popover isnt open...
            if(!mangaListController.editPopoverOpen) {
                // Show the thumbnail window
                thumbnailImageHoverController.showAtPoint(thumbnailImage, point: NSPoint(x: NSEvent.mouseLocation().x, y: NSEvent.mouseLocation().y - 125), height: 250);
            }
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        // Hide the thumbnail window
        thumbnailImageHoverController.hide();
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func resizeWithOldSuperviewSize(oldSize: NSSize) {
        // Update the tracking areas
        self.updateTrackingAreas();
    }

    override func updateTrackingAreas() {
        // Remove the tracking are we added before
        self.removeTrackingArea(self.trackingAreas[0]);
        
        /// The same as the original tracking area, but updates to match the frame of this cell
        let trackingArea : NSTrackingArea = NSTrackingArea(rect: frame, options: [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveInKeyWindow], owner: self, userInfo: nil);
        
        // Add the tracking area
        self.addTrackingArea(trackingArea);
    }
    
    override func awakeFromNib() {
        /// The tracking are we will use for getting mouse entered and exited events
        let trackingArea : NSTrackingArea = NSTrackingArea(rect: frame, options: [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveInKeyWindow], owner: self, userInfo: nil);
        
        // Add the tracking area
        self.addTrackingArea(trackingArea);
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}
