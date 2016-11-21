//
//  KMFavouriteButton.swift
//  Komikan
//
//  Created by Seth on 2016-02-13.
//

import Cocoa

class KMFavouriteButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Set the alternate and regular images to the star
        self.image = NSImage(named: "Star");
        self.alternateImage = NSImage(named: "Star");
        
        // Set the alternate and regular images to be vibrant
        self.image?.isTemplate = true;
        self.alternateImage?.isTemplate = true;
        
        // Set the target to this
        self.target = self;
        
        // Set the action to update the button
        self.action = #selector(KMFavouriteButton.updateButton);
    }
    
    /// Updates the button based on its state
    func updateButton() {
        // If state is true...
        if(Bool(self.state as NSNumber)) {
            // Animate the buttons alpha value to 1
            self.animator().alphaValue = 1;
        }
        else {
            // Animate the buttons alpha value to 0.2
            self.animator().alphaValue = 0.2;
        }
    }
}
