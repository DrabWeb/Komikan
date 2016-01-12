//
//  KMMangaGridController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridController: NSObject {
    // The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!;
    
    // The current way we are sorting the grid
    var currentSortOrder : KMMangaGridSortType = KMMangaGridSortType.Title;
    
    // Are we currently ascending the grids sort?
    var currentSortAscending : Bool = false;
    
    // An array to store all of the manga we are displaying in the collection view
    var manga : NSMutableArray = NSMutableArray();
    
    override func awakeFromNib() {
        // Subscribe to the MangaGrid.Resort notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resort", name:"MangaGrid.Resort", object: nil);
    }
    
    // Adds a given manga to the array
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
        arrayController.addObject(newItem);
    }
    
    func willQuit() {
        // Remove all items from the array controller
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // Say we arent searching
        searching = false;
        
        // Let the collection view show our manga again
        arrayController.addObjects(oldItems);
        
        // Remove the observer so we dont get duplicate calls
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    // A bool to say if we are currently searching
    var searching : Bool = false;
    
    // An array to store all the manga we have so we can restore it when we are done searching
    var oldItems : [KMMangaGridItem] = [];
    
    // Searches the manga grid for the passed string, and updates it accordingly
    func searchFor(searchText : String) {
        // Subscribe to AppDelegate's WillQuit notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willQuit", name:"Application.WillQuit", object: nil);
        
        // Resort the grid
        resort();
        
        // If we arent searching for anything..
        if(searchText == "") {
            print(arrayController.arrangedObjects);
            
            // Remove all items from the array controller
            arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
            
            print(arrayController.arrangedObjects);
            
            if(arrayController.arrangedObjects.count == 0) {
                print("/-------------------------\\");
                print("| Array controller empty! |");
                print("\\-------------------------/");
            }
            
            // Say we arent searching
            searching = false;
            
            // For each of the manga we have in oldItems...
            for (_, currentItem) in oldItems.enumerate() {
                // Add the current item as a KMMangaGridItem to the manga grid array
                arrayController.addObject(currentItem);
            }
        }
        else {
            // If we havent already started searching...
            if(!searching) {
                // Store all the current manga in oldItems
                oldItems = (arrayController.arrangedObjects as? [KMMangaGridItem])!;
            }
            
            // Say we are searching
            searching = true;
            
            // Print to the log what we are searching for
            print("Searching for \"" + searchText + "\"");
            
            // Remove all items from the array controller
            arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
            
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
            for (_, currentItem) in oldItems.enumerate() {
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
                
                // If the current items title includes the search string or has a matching tag...
                if(matchingTags || currentItem.title.lowercaseString.containsString(searchText.stringByReplacingOccurrencesOfString("tags:" + searchTagsUnsplit + ";", withString: "").lowercaseString)) {
                    // If we are searching for tags...
                    if(searchTagsUnsplit != "") {
                        // If we have matching tags...
                        if(matchingTags) {
                            // Add the current object
                            arrayController.addObject(currentItem);
                        }
                    }
                    else {
                        // Add the current object
                        arrayController.addObject(currentItem);
                    }
                }
            }
        }
    }
    
    // Resorts the grid with the last entered sort details
    func resort() {
        // Resort the grid, its gets messy when searching and add/deleting/editing manga
        sort(currentSortOrder, ascending: currentSortAscending);
    }
    
    // Sorts the manga grid by sortType and ascends/decends based on ascending
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

// Used to describe how to sort the manga grid
enum KMMangaGridSortType {
    // Sorts by series
    case Series
    
    // Sorts by artist
    case Artist
    
    // Sorts by title
    case Title
}