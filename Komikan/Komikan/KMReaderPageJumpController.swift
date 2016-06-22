//
//  KMReaderPageJumpController.swift
//  Komikan
//
//  Created by Seth on 2016-03-20.
//

import Cocoa

class KMReaderPageJumpController: NSObject {
    
    /// The array controller for the page jump grid
    @IBOutlet weak var arrayController : NSArrayController!
    
    /// All the pages we can jump to(arrayController's objects)
    var jumpPages : NSMutableArray = NSMutableArray();
    
    /// A reference to the reader view controller
    @IBOutlet weak var readerViewController: KMReaderViewController!
    
    /// The scroll view for readerPageJumpCollectionView
    @IBOutlet weak var readerPageJumpCollectionViewScrollView: NSScrollView!
    
    /// The collection view for showing the page jump thumbnails
    @IBOutlet weak var readerPageJumpCollectionView: NSCollectionView!
    
    /// Sets up the collection view
    func setup() {
        // Set the collection views item prototype
        readerPageJumpCollectionView.itemPrototype = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("readerPageJumpCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the min and max item sizes
        readerPageJumpCollectionView.minItemSize = NSSize(width: 150, height: 200);
        readerPageJumpCollectionView.maxItemSize = NSSize(width: 300, height: 300);
    }
    
    /// Has the thumbnails been loaded at least once?
    var loadedOnce : Bool = false;
    
    /// Sets up the grid with the given manga's pages, current page, and bookmarks
    func loadPagesFromManga(manga : KMManga) {
        // Clear all the current items
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // For every page in the given manga's pages...
        for(currentPageIndex, currentPage) in manga.pages.enumerate() {
            // Add the current page to the page jump collection view
            self.arrayController.addObject(KMReaderPageJumpGridItem(thumbnail: currentPage, currentPage: (manga.currentPage == currentPageIndex), bookmarked: manga.bookmarks.contains(currentPageIndex)));
            
            // Set the item's reader view controller to this
            (self.arrayController.arrangedObjects as! [KMReaderPageJumpGridItem]).last!.readerViewController = self.readerViewController;
            
            // Set the current item's page to the current index
            (self.arrayController.arrangedObjects as! [KMReaderPageJumpGridItem]).last!.page = currentPageIndex;
        }
        
        // Say a manga's thumbnails have already been loaded at least once
        loadedOnce = true;
    }
}
