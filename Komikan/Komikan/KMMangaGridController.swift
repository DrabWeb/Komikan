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
    
    // An array to store all of the manga we are displaying in the collection view
    var manga : NSMutableArray = NSMutableArray();
    
    override func awakeFromNib() {
        // Load 100 pictures of the example manga cover and the title "Ushio Diary" to the collection view
//        for _ in 1...100 {
//            let newManga : KMManga = KMManga();
//            
//            newManga.coverImage = NSImage(named: "example-cover")!;
//            newManga.title = "Ushio Diary";
//            
//            addManga(newManga);
//        }
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
    
    // A bool to say if we are currently searching
    var searching : Bool = false;
    
    // An array to store all the manga we have so we can restore it when we are done searching
    var oldItems : [AnyObject] = [];
    
    // Searches the manga grid for the passed string, and updates it accordingly
    func searchFor(searchText : String) {
        // If we arent searching for anything..
        if(searchText == "") {
            // Remove all items from the array controller
            arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
            
            // Say we arent searching
            searching = false;
            
            // For each of the manga we have in oldItems...
            for (_, currentItem) in oldItems.enumerate() {
                // Add the current item as a KMMangaGridItem to the manga grid array
                arrayController.addObject(currentItem as! KMMangaGridItem);
            }
        }
        else {
            // If we havent already started searching...
            if(!searching) {
                // Store all the current manga in oldItems
                oldItems = (arrayController.arrangedObjects as? [AnyObject])!;
            }
            
            // Say we are searching
            searching = true;
            
            // Print to the log what we are searching for
            print("Searching for \"" + searchText + "\"");
            
            // For every item in the manga grid...
            for (_, currentItem) in ((arrayController.arrangedObjects as? [AnyObject])?.enumerate())! {
                // If the current items title does not include the search string...
                if(!(currentItem as? KMMangaGridItem)!.title.containsString(searchText)) {
                    // Remove that object
                    arrayController.removeObject(currentItem);
                }
            }
        }
    }
    
    // Sorts the manga grid by sortType and ascends/decends based on ascending
    func sort(sortType : KMMangaGridSortType, ascending : Bool) {
        // Print to the log how we are sorting
        print("Sorting manga grid by " + String(sortType));
        
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