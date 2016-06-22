//
//  KMReaderPageJumpGridItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-20.
//

import Cocoa

class KMReaderPageJumpGridItem: NSObject {
    /// The thumbnail for this grid item
    var thumbnail : NSImage = NSImage(named: "NSCaution")!;
    
    /// Is this page bookmarked?
    var bookmarked : Bool = false;
    
    /// Is this page the current page?
    var currentPage : Bool = false;
    
    /// The alpha of this thumbnail
    var alpha : CGFloat = 1.0;
    
    /// The page this item will jump to
    var page : Int = 0;
    
    /// A reference to the reader view controller
    var readerViewController : KMReaderViewController = KMReaderViewController();
    
    /// Reloads the data nad sets values accordingly
    func reloadData() {
        // If this page is the current page...
        if(self.currentPage) {
            // Set the alpha to 0.5
            alpha = 0.5;
        }
        else {
            // Set the alpha to 1.0
            alpha = 1.0;
        }
    }
    
    // Blank init
    override init() {
        self.thumbnail = NSImage(named: "NSCaution")!;
    }
    
    // Init with a thumbnail
    init(thumbnail : NSImage) {
        self.thumbnail = thumbnail;
    }
    
    // Init with a thumbnail, is current page and is bookmarked
    init(thumbnail : NSImage, currentPage : Bool, bookmarked : Bool) {
        super.init();
        
        self.thumbnail = thumbnail;
        self.currentPage = currentPage;
        self.bookmarked = bookmarked;
        
        // Reload the data
        self.reloadData();
    }
}
