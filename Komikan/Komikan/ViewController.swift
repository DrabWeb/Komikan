//
//  ViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTabViewDelegate {
    
    // The main window of the application
    var window : NSWindow! = NSWindow();

    // The visual effect view for the main windows titlebar
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    // The visual effect view for the main windows background
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The collection view that manages displayig manga covers in the main window
    @IBOutlet weak var mangaCollectionView: NSCollectionView!
    
    // The array controller for the manga collection view
    @IBOutlet var mangaCollectionViewArray: NSArrayController!
    
    // The grid controller for the manga grid
    @IBOutlet var mangaGridController: KMMangaGridController!
    
    // The tab view for the titlebar that lets you sort
    @IBOutlet weak var titlebarTabView: NSTabView!
    
    // The search field in the titlebar
    @IBOutlet weak var titlebarSearchField: NSTextField!
    
    // When we finish editing the titlebarSearchField...
    @IBAction func titlebarSearchFieldInteracted(sender: AnyObject) {
        // Search for the passed string
        mangaGridController.searchFor((sender as? NSTextField)!.stringValue);
    }
    
    // The view controller we will load for the add manga popover
    var addMangaViewController: KMAddMangaViewController?
    
    // Is this the first time weve clicked on the add button in the titlebar?
    var addMangaViewFirstLoad : Bool = true;
    
    // The button in the titlebar that lets us add manga
    @IBOutlet weak var titlebarAddMangaButton: NSButton!
    
    // When we click titlebarAddMangaButton...
    @IBAction func titlebarAddMangaButtonInteracted(sender: AnyObject) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add manga view controller
        addMangaViewController = storyboard.instantiateControllerWithIdentifier("addMangaViewController") as? KMAddMangaViewController;
        
        // Present the addMangaViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addMangaViewController!.presentViewController(addMangaViewController!, asPopoverRelativeToRect: (sender as! NSButton).bounds, ofView: ((sender as? NSButton))!, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Semitransient);
        
        // If this is the first time we have pushed this button...
        if(addMangaViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMangaFromAddMangaPopover:", name:"KMAddMangaViewController.Finished", object: nil);
            
            // Say that all the next loads are not the first
            addMangaViewFirstLoad = false;
        }
    }
    
    // The tab view in the titlebar that lets us sort the manga grid
    @IBOutlet weak var titlebarSortingTabView: NSTabView!
    
    // Called when we hit "Add" in the addmanga popover
    func addMangaFromAddMangaPopover(notification: NSNotification) {
        // Print to the log that we are adding from the add popover
        print("Adding from the add popover...");
        
        // If we were passed an array of manga...
        if((notification.object as? [KMManga]) != nil) {
            print("Batch adding manga");
            
            for (_, currentManga) in ((notification.object as? [KMManga])?.enumerate())! {
                // Add the current manga to the grid
                mangaGridController.addManga(currentManga);
            }
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add Manga popover");
            
            // Add the manga to the grid
            mangaGridController.addManga((notification.object as? KMManga)!);
        }
        
        // Stop addMangaViewController.addButtonUpdateLoop, so it stops eating resources when it doesnt need to
        addMangaViewController?.addButtonUpdateLoop.invalidate();
        
        // Tell the manga grid to resort itself
        NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.Resort", object: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Style the window to be fancy
        styleWindow();
        
        // Set the collections views item prototype to the collection view item we created in Main.storyboard
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the addFromEHMenuItem's action
        (NSApplication.sharedApplication().delegate as! AppDelegate).addFromEHMenuItem.action = Selector("showAddFromEHPopover");
        
        // Start a 0.1 second loop that will fix the windows look in fullscreen
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
        
        // Set the titlebar tab views delegate to self
        titlebarTabView.delegate = self;
        
        // Load the manga we had in the grid
        loadManga();
        
        // Set the manga grid as the first responder
        window.makeFirstResponder(mangaCollectionView);
        
        // Set he delete all manga menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.deleteAllMangaMenuItem.action = Selector("deleteAllManga");
        
        // Sort the manga grid by the tab view item we have selected at start
        // If the tab view item we have selected is the Title sort one...
        if(titlebarTabView.selectedTabViewItem!.label == "Title") {
            // Sort the manga grid by title
            mangaGridController.sort(KMMangaGridSortType.Title, ascending: true);
        }
            // If the tab view item we have selected is the Series sort one...
        else if(titlebarTabView.selectedTabViewItem!.label == "Series") {
            // Sort the manga grid by series
            mangaGridController.sort(KMMangaGridSortType.Series, ascending: true);
        }
            // If the tab view item we have selected is the Artist sort one...
        else if(titlebarTabView.selectedTabViewItem!.label == "Artist") {
            // Sort the manga grid by artist
            mangaGridController.sort(KMMangaGridSortType.Artist, ascending: true);
        }
        
        // Subscribe to the edit manga popovers remove function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeSelectItemFromMangaGrid:", name:"KMEditMangaViewController.Remove", object: nil);
        
        // Subscribe to the global redraw manga grid function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMangaGrid", name:"ViewController.UpdateMangaGrid", object: nil);
    }
    
    // When changing the values, it doesnt update right. Call this function to reload it
    func updateMangaGrid() {
        // Redraw the collection view to match the updated content
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
    }
    
    // The view controller we will load for the add manga popover
    var addFromEHViewController: KMEHViewController?
    
    // Is this the first time weve clicked on the add button in the titlebar?
    var addFromEHViewFirstLoad : Bool = true;
    
    func showAddFromEHPopover() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add from eh view controller
        addFromEHViewController = storyboard.instantiateControllerWithIdentifier("addFromEHViewController") as? KMEHViewController;
        
        // Present the addFromEHViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addFromEHViewController!.presentViewController(addFromEHViewController!, asPopoverRelativeToRect: titlebarAddMangaButton.bounds, ofView: titlebarAddMangaButton, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Semitransient);
        
        // If this is the first time we have opened the popover...
        if(addFromEHViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMangaFromEHPopover:", name:"KMEHViewController.Finished", object: nil);
            
            // Say that all the next loads are not the first
            addFromEHViewFirstLoad = false;
        }
    }
    
    func addMangaFromEHPopover(notification : NSNotification) {
        // Print to the log that we are adding a manga from the EH popover
        print("Adding from EH...");
        
        // If we were passed an array of manga...
        if((notification.object as? [KMManga]) != nil) {
            print("Batch adding manga");
            
            for (_, currentManga) in ((notification.object as? [KMManga])?.enumerate())! {
                // Add the current manga to the grid
                mangaGridController.addManga(currentManga);
            }
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add From EH Manga popover");
            
            // Add the manga to the grid
            mangaGridController.addManga((notification.object as? KMManga)!);
        }
        
        // Stop the loop so we dont take up precious memory
        addFromEHViewController?.addButtonUpdateLoop.invalidate();
        
        // Tell the manga grid to resort itself
        NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.Resort", object: nil);
    }
    
    // Deletes all the manga in the manga grid array controller
    func deleteAllManga() {
        // Remove all the objects in mangaCollectionViewArray
        mangaCollectionViewArray.removeObjects(mangaCollectionViewArray.arrangedObjects as! [AnyObject]);
    }
    
    // Removes the selected item from the manga grid
    func removeSelectItemFromMangaGrid(notification : NSNotification) {
        // Print to the log that we are removing this manga
        print("Removing \"" + (notification.object as? KMManga)!.title + "\" from the manga grid");
        
        // If the manga is from EH ad we said in the preferences to delete them...
        if((notification.object as? KMManga)!.directory.containsString("/Library/Application Support/Komikan/EH") && (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.deleteLLewdMangaWhenRemovingFromTheGrid) {
            // Also delete the file
            do {
                // Try to delete the file at the mangas directory
                try NSFileManager.defaultManager().removeItemAtPath((notification.object as? KMManga)!.directory);
                
                // Print to the log that we deleted it
                print("Deleted manga \"" + (notification.object as? KMManga)!.title + "\"'s file");
            }
            // If there is an error...
            catch _ as NSError {
                // Do nothing
            }
        }
        
        // Remove this item from the collection view
        mangaCollectionViewArray.removeObjectsAtArrangedObjectIndexes(NSIndexSet(index: mangaCollectionView.selectionIndexes.lastIndex));
    }
    
    func styleWindow() {
        // Get a reference to the main window
        window = NSApplication.sharedApplication().windows.last!;
        
        // Set the main window to have a full size content view
        window.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        window.titlebarAppearsTransparent = true;
        
        // Hide the titlebar title
        window.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        // Set the backgrouynd effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        
        // Set the titlebar effect to be ultra dark
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
    }
    
    func deleteTitlebarInFullscreen() {
        // If the window is in fullscreen(Window height matches the screen height(This is really cheaty and I need to find a better way to do this))
        if(window.isFullscreen()) {
            // Hide the toolbar so we dont get a grey bar at the top
            window.toolbar?.visible = false;
        }
        else {
            // Show the toolbar again in non-fullscreen(So we still get the traffic lights in the right place)
            window.toolbar?.visible = true;
        }
    }
    
    // Saves the manga in the grid
    func saveManga() {
        // Create a NSKeyedArchiver data with the manga array controllers objects
        let data = NSKeyedArchiver.archivedDataWithRootObject(mangaCollectionViewArray.arrangedObjects);
        
        // Set the standard user defaults mangaArray key to that data
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "mangaArray");
        
        // Synchronize the data
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    // Load the saved manga back to the grid
    func loadManga() {
        // If we have any data to load...
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("mangaArray") as? NSData {
            // For every KMMangaGridItem in the saved manga grids items...
            for (_, currentManga) in (NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [KMMangaGridItem]).enumerate() {
                // Add the current object to the manga grid
                mangaCollectionViewArray.addObject(currentManga);
            }
        }
    }
    
    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        // If the tab view item we selected was the Title sort one...
        if(tabViewItem!.label == "Title") {
            // Sort the manga grid by title
            mangaGridController.sort(KMMangaGridSortType.Title, ascending: true);
        }
            // If the tab view item we selected was the Series sort one...
        else if(tabViewItem!.label == "Series") {
            // Sort the manga grid by series
            mangaGridController.sort(KMMangaGridSortType.Series, ascending: true);
        }
        // If the tab view item we selected was the Artist sort one...
        else if(tabViewItem!.label == "Artist") {
            // Sort the manga grid by artist
            mangaGridController.sort(KMMangaGridSortType.Artist, ascending: true);
        }
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewWillDisappear() {
        // Save the manga in the grid
        saveManga();
    }
}

