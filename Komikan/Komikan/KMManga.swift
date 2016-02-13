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
    /// The cover image for this manga
    var coverImage : NSImage = NSImage(named: "NSCaution")!;
    
    /// An array of NSImages that hold all the pages of this manga
    var pages : [NSImage] = [NSImage()];
    
    /// The title of this manga
    var title : String = "";
    
    /// The series this manga belongs to
    var series : String = "";
    
    /// The artist(s) of this manga
    var artist : String = "";
    
    /// The person(s) who wrote this manga
    var writer : String = "";
    
    /// The tags for this manga
    var tags : [String] = [];
    
    /// The directory of this mangas CBZ/CBR
    var directory : String = ""
    
    /// The unique identifier for this mangas /tmp/ folder
    var tmpDirectory : String = "/tmp/komikan/komikanmanga-";
    
    /// The current page we have open
    var currentPage : Int = 0;
    
    /// The amount of pages for this manga
    var pageCount : Int = 0;
    
    /// All the bookmarks for this manga(Each array element is a bookmarked page)
    var bookmarks : [Int]! = [];
    
    /// Has this Manga been read?
    var read : Bool = false;
    
    /// This manga's unique UUID so we dont cause the duplication bug among other things
    var uuid : String = NSUUID().UUIDString.lowercaseString;
    
    /// The saturation for the pages
    var saturation : CGFloat = 1;
    
    /// The brightness for the pages
    var brightness : CGFloat = 0;
    
    /// The contrast for the pages
    var contrast : CGFloat = 1;
    
    /// The sharpness for the pages
    var sharpness : CGFloat = 0;
    
    /// Is this manga l-lewd...?
    var lewd : Bool = false;
    
    /// This manga's group
    var group : String = "";
    
    /// Is this manga a favourite?
    var favourite : Bool = false;
    
    /// How much we are finished this manga(From 0 to 100)
    var percentFinished : Int = 0;
    
    /// A bool to say if we have already set tmpDirectory
    private var alreadySetTmpDirectory : Bool = false;
    
    /// addManga : Bool - Should we extract it to /tmp/komikan/addmanga?
    func extractToTmpFolder() {
        // If we didnt already get the pages(Im kind of cheating and doing this if there is only one page)...
        if(pages.count < 2) {
            // Reset this mangas pages
            pages = [NSImage()];
            
            // If we havent already set tmpDirectory...
            if(!alreadySetTmpDirectory) {
                // Set tmpDirectory to /tmp/komikan/komikanmanga-(Title)
                tmpDirectory += title + "/";
                
                // Say we alrady set tmpDirectory
                alreadySetTmpDirectory = true;
            }
            
            // A variable to tell us all the folders in /tmp/komikan
            var extractedFolders : [String] = [];
            
            // Get all the folders in /tmp/komikan/
            do {
                // Try to set extractedFolders to all the folders in /tmp/komikan/
                extractedFolders = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("/tmp/komikan/");
            }
                // If there is an error...
            catch _ as NSError {
                // Do nothing
            }
            
            // If this manga hasnt already been extracted...
            if(!extractedFolders.contains("komikanmanga-" + NSURL(fileURLWithPath: tmpDirectory).lastPathComponent!)) {
                // Unzip this manga to /tmp/komikan/komikanmanga-(title)
                KMFileUtilities().extractArchive(directory, toDirectory: tmpDirectory);
            }
            else {
                // Print to the log that it has already been extracted
                print("\"" + title + "\" has already been extracted to \"" + tmpDirectory + "\"");
            }
            
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
            KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/cleanmangadir", arguments: [tmpDirectory], waitUntilExit: true);
            
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
        // If we did already get the pages...
        else {
            // Print to the log that we already have the pages
            print("Already got pages for \"" + title + "\"");
        }
    }
    
    /// Updates this manga's percent finished
    func updatePercent() {
        // If the page count minus one is not 0...
        if(self.pageCount - 1 != 0) {
            // Set the percent finished to the current page divided by the page count times 100
            self.percentFinished = Int(Float((Float(self.currentPage) / Float(self.pageCount - 1)) * 100));
        }
        else {
            // Set percent finished to 0
            self.percentFinished = 0;
        }
        
        // If the percent finished is 100...
        if(self.percentFinished >= 100) {
            // Set this manga as read
            self.read = true;
        }
    }
}