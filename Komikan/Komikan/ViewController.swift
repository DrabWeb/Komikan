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
    
    // The visual effect view for the info bottom bar
    @IBOutlet weak var infoBarVisualEffectView: NSVisualEffectView!
    
    // The container for the info bar
    @IBOutlet weak var infoBarContainer: NSView!
    
    // The label on the info bar that shows how many manga you have
    @IBOutlet weak var infoBarMangaCountLabel: NSTextField!
    
    // The collection view that manages displayig manga covers in the main window
    @IBOutlet weak var mangaCollectionView: NSCollectionView!
    
    // The scroll view for the manga collection view
    @IBOutlet weak var mangaCollectionViewScrollView: NSScrollView!
    
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
    
    // The disclosure button in the titlebatr that lets you ascend/descend the sort order of the manga grid
    @IBOutlet weak var titlebarToggleSortDirectionButton: NSButton!
    
    // When we interact with titlebarToggleSortDirectionButton...
    @IBAction func titlebarToggleSortDirectionButtonInteracted(sender: AnyObject) {
        // Resort the grid based on which direction we said to sort it in
        mangaGridController.sort(mangaGridController.currentSortOrder, ascending: Bool(titlebarToggleSortDirectionButton.state));
    }
    
    /// The button in the titlebar with the hamburger icon that lets us toggle the sidebar
    @IBOutlet weak var titlebarToggleSidebarButton: NSButton!
    
    /// When we interact with titlebarToggleSidebarButton...
    @IBAction func titlebarToggleSidebarButtonInteracted(sender: AnyObject) {
        // Toggle the sidebar
        sidebarController.toggleSidebar();
    }
    
    // The view controller we will load for the add manga popover
    var addMangaViewController: KMAddMangaViewController?
    
    /// The controller for the sidebar that lets us filter by groups
    @IBOutlet var sidebarController: KMSidebarController!
    
    // Is this the first time we've clicked on the add button in the titlebar?
    var addMangaViewFirstLoad : Bool = true;
    
    // The bool to say if we have the info bar showing
    var infoBarOpen : Bool = false;
    
    // Is the sidebar open?
    var sidebarOpen : Bool = false;
    
    // The button in the titlebar that lets us add manga
    @IBOutlet weak var titlebarAddMangaButton: NSButton!
    
    // When we click titlebarAddMangaButton...
    @IBAction func titlebarAddMangaButtonInteracted(sender: AnyObject) {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.MaxY);
    }
    
    // The tab view in the titlebar that lets us sort the manga grid
    @IBOutlet weak var titlebarSortingTabView: NSTabView!
    
    // Called when we hit "Add" in the addmanga popover
    func addMangaFromAddMangaPopover(notification: NSNotification) {
        // Print to the log that we are adding from the add popover
        print("Adding from the add popover...");
        
        // If we were passed an array of manga...
        if((notification.object as? [KMManga]) != nil) {
            // Print to the log that we are batch adding
            print("Batch adding manga");
            
            // For every manga in the notifications manga array...
            for (_, currentManga) in ((notification.object as? [KMManga])?.enumerate())! {
                // Add the current manga to the grid
                mangaGridController.addManga(currentManga, updateFilters: false);
            }
            
            // Create the new notification to tell the user the import has finished
            let finishedImportNotification = NSUserNotification();
            
            // Set the title
            finishedImportNotification.title = "Komikan";
            
            // Set the informative text
            finishedImportNotification.informativeText = "Finished importing \"" + (notification.object as? [KMManga])![0].series + "\"";
            
            // Set the notifications identifier to be an obscure string, so we can show multiple at once
            finishedImportNotification.identifier = NSUUID().UUIDString;
            
            // Deliver the notification
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedImportNotification);
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add Manga popover");
            
            // Add the manga to the grid, and store the item in a new variable
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
        }
        
        // Stop addMangaViewController.addButtonUpdateLoop, so it stops eating resources when it doesnt need to
        addMangaViewController?.addButtonUpdateLoop.invalidate();
        
        // Reload the filters
        mangaGridController.reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Style the window to be fancy
        styleWindow();
        
        // Hide the window so we dont see any ugly loading "artifacts"
        window.alphaValue = 0;
        
        // Set the collections views item prototype to the collection view item we created in Main.storyboard
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the addFromEHMenuItem menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).addFromEHMenuItem.action = Selector("showAddFromEHPopover");
        
        // Set the toggle info bar menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).toggleInfoBarMenuItem.action = Selector("toggleInfoBar");
        
        // Set the delete selected manga menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).deleteSelectedMangaMenuItem.action = Selector("removeSelectedItemsFromMangaGrid");
        
        // Set the mark selected manga as read menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).markSelectedAsReadMenuItem.action = Selector("markSelectedItemsAsRead");
        
        // Set the delete all manga menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.deleteAllMangaMenuItem.action = Selector("deleteAllManga");
        
        // Set the add / import manga menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.importAddMenuItem.action = Selector("showAddImportPopoverMenuItem");
        
        // Set the toggle sidebar menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.toggleSidebarMenuItem.action = Selector("toggleSidebar");
        
        // Set the set selected manga's group menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.setGroupForSelectedMenuItem.action = Selector("setSelectedMangaGroup");
        
        // Start a 0.1 second loop that will fix the windows look in fullscreen
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
        
        // Set the app delegates sidebar controller
        (NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController = sidebarController;
        
        // Set the titlebar tab views delegate to self
        titlebarTabView.delegate = self;
        
        // Load the manga we had in the grid
        loadManga();
        
        // Load the sidebar items
        sidebarController.loadSidebar();
        
        // Scroll to the top of the manga grid
        mangaCollectionViewScrollView.pageUp(self);
        
        // Select the manga grid
        makeMangaGridFirstResponder();
        
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
        
        // Create some options for the manga grid KVO
        let options = NSKeyValueObservingOptions([.New, .Old, .Initial, .Prior]);
        
        // Subscribe to when the manga grid changes its values in any way
        mangaGridController.arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: options, context: nil);
        
        // Show the window after 0.1 seconds
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("showWindowAlpha"), userInfo: nil, repeats: false);
        
        // Subscribe to the edit manga popovers remove notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeSelectItemFromMangaGrid:", name:"KMEditMangaViewController.Remove", object: nil);
        
        // Subscribe to the global redraw manga grid notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMangaGrid", name:"ViewController.UpdateMangaGrid", object: nil);
        
        // Subscribe to the global application will quit notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveManga", name:"Application.WillQuit", object: nil);
        
        // Subscribe to the ViewController.SelectMangaGrid
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "makeMangaGridFirstResponder", name:"ViewController.SelectMangaGrid", object: nil);
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // If the keyPath is the one for the manga grids arranged objets...
        if(keyPath == "arrangedObjects") {
            // Update the manga count in the info bar
            updateInfoBarMangaCountLabel();
        }
    }
    
    /// The view controller for the mass set selected manga's group popover
    var massSetGroupViewController : NSViewController = NSViewController();
    
    /// Is this the ifrst time going through setSelectedMangaGroup?
    var massSetGroupViewFirstLoad : Bool = false;
    
    /// Sets the selected manga's group
    func setSelectedMangaGroup() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the mass set group view controller
        massSetGroupViewController = (storyboard.instantiateControllerWithIdentifier("massSetGroupViewController") as? KMMassSetGroupViewController)!;
        
        // Present the massSetGroupViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        massSetGroupViewController.presentViewController(massSetGroupViewController, asPopoverRelativeToRect: NSRect(x: 0, y: 0, width: window.contentView!.bounds.width, height: window.contentView!.bounds.height / 2), ofView: backgroundVisualEffectView, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Semitransient);
        
        // If this is the first time we have called this function...
        if(massSetGroupViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveFromSetSelectedMangaGroup:", name:"KMMassSetGroupViewController.Finished", object: nil);
            
            // Say that all the next loads are not the first
            massSetGroupViewFirstLoad = false;
        }
    }
    
    func receiveFromSetSelectedMangaGroup(notification : NSNotification) {
    
    }
    
    /// Just a wrapper for the menu item to toggle the sidebar
    func toggleSidebar() {
        // Toggle the sidebar
        sidebarController.toggleSidebar();
    }
    
    /// Shows the add / import popover, without passing variables for the menu item
    func showAddImportPopoverMenuItem() {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.MaxY);
    }
    
    /// Shows the add / import popover with the origin rect as where the arrow comes from, and the preferredEdge as to which side to come from
    func showAddImportPopover(origin : NSRect, preferredEdge : NSRectEdge) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add manga view controller
        addMangaViewController = storyboard.instantiateControllerWithIdentifier("addMangaViewController") as? KMAddMangaViewController;
        
        // Present the addMangaViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addMangaViewController!.presentViewController(addMangaViewController!, asPopoverRelativeToRect: origin, ofView: titlebarAddMangaButton, preferredEdge: preferredEdge, behavior: NSPopoverBehavior.Semitransient);
        
        // If this is the first time we have pushed this button...
        if(addMangaViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMangaFromAddMangaPopover:", name:"KMAddMangaViewController.Finished", object: nil);
            
            // Say that all the next loads are not the first
            addMangaViewFirstLoad = false;
        }
    }
    
    func showWindowAlpha() {
        // Set the windows alpha value to 1
        window.alphaValue = 1;
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
                mangaGridController.addManga(currentManga, updateFilters: false);
            }
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add From EH Manga popover");
            
            // Add the manga to the grid
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
        }
        
        // Reload the filters
        mangaGridController.reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
        
        // Stop the loop so we dont take up precious memory
        addFromEHViewController?.addButtonUpdateLoop.invalidate();
    }
    
    /// Makes the manga grid the first responder
    func makeMangaGridFirstResponder() {
        // Set the manga grid as the first responder
        window.makeFirstResponder(mangaCollectionView);
    }
    
    // Deletes all the manga in the manga grid array controller
    func deleteAllManga() {
        // Remove all the objects from the collection view
        mangaGridController.removeAllGridItems(true);
    }
    
    // Removes the selected item from the manga grid
    func removeSelectItemFromMangaGrid(notification : NSNotification) {
        // Print to the log that we are removing this manga
        print("Removing \"" + (notification.object as? KMManga)!.title + "\" from the manga grid");
        
        // Remove this item from the collection view
        mangaGridController.removeGridItem((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![mangaCollectionView.selectionIndexes.lastIndex], resort: true);
    }
    
    /// Removes all the selected manga in the grid(Use this for multiple)
    func removeSelectedItemsFromMangaGrid() {
        // Print to the lgo that we are removing multiple manga from the grid
        print("Removing multiple manga from the grid");
        
        /// The manga grid items that we want to remove
        var selectionItemsToRemove : [KMMangaGridItem] = [];
        
        // This breaks because the indexes change during the for loop, and it then gets items it shouldnt.
        for(_, currentIndex) in mangaCollectionView.selectionIndexes.enumerate() {
            selectionItemsToRemove.append((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![currentIndex]);
        }
        
        // For every item in the manga ggrid items we want to remove...
        for(_, currentItem) in selectionItemsToRemove.enumerate() {
            // Remove the curent item from the grid, with resorting
            mangaGridController.removeGridItem(currentItem, resort: true);
        }
        
        // Deselect all the items
        mangaCollectionView.deselectAll(self);
    }
    
    /// Removes all the selected manga in the grid(Use this for multiple)
    func markSelectedItemsAsRead() {
        // Print to the lgo that we are removing multiple manga from the grid
        print("Marking multiple manga as read from the grid");
        
        /// The manga grid items that we want to mark as read
        var selectionItemsToMarkAsRead : [KMMangaGridItem] = [];
        
        // This breaks because the indexes change during the for loop, and it then gets items it shouldnt.
        for(_, currentIndex) in mangaCollectionView.selectionIndexes.enumerate() {
            selectionItemsToMarkAsRead.append((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![currentIndex]);
        }
        
        // For every item in the manga grid that we want to mark as read...
        for(_, currentItem) in selectionItemsToMarkAsRead.enumerate() {
            // Mark the current manga as read
            currentItem.manga.read = true;
            
            // Update the current manga's percent finished
            currentItem.manga.updatePercent();
        }
        
        // Deselect all the items
        mangaCollectionView.deselectAll(self);
        
        // Update the grid
        updateMangaGrid();
    }
    
    func toggleInfoBar() {
        // Set infoBarOpen to the opposite of its current value
        infoBarOpen = !infoBarOpen;
        
        // If the info bar is now open...
        if(infoBarOpen) {
            // Fade it in
            infoBarContainer.animator().alphaValue = 1;
        }
        // If the info bar is now closed...
        else {
            // Fade it out
            infoBarContainer.animator().alphaValue = 0;
        }
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
        
        // Set the background visual effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        
        // Set the titlebar visual effect view to be ultra dark
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
        
        // Set the info visual effect view to be ultra dark
        infoBarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
        
        // Hide the info bar
        infoBarContainer.alphaValue = 0;
    }
    
    func deleteTitlebarInFullscreen() {
        // If the window is in fullscreen(Window height matches the screen height(This is really cheaty and I need to find a better way to do this))
        if(window.isFullscreen()) {
            // Hide the toolbar so we dont get a grey bar at the top
            window.toolbar?.visible = false;
            
            // If the toggle sidebar button is not already moved...
            if(titlebarToggleSidebarButton.frame.origin != NSPoint(x: 2, y: 1)) {
                // Move the sidebar toggle button to the edge of the toolbar to fit in fullscreen
                titlebarToggleSidebarButton.setFrameOrigin(NSPoint(x: 2, y: 1));
            }
        }
        else {
            // Show the toolbar again in non-fullscreen(So we still get the traffic lights in the right place)
            window.toolbar?.visible = true;
            
            // If the toggle sidebar button is not already moved...
            if(titlebarToggleSidebarButton.frame.origin != NSPoint(x: 72, y: 1)) {
                // Move the sidebar toggle button to the edge of the traffic lights so it fits in the right place
                titlebarToggleSidebarButton.setFrameOrigin(NSPoint(x: 72, y: 1));
            }
        }
    }
    
    func updateInfoBarMangaCountLabel() {
        // Set the manga count labels label to the manga count awith "Manga" on the end
        infoBarMangaCountLabel.stringValue = String(mangaGridController.arrayController.arrangedObjects.count) + " Manga";
    }
    
    // Saves the manga in the grid
    func saveManga() {
        // Create a NSKeyedArchiver data with the manga grid controllers grid items
        let data = NSKeyedArchiver.archivedDataWithRootObject(mangaGridController.gridItems);
        
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
                mangaGridController.addGridItem(currentManga);
            }
        }
        
        // Update the grid
        updateMangaGrid();
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
        // Save the sidebar items
        sidebarController.saveSidebar();
    }
}

