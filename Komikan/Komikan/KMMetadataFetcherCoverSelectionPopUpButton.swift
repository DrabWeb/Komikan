//
//  KMMetadataFetcherCoverSelectionPopUpButton.swift
//  Komikan
//
//  Created by Seth on 2016-02-28.
//

import Cocoa

class KMMetadataFetcherCoverSelectionPopUpButton: NSPopUpButton {
    
    // Disable vibrancy so the image doesnt get ruined
    override var allowsVibrancy : Bool {
        return self.selectedCell()?.title == "Dont Change";
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect);

        // Drawing code here.
        // I know absolute frames are bad, but its the only way
        self.frame = NSRect(x: 217, y: 58, width: 216, height: 219);
    }
}
