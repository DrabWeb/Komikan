//
//  KMReaderPageJumpTableView.swift
//  Komikan
//
//  Created by Seth on 2016-02-22.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderPageJumpTableView: NSTableView {

    /// The array of KMReaderPageJumpData that we will use for the table view
    var thumbnails : [KMReaderPageJumpData] = [];
    
    /// Have we called loadDataFromManga at least once?
    var loadedDataFromManga : Bool = false;
    
    /// The KMReaderViewController that this table view should use for page jumping
    var readerViewController : KMReaderViewController?;
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        // Set this table views delegate and data source to this
        self.setDataSource(self);
        self.setDelegate(self);
    }
    
    /// Loads the data from the passed KMManga into the table view. Also only does bookmarks if onlyBookmarks is true. This is such a hack and should probably be redone
    func loadDataFromManga(manga : KMManga, onlyBookmarks : Bool) {
        // If we arent doing only bookmarks...
        if(!onlyBookmarks) {
            // Clear the table
            thumbnails.removeAll();
        }
        
        // For pageCount is less than the page count and we add three...
        for(var pageCount = 3; pageCount < (manga.pages.count + 3); pageCount += 3) {
            /// The array of NSImages we will add to the jump view at the end
            var thumbnailArray : [NSImage] = [];
            
            /// The array of Ints to say what pages each thumbnail jumpts to
            var pageNumbers : [Int] = [];
            
            /// The array of bookmark Bools we will pass ti the row data
            var bookmarks : [Bool] = [false, false, false];
            
            // For every number from 1 to 3...
            for index in 1...3 {
                // If the current index in the higher for loop - 4 + the current index from 1 to 3 is less than the manga's page count(This is the hack)
                if((pageCount - 4) + index < manga.pages.count) {
                    // If we arent doing only bookmarks...
                    if(!onlyBookmarks) {
                        // Append the current page
                        thumbnailArray.append(manga.pages[(pageCount - 4) + index]);
                        
                        // Add the current page to the pages
                        pageNumbers.append((pageCount - 4) + index);
                    }
                    // If the manga's bookmarks contains this page...
                    if(manga.bookmarks.contains((pageCount - 4) + index)) {
                        // Set this page to be bookmarked in the jump view
                        bookmarks[index - 1] = true;
                    }
                }
            }
            
            /// The KMReaderPageJumpData we will add to the table view
            let rowData : KMReaderPageJumpData = KMReaderPageJumpData();
            
            // If we arent doing only bookmarks...
            if(!onlyBookmarks) {
                // Load the thumbnail data from the thumbnail array
                rowData.loadThumbnailsFromArray(thumbnailArray);
            
                // Load the page number data
                rowData.loadPageNumbersFromArray(pageNumbers);
            }
            
            // Load the bookmark data
            rowData.loadBookmarksFromArray(bookmarks);
            
            // Add the row data to the thumbnails array
            self.thumbnails.append(rowData);
        }
        
        // Reload the table view
        self.reloadData();
        
        // Say we have called loadedDataFromManga at least once
        loadedDataFromManga = true;
    }
}

extension KMReaderPageJumpTableView : NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the amount of thumbnail items
        return self.thumbnails.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the column is the Thumbnail Column...
        if(tableColumn!.identifier == "Thumbnail Column") {
            /// This items thumbnail data
            let thumbnailItemData = self.thumbnails[row]
            
            // Set the cell views reader view controller
            (cellView as? KMReaderPageJumpCellView)?.readerViewController = readerViewController;
            
            // Set the cell views data so it can update it as it is changed
            (cellView as? KMReaderPageJumpCellView)?.data = thumbnailItemData;
            
            // Tell the cell to load its data
            (cellView as? KMReaderPageJumpCellView)?.loadData();
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we didnt need to do anything to this one
        return cellView;
    }
}

extension KMReaderPageJumpTableView : NSTableViewDelegate {
    
}