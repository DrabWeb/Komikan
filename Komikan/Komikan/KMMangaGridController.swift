//
//  KMMangaGridController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridController: NSObject {
    
    /// The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!;
    
    /// The items for the manga collection view. THIS IS NOT TO BE MODIFIED DIRECTLY
    var gridItems : [KMMangaGridItem] = [];
    
    /// The current way we are sorting the grid
    var currentSortOrder : KMMangaGridSortType = KMMangaGridSortType.Title;
    
    /// Are we currently ascending the grids sort?
    var currentSortAscending : Bool = false;
    
    /// An array to store all of the manga we are displaying in the collection view
    var manga : NSMutableArray = NSMutableArray();
    
    /// Are we showing lewd manga?
    var showingLewdManga : Bool = false;
    
    override func awakeFromNib() {
        // Subscribe to the MangaGrid.Resort notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resort", name:"MangaGrid.Resort", object: nil);
    }
    
    /// Removes gridItem from the manga grid
    func removeGridItem(gridItem : KMMangaGridItem) {
        // For every item in gridItems...
        for(currentIndex, currentItem) in gridItems.enumerate() {
            // If the current item is the same as the grid item we want to remove...
            if(currentItem == gridItem) {
                // Remove the object at the current index from gridItems
                gridItems.removeAtIndex(currentIndex);
                
                // Remove the current object from the array controller
                arrayController.removeObject(currentItem);
            }
        }
        
        // Resort the grid
        resort();
    }
    
    /// Adds the passed KMMangaGridItem to the manga grid
    func addGridItem(gridItem : KMMangaGridItem) {
        // Append gridItem to gridItems
        gridItems.append(gridItem);
        
        // Add gridItem to the array controller
        arrayController.addObject(gridItem);
    }
    
    /// Clears the entire manga grid (If clearGridItems is true, it also clears gridItems)
    func removeAllGridItems(clearGridItems : Bool) {
        // Remove all objects from the array controller
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // If we said to clear gridItems...
        if(clearGridItems) {
            // Clear gridItems
            gridItems.removeAll();
        }
    }
    
    /// Updates the manga grid to match the items in gridItems
    func updateGridToMatchGridItems() {
        // Remove all the grid items from the array controller
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // Add all the items in gridItems
        setGridToItems(gridItems);
        
        // Resort the grid
        resort();
    }
    
    /// Shows all the items in objects to the manga grid
    func setGridToItems(objects : [KMMangaGridItem]) {
        // Add objects to the manga grid
        arrayController.addObjects(objects);
    }
    
    /// Adds the given manga to the manga grid
    func addManga(manga : KMManga) {
        // Print to the log that we are adding a manga to the grid and what its name is
        print("Adding manga \"" + manga.title + "\" to the manga grid");
        
        // Create a new item
        let newItem : KMMangaGridItem = KMMangaGridItem();
        
        // Set the cover image to the mangas cover image
        newItem.coverImage = manga.coverImage;
        
        // Set the title to the mangas title
        newItem.title = manga.title;
        
        // Set the manga to the manga
        newItem.manga = manga;
        
        // Add the object
        addGridItem(newItem);
    }
    
    // A bool to say if we are currently searching
    var searching : Bool = false;
    
    // Stores all the items that match the search
    var searchItems : [KMMangaGridItem] = [];
    
    /// Searches the manga grid for the passed string, and updates it accordingly
    func searchFor(searchText : String) {
        // Resort the grid
        resort();
        
        // If we arent searching for anything..
        if(searchText == "") {
            // If we have searched before...
            if(searching) {
                removeAllGridItems(false);
                updateGridToMatchGridItems();
            }
        }
        else {
            // Say we are searching
            searching = true;
            
            // Print to the log what we are searching for
            print("Searching for \"" + searchText + "\"");
            
            // Remove all items from the array controller
            removeAllGridItems(false);
            
            // The tags we are searching for, if any
            var searchTags : [String] = [];
            
            // The search tags direct value
            var searchTagsUnsplit : String = "";
            
            // substring between tags: and ;
            if let startRange = searchText.rangeOfString("tags:"), endRange = searchText.rangeOfString(";") where startRange.endIndex <= endRange.startIndex {
                // Set searchTagsUnsplit to the text between tags: and ;
                searchTagsUnsplit = searchText[startRange.endIndex..<endRange.startIndex];
                
                // Set search tags to searchTagsUnsplit split at every ", "
                searchTags = searchTagsUnsplit.componentsSeparatedByString(", ");
            }
            
            // For every item in the manga grid...
            for (_, currentItem) in gridItems.enumerate() {
                // Do we have matching tags?
                var matchingTags : Bool = false;
                
                // How maby mtahcing tags we had
                var matchingTagCount : Int = 0;
                
                // For every tag in the current manga...
                for (_, currentSearchTag) in searchTags.enumerate() {
                    // For every tag we are searching for...
                    for (_, currentTag) in currentItem.manga.tags.enumerate() {
                        // If the two tags match...
                        if(currentTag == currentSearchTag) {
                            // Say we have matching tags
                            matchingTags = true;
                            
                            // Add one to the matching tag count
                            matchingTagCount++;
                        }
                    }
                }
                
                // If we have less matching tags then we searched for...
                if(matchingTagCount < searchTags.count) {
                    // Say that the tags didnt match
                    matchingTags = false;
                }
                
                // The search string, but without the tags:;
                var searchStringWithoutTags : String = searchText.stringByReplacingOccurrencesOfString("tags:" + searchTagsUnsplit + ";", withString: "").lowercaseString;
                
                // If we actually did a title search...
                if(searchStringWithoutTags != "") {
                    // If the last character in searchStringWithoutTags is a space...
                    if(searchStringWithoutTags.substringFromIndex(searchStringWithoutTags.characters.endIndex.predecessor()) == " ") {
                        // Remove the last character
                        searchStringWithoutTags.removeAtIndex(searchStringWithoutTags.endIndex.predecessor());
                    }
                }
                
                // Do we have a matching title?
                let matchingTitle : Bool = currentItem.title.lowercaseString.containsString(searchStringWithoutTags);
                
                // This was terrible to program, 0/10 would not recommend
                // If the current items title includes the search string or has a matching tag...
                if(currentItem.title.lowercaseString.containsString(searchStringWithoutTags) || matchingTags) {
                    // If we did actually search for a title...
                    if(searchStringWithoutTags != "") {
                        // If we have matching tags and title...
                        if(matchingTags && matchingTitle) {
                            // Add the current object
                            searchItems.append(currentItem);
                        }
                        // If we have no search tags...
                        else if(searchTags.count == 0) {
                            // If there is a matching title...
                            if(matchingTitle) {
                                // Add the current object
                                searchItems.append(currentItem);
                            }
                        }
                    }
                    // If we only have matching tags...
                    else if(matchingTags) {
                        // Add the current object
                        searchItems.append(currentItem);
                    }
                }
            }
            
            // Set the grid to show all the items that match the search
            setGridToItems(searchItems);
            
            // Resort the grid
            resort();
        }
    }
    
    /// Resort the manga grid(Based on the last chosen sorting method)
    func resort() {
        // Call the rearrange function on the array
        arrayController.rearrangeObjects();
    }
    
    /// Sorts the manga grid by sortType and ascends/decends based on ascending
    func sort(sortType : KMMangaGridSortType, ascending : Bool) {
        // Print to the log how we are sorting
        print("Sorting manga grid by " + String(sortType));
        
        // Set the current sort type to be the type we are sorting as
        currentSortOrder = sortType;
        
        // Set the current sort ascending to be what we are passing
        currentSortAscending = ascending;
        
        // If the sort type is by series...
        if(sortType == KMMangaGridSortType.Series) {
            // Sort by series
            arrayController.sortDescriptors = [NSSortDescriptor(key: "series", ascending: ascending)];
        }
        // If the sort type is by artist...
        else if(sortType == KMMangaGridSortType.Artist) {
            // Sort by artist
            arrayController.sortDescriptors = [NSSortDescriptor(key: "artist", ascending: ascending)];
        }
        // If the sort type is by title...
        else if(sortType == KMMangaGridSortType.Title) {
            // Sort by title
            arrayController.sortDescriptors = [NSSortDescriptor(key: "title", ascending: ascending)];
        }
    }
}