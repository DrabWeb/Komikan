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
    
    func sort(sortType : KMMangaGridSortType, ascending : Bool) {
        print("Sorting manga grid by " + String(sortType));
        
        if(sortType == KMMangaGridSortType.Series) {
            arrayController.sortDescriptors = [NSSortDescriptor(key: "series", ascending: ascending)];
        }
        else if(sortType == KMMangaGridSortType.Artist) {
            arrayController.sortDescriptors = [NSSortDescriptor(key: "artist", ascending: ascending)];
        }
        else if(sortType == KMMangaGridSortType.Title) {
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