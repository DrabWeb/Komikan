//
//  AppDelegate.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // The Manga/Next Page menu item
    @IBOutlet weak var nextPageMenubarItem: NSMenuItem!
    
    // The Manga/Previous Page menu item
    @IBOutlet weak var previousPageMenubarItem: NSMenuItem!
    
    // The Manga/Jump to Page menu item
    @IBOutlet weak var jumpToPageMenuItem: NSMenuItem!
    
    // The Manga/Bookmark menu item
    @IBOutlet weak var bookmarkCurrentPageMenuItem: NSMenuItem!
    
    // The Manga/Dual Page menu item
    @IBOutlet weak var dualPageMenuItem: NSMenuItem!
    
    // The Manga/Fit Window to Page menu item
    @IBOutlet weak var fitWindowToPageMenuItem: NSMenuItem!
    
    // The Komikan/Delete All Manga menu item
    @IBOutlet weak var deleteAllMangaMenuItem: NSMenuItem!
    
    // The Komikan/Add From E-Hentai menu item
    @IBOutlet weak var addFromEHMenuItem: NSMenuItem!
    
    // The view controller we will load for the reader
    var mangaReaderViewController: KMReaderViewController?;
    
    // The controller for the reader window
    var mangaReaderWindowController : NSWindowController!;
    
    // The preferences keeper(Kept in app delegate because it should be globally accesable)
    var preferencesKepper : KMPreferencesKeeper = KMPreferencesKeeper();
    
    // Opens the specified manga in the reader at the specified page
    func openManga(manga : KMManga, page : Int) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the reader
        mangaReaderWindowController = storyboard.instantiateControllerWithIdentifier("reader") as? NSWindowController;
        
        // Get the view controller from the window
        mangaReaderViewController = (mangaReaderWindowController.contentViewController as? KMReaderViewController);
        
        // Tell the view controller to open the manga we passed at the page we passed
        mangaReaderViewController?.openManga(manga, page: page);
        
        // Present mangaReaderWindowController
        mangaReaderWindowController.showWindow(self);
    }
    
    func savePreferences() {
        // Create a string to store our preferences values
        var preferencesString : String = "";
        
        // Add the l-lewd... mode enabled bool to the end of it
        preferencesString.appendContentsOf(String(preferencesKepper.llewdModeEnabled));
        
        // Write the preferences to the preferences file in Komikan's application support
        do {
            // Try to write to the preferences file in Komikan's application support directory
            try preferencesString.writeToFile(NSHomeDirectory() + "/Library/Application Support/Komikan/preferences", atomically: true, encoding: NSUTF8StringEncoding);
            // If there is an error...
        } catch let error as NSError {
            // Print the error description to the log
            print(error.description);
        }
    }
    
    func loadPreferences() {
        // Make sure the preferences file exists
        if(NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/preferences")) {
            // Create a variable to hold the preferences
            var preferencesString : String = "";
            
            // Load the preferences
            do {
                // Try to get the contents of the preferences file in our application support folder
                preferencesString = String(data: NSFileManager.defaultManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/preferences")!, encoding: NSUTF8StringEncoding)!;
                // If there is an error...
            } catch _ as NSError {
                // Print to the log that there is no preferences to load
                print("No preferences file to load");
            }
            
            // For every line in the preferences string
            for (currentIndex, currentElement) in preferencesString.componentsSeparatedByString("\n").enumerate() {
                // If this is the first line...
                if(currentIndex == 0) {
                    // Set the l-lewd... mode enabled bool to be this lines value
                    preferencesKepper.llewdModeEnabled = KMFileUtilities().stringToBool(currentElement);
                }
            }
        }
    }
    
    // Clears the cache
    func clearCache() {
        // Get everything in /tmp/komikan and delete it
        do {
            // Get all files in /tmp/komikan
            let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("/tmp/komikan");
            
            // Delete all of them
            for (_, currentFile) in files.enumerate() {
                // Print to the log what we are removing
                print("Deleting /tmp/komikan/" + currentFile);
                
                // Try to remove it
                try NSFileManager.defaultManager().removeItemAtPath("/tmp/komikan/" + currentFile);
            }
            
            // If there is an error...
        } catch _ as NSError {
            // Print to the log that the cache is already cleared
            print("Cache is already cleared");
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Make sure we have an application support folder
        KMCommandUtilities().runCommand("/bin/mkdir", arguments: [NSHomeDirectory() + "/Library/Application Support/Komikan"]);
        
        // Clear the cache on load
        clearCache();
        
        // Load the preferences
        loadPreferences();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        // Save the preferences
        savePreferences();
        
        // Post the notification saying the app will quit
        NSNotificationCenter.defaultCenter().postNotificationName("Application.WillQuit", object: nil);
    }
}

