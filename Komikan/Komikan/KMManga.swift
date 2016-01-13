//
//  KMManga.swift
//  Komikan
//
//  Created by Seth on 2016-01-03.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

// A class for holding information about a manga
class KMManga {
    // The cover image for this manga
    var coverImage : NSImage = NSImage(named: "NSCaution")!;
    
    // An array of NSImages that hold all the pages of this manga
    var pages : [NSImage] = [NSImage()];
    
    // The title of this manga
    var title : String = "";
    
    // The series this manga belongs to
    var series : String = "";
    
    // The artist(s) of this manga
    var artist : String = "";
    
    // The person(s) who wrote this manga
    var writer : String = "";
    
    // The tags for this manga
    var tags : [String] = [];
    
    // The directory of this mangas CBZ/CBR
    var directory : String = ""
    
    // The unique identifier for this mangas /tmp/ folder
    var tmpDirectory : String = "/tmp/komikan/komikanmanga-";
    
    // The current page we have open
    var currentPage : Int = 0;
    
    // The amount of pages for this manga
    var pageCount : Int = 0;
    
    // All the bookmarks for this manga(Each array element is a bookmarked page)
    var bookmarks : [Int]! = [];
    
    // addManga : Bool - Should we extract it to /tmp/komikan/addmanga?
    func extractToTmpFolder() {
        // Reset this mangas pages
        pages = [NSImage()];
        
        // Set tmpDirectory to /tmp/komikan/komikanmanga-(Title)
        tmpDirectory += title + "/";
        
        // Unzip this manga to /tmp/komikan/komikanmanga-(title)
        WPZipArchive.unzipFileAtPath(directory, toDestination: tmpDirectory);
        
        // Some archives will create a __MACOSX folder in the extracted folder, lets delete that
        do {
            // Remove the possible __MACOSX folder
            try NSFileManager().removeItemAtPath(tmpDirectory + "/__MACOSX");
            
            // Print to the log that we deleted it
            print("Deleted the __MACOSX folder in \"" + title + "\"");
            // If there is an error...
        } catch _ as NSError {
            // Print to the log that there is no __MACOSX folder to delete
            print("No __MACOSX folder to delete in \"" + title + "\"");
        }
        
        // Run the cleanmangadir binary to make the directory readable for us
        KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/cleanmangadir", arguments: [tmpDirectory]);
        
        // Set pages to all the pages in /tmp/komikan/komikanmanga-(title)
        do {
            // For every file in this mangas tmp folder...
            for currentPage in try NSFileManager().contentsOfDirectoryAtPath(tmpDirectory).enumerate() {
                // Print to the log what file we found
                print("Found page \"" + currentPage.element + "\"");
                
                // Append this image to the manga.pages array
                pages.append(NSImage(contentsOfFile: tmpDirectory + currentPage.element)!);
            }
            // If there is an error...
        } catch let error as NSError {
            // Print the error description to the log
            print(error.description);
        }
        
        // Remove the first image in pages(Its always nil for no reason)
        pages.removeAtIndex(0);
        
        // Set pageCount
        pageCount = pages.count;
    }
}