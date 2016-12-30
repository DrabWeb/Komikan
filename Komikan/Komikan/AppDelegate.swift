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

    /// The File/Open Selected menu item
    @IBOutlet weak var openMenuItem: NSMenuItem!
    
    /// The Manga/Next Page menu item
    @IBOutlet weak var nextPageMenubarItem: NSMenuItem!
    
    /// The Manga/Previous Page menu item
    @IBOutlet weak var previousPageMenubarItem: NSMenuItem!
    
    /// The Manga/Jump to Page menu item
    @IBOutlet weak var jumpToPageMenuItem: NSMenuItem!
    
    /// The Manga/Bookmark menu item
    @IBOutlet weak var bookmarkCurrentPageMenuItem: NSMenuItem!
    
    /// The Manga/Dual Page menu item
    @IBOutlet weak var dualPageMenuItem: NSMenuItem!
    
    /// The Manga/Switch Dual Page Direction menu item
    @IBOutlet weak var switchDualPageDirectionMenuItem: NSMenuItem!
    
    /// The Manga/Fit Window to Page menu item
    @IBOutlet weak var fitWindowToPageMenuItem: NSMenuItem!
    
    /// The Komikan/Delete All Manga menu item
    @IBOutlet weak var deleteAllMangaMenuItem: NSMenuItem!
    
    /// The Collection/Add From E-Hentai menu item
    @IBOutlet weak var addFromEHMenuItem: NSMenuItem!
    
    /// The Komikan/Toggle Background Darken menu item
    @IBOutlet weak var toggleBackgroundDarkenMenuItem: NSMenuItem!
    
    /// The menu item that lets you toggle the info bar in the main window
    @IBOutlet weak var toggleInfoBarMenuItem: NSMenuItem!
    
    /// The Collection/Manage/Delete Selected menu item
    @IBOutlet weak var deleteSelectedMangaMenuItem: NSMenuItem!
    
    /// The Collection/Manage/Mark Selected as Read menu item
    @IBOutlet weak var markSelectedAsReadMenuItem: NSMenuItem!
    
    /// The Collection/Manage/Mark Selected as Unread menu item
    @IBOutlet weak var markSelectedAsUnreadMenuItem: NSMenuItem!
    
    /// The Collection/Manage/Set Selected Items Properties Menu Items
    @IBOutlet weak var setSelectedItemsPropertiesMenuItems: NSMenuItem!
    
    /// The File/Import / Add menu item
    @IBOutlet weak var importAddMenuItem: NSMenuItem!
    
    /// The Collection/Export Metadata for all Manga menu item
    @IBOutlet weak var exportJsonForAllMangaMenuItem: NSMenuItem!
    
    /// The Komikan/Export Metadata for all Manga for Migration menu item
    @IBOutlet weak var exportJsonForAllMangaForMigrationMenuItem: NSMenuItem!
    
    /// The Manga/Magnification/Zoom In menu item
    @IBOutlet weak var readerZoomInMenuItem: NSMenuItem!
    
    /// The Manga/Magnification/Zoom Out menu item
    @IBOutlet weak var readerZoomOutMenuItem: NSMenuItem!
    
    /// The Manga/Magnification/Reset Zoom menu item
    @IBOutlet weak var readerResetZoomMenuItem: NSMenuItem!
    
    /// The Manga/Rotation/Rotate 90° Left menu item
    @IBOutlet weak var readerRotateNinetyDegressLeftMenuItem: NSMenuItem!
    
    /// The Manga/Rotation/Rotate 90° Right menu item
    @IBOutlet weak var readerRotateNinetyDegressRightMenuItem: NSMenuItem!
    
    /// The Manga/Rotation/Reset Rotation menu item
    @IBOutlet weak var readerResetRotationMenuItem: NSMenuItem!
    
    /// The Collection/Manage/Fetch Metadata For Selected menu item
    @IBOutlet weak var fetchMetadataForSelectedMenuItem: NSMenuItem!
    
    /// The Collection/Toggle List View menu item
    @IBOutlet weak var toggleListViewMenuItem: NSMenuItem!
    
    /// The Manga/Notes/View Notes menu item
    @IBOutlet weak var readerOpenNotesMenuItem: NSMenuItem!
    
    /// The Manga/Notes/Toggle Edit Bar menu item
    @IBOutlet weak var readerToggleNotesEditBarMenuItem: NSMenuItem!
    
    /// The Window/Select Search Field menu item
    @IBOutlet weak var selectSearchFieldMenuItem: NSMenuItem!
    
    /// The Manga/Notes/Open in External Editor menu item
    @IBOutlet weak var openInExternalEditorMenuItem: NSMenuItem!
    
    /// The File/Edit Selected menu item
    @IBOutlet weak var editSelectedMenuItem: NSMenuItem!
    
    /// The Window/Select Manga View menu item
    @IBOutlet weak var selectMangaViewMenuItem: NSMenuItem!
    
    /// The Collection/Import... menu item
    @IBOutlet weak var importMenuItem: NSMenuItem!
    
    /// The view controller we will load for the reader
    var mangaReaderViewController: KMReaderViewController?;
    
    /// The File/Hide Komikan Folders menu item
    @IBOutlet weak var hideKomikanFoldersMenuItem: NSMenuItem!
    
    /// The File/Show Komikan Folders menu item
    @IBOutlet weak var showKomikanFoldersMenuItem: NSMenuItem!
    
    /// The Collection/Group View menu item
    @IBOutlet weak var toggleGroupViewMenuItem: NSMenuItem!
    
    /// The grid controller for the manga grid
    var mangaGridController : KMMangaGridController = KMMangaGridController();
    
    /// The view controller for the main window
    var mainViewController : ViewController = ViewController();
    
    /// The search text field in the main window
    var searchTextField : NSTextField = NSTextField();
    
    /// The controller for the reader window
    var mangaReaderWindowController : NSWindowController!;
    
    /// The global preferences object
    var preferences : KMPreferencesObject = KMPreferencesObject();
    
    /// The window controller that lets the user darken everything behind the window
    var darkenBackgroundWindowController : NSWindowController!;
    
    /// The download controller for downloading from E-Hentai and ExHentai
    var ehDownloadController : KMEHDownloadController = KMEHDownloadController();
    
    /// An Int that indicates what modifier keys are being held(These are defined by NSEvent, not me)
    var modifierValue : Int = 0;
    
    // Opens the specified manga in the reader at the specified page
    func openManga(_ manga : KMManga, page : Int) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the reader
        mangaReaderWindowController = storyboard.instantiateController(withIdentifier: "reader") as? NSWindowController;
        
        // Get the view controller from the window
        mangaReaderViewController = (mangaReaderWindowController.contentViewController as? KMReaderViewController);
        
        // Tell the view controller to open the manga we passed at the page we passed
        mangaReaderViewController?.openManga(manga, page: page);
        
        // Present mangaReaderWindowController
        mangaReaderWindowController.showWindow(self);
    }
    
    /// Saves the preferences
    func savePreferences() {
        /// The data for the preferences object
        let data = NSKeyedArchiver.archivedData(withRootObject: preferences);
        
        // Set the standard user defaults preferences key to that data
        UserDefaults.standard.set(data, forKey: "preferences");
        
        // Synchronize the data
        UserDefaults.standard.synchronize();
    }
    
    /// Loads the preferences
    func loadPreferences() {
        // If we have any data to load...
        if let data = UserDefaults.standard.object(forKey: "preferences") as? Data {
            // Set the preferences object to the loaded object
            preferences = (NSKeyedUnarchiver.unarchiveObject(with: data) as! KMPreferencesObject);
        }
    }
    
    // Clears the cache
    func clearCache() {
        // Get everything in /tmp/komikan and delete it
        do {
            // Get all files in /tmp/komikan
            let files = try FileManager.default.contentsOfDirectory(atPath: "/tmp/komikan");
            
            // Delete all of them
            for (_, currentFile) in files.enumerated() {
                // Print to the log what we are removing
                print("AppDelegate: Deleting /tmp/komikan/" + currentFile);
                
                // Try to remove it
                try FileManager.default.removeItem(atPath: "/tmp/komikan/" + currentFile);
            }
            
            // If there is an error...
        } catch _ as NSError {
            // Print to the log that the cache is already cleared
            print("AppDelegate: Cache is already cleared");
        }
    }
    
    func actOnPreferences() {
        // Print to the log that we are acting upon preferences
        print("AppDelegate: Acting On Preferences");
        
        // Hide/show the Add From EH Menu Item depending on if we have l-lewd... mode enabled
        addFromEHMenuItem.isHidden = !preferences.llewdModeEnabled;
        
        // Set the distraction free mode dim amount
        backgroundDarkenAmount = preferences.distractionFreeModeDimAmount;
        
        // If we are in distraction free mode...
        if(backgroundDarkened) {
            // Double toggle distraction free mode so it matches the new darken amount
            toggleDarken();
            toggleDarken();
        }
        
        // Save the scroll position and selection in the grid
        mangaGridController.storeCurrentSelection();
        
        // Reload the filters in the grid
        mangaGridController.updateFilters();
        
        // Post the notification saying the preferences have been saved
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Application.PreferencesSaved"), object: nil);
        
        // Restore the scroll position and selection in the grid
        mangaGridController.restoreSelection();
    }
    
    // How much to darken the background
    var backgroundDarkenAmount : Double = 0.4;
    
    // Do we have the background darkened?
    var backgroundDarkened = false;
    
    func setupBackgroundDarkenWindow() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instantiate the window controller for darkening the background
        darkenBackgroundWindowController = storyboard.instantiateController(withIdentifier: "backgroundDarkenWindow") as? NSWindowController;
        
        // Set the darken background windows frame to be the same as the srceens frame
        darkenBackgroundWindowController.window?.setFrame(NSRect(x: 0, y: 0, width: (NSScreen.main()?.frame.width)!, height: (NSScreen.main()?.frame.height)!), display: false);
        
        // Allow the window to be transparent
        darkenBackgroundWindowController.window?.isOpaque = false;
        
        // Set the background color to black
        darkenBackgroundWindowController.window?.backgroundColor = NSColor.black;
        
        // Set the transpareny to something /comfy/
        darkenBackgroundWindowController.window?.alphaValue = CGFloat(backgroundDarkenAmount);
        
        // Make the window borderless
        darkenBackgroundWindowController.window?.styleMask.insert(NSBorderlessWindowMask);
        
        // Make it so you cant click the window
        darkenBackgroundWindowController.window?.ignoresMouseEvents = true;
        
        // Set the windows level
        darkenBackgroundWindowController.window?.level -= 1;
        
        // Fade out the darken. If you dont do this, the first time you toggle distraction free mode it will only show and not fade in
        // Make the darken window clear
        darkenBackgroundWindowController.window?.alphaValue = 0;
        
        // Close the darken window
        closeDarkenWindow();
    }
    
    func fadeInDarken() {
        // Order the window to show but not steal focus
        darkenBackgroundWindowController.window?.orderFrontRegardless();
        
        // Animate the window in
        darkenBackgroundWindowController.window?.animator().alphaValue = CGFloat(backgroundDarkenAmount);
        
        // If we said to hide the cursor in distraction free mode...
        if(preferences.hideCursorInDistractionFreeMode) {
            // Hide the cursor
            NSCursor.hide();
        }
    }
    
    func fadeOutDarken() {
        // Animate out the window
        darkenBackgroundWindowController.window?.animator().alphaValue = 0;
        
        // Wait for the animation to finish and hide the window
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(AppDelegate.closeDarkenWindow), userInfo: nil, repeats:false);
        
        // If we said to hide the cursor in distraction free mode...
        if(preferences.hideCursorInDistractionFreeMode) {
            // Show the cursor
            NSCursor.unhide();
        }
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
    
    func closeDarkenWindow() {
        // Order out the window
        darkenBackgroundWindowController.window?.orderBack(self);
    }
    
    func modifierKeyEventHandler(_ theEvent : NSEvent) -> NSEvent {
        // Set modifierValue to the raw modifier key values
        self.modifierValue = Int(theEvent.modifierFlags.rawValue);
        
        // Return the event(Required for some reason)
        return theEvent;
    }
    
    /// Does various initialization things, such as cache clearing, make sure there is an application support folder, load preferences, etc.
    func initialize() {
        // Make sure we have an application support folder
        _ = KMCommandUtilities().runCommand("/bin/mkdir", arguments: [NSHomeDirectory() + "/Library/Application Support/Komikan"], waitUntilExit: true);
        
        // Make sure we have a /tmp/komikan folder
        _ = KMCommandUtilities().runCommand("/bin/mkdir", arguments: ["/tmp/komikan"], waitUntilExit: true);
        
        // Clear the cache on load
        clearCache();
        
        // Load the preferences
        loadPreferences();
        
        // Act upon the loaded preferences
        actOnPreferences();
        
        // Setup the window thats lets us dim the background
        setupBackgroundDarkenWindow();
        
        // Setup the darken background menu items action
        toggleBackgroundDarkenMenuItem.action = #selector(AppDelegate.toggleDarken);
        
        /// Set the notification center delegate
        NSUserNotificationCenter.default.delegate = self;
        
        // Subscribe to the modifier key changed event
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: modifierKeyEventHandler);
    }
    
    internal func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Always show notifications from this app, even if it is frontmost
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        // Post the notification saying the app will quit
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Application.WillQuit"), object: nil);
        
        // Save the preferences
        savePreferences();
    }
}

