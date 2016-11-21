//
//  KMMangaGroupCollectionItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//

import Cocoa

class KMMangaGroupCollectionItem: NSCollectionViewItem {

    override func mouseDown(with theEvent: NSEvent) {
        // Select this item
        self.isSelected = true;
        
        // Set the collection view to be frontmost
        NSApplication.shared().windows.first!.makeFirstResponder(self.collectionView);
        
        // If we double clicked...
        if(theEvent.clickCount == 2) {
            // Display this groups manga
            displayManga();
        }
    }
    
    /// Displays the manga for this group of manga(Actually searches in the background)
    func displayManga() {
        /// The search term to use for this group
        var searchTerm : String = "";
        
        // If this item's group type is Series...
        if((self.representedObject as! KMMangaGroupItem).groupType == KMMangaGroupType.series) {
            // Set the search term to series
            searchTerm = "s";
        }
        // If this item's group type is Artist...
        else if((self.representedObject as! KMMangaGroupItem).groupType == KMMangaGroupType.artist) {
            // Set the search term to artist
            searchTerm = "a";
        }
        // If this item's group type is Writer...
        else if((self.representedObject as! KMMangaGroupItem).groupType == KMMangaGroupType.writer) {
            // Set the search term to writer
            searchTerm = "w";
        }
        // If this item's group type is Group...
        else if((self.representedObject as! KMMangaGroupItem).groupType == KMMangaGroupType.group) {
            // Set the search term to group
            searchTerm = "g";
        }
        
        // Make the search
        (NSApplication.shared().delegate as! AppDelegate).mangaGridController.searchFor(searchTerm + ":\"" + (self.representedObject as! KMMangaGroupItem).groupName.replacingOccurrences(of: (self.representedObject as! KMMangaGroupItem).countLabel, with: "") + "\"");
        
        // Update the search field
        (NSApplication.shared().delegate as! AppDelegate).searchTextField.stringValue = searchTerm + ":\"" + (self.representedObject as! KMMangaGroupItem).groupName.replacingOccurrences(of: (self.representedObject as! KMMangaGroupItem).countLabel, with: "") + "\"";
        
        // Hide the group view
        (NSApplication.shared().delegate as! AppDelegate).mainViewController.hideGroupView();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
