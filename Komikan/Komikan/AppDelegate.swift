//
//  AppDelegate.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

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
    
    // The Manga/Switch Dual Page Direction menu item
    @IBOutlet weak var switchDualPageDirectionMenuItem: NSMenuItem!
    
    // The Manga/Fit Window to Page menu item
    @IBOutlet weak var fitWindowToPageMenuItem: NSMenuItem!
    
    // The Komikan/Delete All Manga menu item
    @IBOutlet weak var deleteAllMangaMenuItem: NSMenuItem!
    
    // The Collection/Add From E-Hentai menu item
    @IBOutlet weak var addFromEHMenuItem: NSMenuItem!
    
    // The Komikan/Toggle Background Darken menu item
    @IBOutlet weak var toggleBackgroundDarkenMenuItem: NSMenuItem!
    
    // The view controller we will load for the reader
    var mangaReaderViewController: KMReaderViewController?;
    
    // The controller for the reader window
    var mangaReaderWindowController : NSWindowController!;
    
    // The preferences keeper(Kept in app delegate because it should be globally accesable)
    var preferencesKepper : KMPreferencesKeeper = KMPreferencesKeeper();
    
    // The window controller that lets the user darken everything behind the window
    var darkenBackgroundWindowController : NSWindowController!;
    
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
        
        // Add the l-lewd... mode delete when removing enabled bool to the end of it
        preferencesString.appendContentsOf("\n" + String(preferencesKepper.deleteLLewdMangaWhenRemovingFromTheGrid));
        
        // Add mark as read when completed in reader bool to the end of it
        preferencesString.appendContentsOf("\n" + String(preferencesKepper.markAsReadWhenCompletedInReader));
        
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
            
            // Try to get the contents of the preferences file in our application support folder
            preferencesString = String(data: NSFileManager.defaultManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/preferences")!, encoding: NSUTF8StringEncoding)!;
            
            // For every line in the preferences string
            for (currentIndex, currentElement) in preferencesString.componentsSeparatedByString("\n").enumerate() {
                // If this is the first line...
                if(currentIndex == 0) {
                    // Set the l-lewd... mode enabled bool to be this lines value
                    preferencesKepper.llewdModeEnabled = KMFileUtilities().stringToBool(currentElement);
                }
                // If this is the second line...
                else if(currentIndex == 1) {
                    // Set the l-lewd... mode delete when removing enabled bool to be this lines value
                    preferencesKepper.deleteLLewdMangaWhenRemovingFromTheGrid = KMFileUtilities().stringToBool(currentElement);
                }
                // If this is the third line...
                else if(currentIndex == 2) {
                    // Set if we want to mark manga as read when we finish them in the reader to be this lines value
                    preferencesKepper.markAsReadWhenCompletedInReader = KMFileUtilities().stringToBool(currentElement);
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
    
    func actOnPreferences() {
        // Hide/show the Add From EH Menu Item depending on if we have l-lewd... mode enabled
        addFromEHMenuItem.hidden = !preferencesKepper.llewdModeEnabled;
    }
    
    // How much to darken the background
    var backgroundDarkenAmount : CGFloat = 0.4;
    
    // Do we have the background darkened?
    var backgroundDarkened = false;
    
    func setupBackgroundDarkenWindow() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instantiate the window controller for darkening the background
        darkenBackgroundWindowController = storyboard.instantiateControllerWithIdentifier("backgroundDarkenWindow") as? NSWindowController;
        
        // Set the darken background windows frame to be the same as the srceens frame
        darkenBackgroundWindowController.window?.setFrame(NSRect(x: 0, y: 0, width: (NSScreen.mainScreen()?.frame.width)!, height: (NSScreen.mainScreen()?.frame.height)!), display: false);
        
        // Allow the window to be transparent
        darkenBackgroundWindowController.window?.opaque = false;
        
        // Set the background color to black
        darkenBackgroundWindowController.window?.backgroundColor = NSColor.blackColor();
        
        // Set the transpareny to something /comfy/
        darkenBackgroundWindowController.window?.alphaValue = backgroundDarkenAmount;
        
        // Make the window borderless
        darkenBackgroundWindowController.window?.styleMask |= NSBorderlessWindowMask;
        
        // Make it so you cant click the window
        darkenBackgroundWindowController.window?.ignoresMouseEvents = true;
        
        // Set the windows level
        darkenBackgroundWindowController.window?.level--;
    }
    
    func fadeInDarken() {
        // Order the window to show but not steal focus
        darkenBackgroundWindowController.window?.orderFrontRegardless();
        
        // Animate the window in
        darkenBackgroundWindowController.window?.animator().alphaValue = backgroundDarkenAmount;
    }
    
    func fadeOutDarken() {
        // Animate out the window
        darkenBackgroundWindowController.window?.animator().alphaValue = 0;
        
        // Wait for the animation to finish and hide the window
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("closeDarkenWindow"), userInfo: nil, repeats:false);
    }
    
    func toggleDarken() {
        // Toggle backgroundDarkened
        backgroundDarkened = !backgroundDarkened;
        
        // If the background is now darkened...
        if(backgroundDarkened) {
            // Fade in the darken
            fadeInDarken();
        }
        // If the background is now not darkened...
        else if(!backgroundDarkened) {
            // Fade out the darken
            fadeOutDarken();
        }
    }
    
    private func closeDarkenWindow() {
        // Order out the window
        darkenBackgroundWindowController.window?.orderBack(self);
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Make sure we have an application support folder
        KMCommandUtilities().runCommand("/bin/mkdir", arguments: [NSHomeDirectory() + "/Library/Application Support/Komikan"], waitUntilExit: true);
        
        // Clear the cache on load
        clearCache();
        
        // Load the preferences
        loadPreferences();
        
        // Setup the window thats lets us dim the background
        setupBackgroundDarkenWindow();
        
        // Setup the darken background menu items action
        toggleBackgroundDarkenMenuItem.action = Selector("toggleDarken");
        
        // Subscribe to the KMPreferencesController.Modified notification, so that we can act upon our changed preferences
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnPreferences", name:"KMPreferencesController.Modified", object: nil);
        
        // Get the default notification center
        let nc = NSUserNotificationCenter.defaultUserNotificationCenter();
        
        // Set its delegate to this class
        nc.delegate = self;
    }
    
    internal func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // Always show notifications from this app, even if it is frontmost
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        // Save the preferences
        savePreferences();
        
        // Post the notification saying the app will quit
        NSNotificationCenter.defaultCenter().postNotificationName("Application.WillQuit", object: nil);
    }
}

