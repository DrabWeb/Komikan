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
    
    // Thhe Manga/Jump to Page menu item
    @IBOutlet weak var jumpToPageMenuItem: NSMenuItem!
    
    // The Manga/Bookmark menu item
    @IBOutlet weak var bookmarkCurrentPageMenuItem: NSMenuItem!
    
    // The view controller we will load for the reader
    var mangaReaderViewController: KMReaderViewController?;
    
    // The controller for the reader window
    var mangaReaderWindowController : NSWindowController!;
    
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
    
    // Clears the cache
    func clearCache() {
        // Get everything in /tmp/komikan and delete it
        do {
            // Get all files in /tmp/komikan
            let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("/tmp/komikan");
            
            // Delete all of them
            for (_, currentFile) in files.enumerate() {
                print("Deleting /tmp/komikan/" + currentFile);
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
        // Clear the cache on load
        clearCache();
        
        // Clears the manga grid, used for debugging
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

