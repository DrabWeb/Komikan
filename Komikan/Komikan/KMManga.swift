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
    
    /// The directory of this mangas CBZ/CBR/ZIP/RAR
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
                // If the manga's file isnt a folder...
                if(!KMFileUtilities().isFolder(directory)) {
                    // Unzip this manga to /tmp/komikan/komikanmanga-(title)
                    KMFileUtilities().extractArchive(directory, toDirectory: tmpDirectory);
                }
                // If the manga's file is a folder...
                else {
                    // Copy the folder to /tmp/komikan/komikanmanga-(title)
                    do {
                        try NSFileManager.defaultManager().copyItemAtPath(directory, toPath: tmpDirectory);
                    }
                    catch _ as NSError {
                        
                    }
                }
            }
            else {
                // Print to the log that it has already been extracted
                print("\"" + title + "\" has already been extracted to \"" + tmpDirectory + "\"");
            }
            
            // Print that we are done extracting
            print("Done extracting");
            
            // Run the cleanmangadir binary to make the directory readable for us
            KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/cleanmangadir", arguments: [tmpDirectory], waitUntilExit: true);
            
            /// The names of all the page image files
            var imageFileNames : NSArray = [];
            
            // Get the image file names
            do {
                // Set imageFileNames to all the images in the manga's TMP directory
                imageFileNames = try NSFileManager().contentsOfDirectoryAtPath(tmpDirectory);
                
                // Sort the image file names by their integer values
                imageFileNames = imageFileNames.sortedArrayUsingDescriptors([NSSortDescriptor(key: "integerValue", ascending: true)]);
            }
            catch _ as NSError {
                // Do nothing
            }
            
            // Set pages to all the pages in /tmp/komikan/komikanmanga-(title)
            // For every file in this mangas tmp folder...
            for currentPage in imageFileNames.enumerate() {
                // If the current file is an image and its not a dot file...
                if(KMFileUtilities().isImage(tmpDirectory + (currentPage.element as! String)) && ((currentPage.element as! String).substringToIndex((currentPage.element as! String).startIndex.successor())) != ".") {
                    /// The regex for pages that we want to ignore if they match this regex
                    let excludeRegexPattern : String = (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.pageIgnoreRegex;
                    
                    // If the current page's filename matched the ignore regex...
                    if let _ = (currentPage.element as! String).rangeOfString(excludeRegexPattern, options: .RegularExpressionSearch) {
                        // Print to the log that we are ignoring this file
                        print("Ignoring page \"" + (currentPage.element as! String) + "\"");
                    }
                    // If the current page's filename didnt match the regex...
                    else {
                        // Print to the log what page we found
                        print("Found page \"" + (currentPage.element as! String) + "\"");
                        
                        // Append this image to the manga.pages array
                        pages.append(NSImage(contentsOfFile: tmpDirectory + (currentPage.element as! String))!);
                    }
                }
                // If its not an image...
                else {
                    // Print to the log that we found a non-image file
                    print("Found file \"" + (currentPage.element as! String) + "\" that was not a page");
                }
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
            
            // Set the current page to the first page
            self.currentPage = 0;
        }
        // If the percent finished is less than 100...
        else if(self.percentFinished < 100) {
            // Set this manga as unread
            self.read = false;
        }
    }
}