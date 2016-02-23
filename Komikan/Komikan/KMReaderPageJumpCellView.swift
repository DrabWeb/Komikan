//
//  KMReaderPageJumpCellView.swift
//  Komikan
//
//  Created by Seth on 2016-02-22.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderPageJumpCellView: NSTableCellView {
    
    /// The KMReaderPageJumpData for this view to call on for page jump information
    var data : KMReaderPageJumpData = KMReaderPageJumpData();

    /// The bookmark marker for the leftmost thumbnail
    @IBOutlet weak var leftBookmarkMarker: NSImageView!
    
    /// The thumbnail image button on the left
    @IBOutlet weak var leftButton: NSButton!
    
    /// The KMReaderViewController that we want to control
    var readerViewController : KMReaderViewController?;
    
    /// When we press leftButton...
    @IBAction func leftButtonPressed(sender: AnyObject) {
        // Close the jump to page dialog
        readerViewController!.closeJumpToPageDialog();
        
        // If the left page number is not -1...
        if(data.thumbnailOnePage != -1) {
            // Jump to the chosen page
            readerViewController!.jumpToPage(data.thumbnailOnePage, round: false);
        }
    }
    
    /// The bookmark marker for the center thumbnail
    @IBOutlet weak var centerBookmarkMarker: NSImageView!
    
    /// The thumbnail image button in the center
    @IBOutlet weak var centerButton: NSButton!
    
    /// When we press centerButton...
    @IBAction func centerButtonPressed(sender: AnyObject) {
        // Close the jump to page dialog
        readerViewController!.closeJumpToPageDialog();
        
        // If the center page number is not -1...
        if(data.thumbnailTwoPage != -1) {
            // Jump to the chosen page
            readerViewController!.jumpToPage(data.thumbnailTwoPage, round: false);
        }
    }
    
    /// The bookmark marker for the rightmost thumbnail
    @IBOutlet weak var rightBookmarkMarker: NSImageView!
    
    /// The thumbnail image button on the right
    @IBOutlet weak var rightButton: NSButton!
    
    /// When we press right button...
    @IBAction func rightButtonPressed(sender: AnyObject) {
        // Close the jump to page dialog
        readerViewController!.closeJumpToPageDialog();
        
        // If the right page number is not -1...
        if(data.thumbnailThreePage != -1) {
            // Jump to the chosen page
            readerViewController!.jumpToPage(data.thumbnailThreePage, round: false);
        }
    }
    
    /// Loads and fills in all the info from the data array
    func loadData() {
        // Load all the thumbnails into the correct buttons
        leftButton.image = data.thumbnailOne;
        centerButton.image = data.thumbnailTwo;
        rightButton.image = data.thumbnailThree;
        
        // If the first thumbnail is blank...
        if(data.thumbnailOne == NSImage()) {
            // Disable and hide the left button
            leftButton.enabled = false;
            leftButton.hidden = true;
        }
        else {
            // Enable and show the left button
            leftButton.enabled = true;
            leftButton.hidden = false;
        }
        
        // If the second thumbnail is blank...
        if(data.thumbnailTwo == NSImage()) {
            // Disable and hide the right button
            rightButton.enabled = false;
            rightButton.hidden = true;
        }
        else {
            // Enable and show the right button
            rightButton.enabled = true;
            rightButton.hidden = false;
        }
        
        // If the third thumbnail is blank...
        if(data.thumbnailThree == NSImage()) {
            // Disable and hide the right button
            rightButton.enabled = false;
            rightButton.hidden = true;
        }
        else {
            // Enable and show the right button
            rightButton.enabled = true;
            rightButton.hidden = false;
        }
        
        // Show / hide the bookmark markers
        leftBookmarkMarker.hidden = data.thumbnailOneBookmarked;
        centerBookmarkMarker.hidden = data.thumbnailTwoBookmarked;
        rightBookmarkMarker.hidden = data.thumbnailThreeBookmarked;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
