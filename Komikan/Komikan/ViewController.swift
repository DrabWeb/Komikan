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
    
    /// The list controller for the manga list
    @IBOutlet var mangaListController: KMMangaListController!
    
    /// The table view the user can switch to to see their manga in a list instead of a grid
    @IBOutlet var mangaTableView: NSTableView!
    
    /// The scroll view for mangaTableView
    @IBOutlet var mangaTableViewScrollView: NSScrollView!
    
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
    
    // The view controller we will load for the add manga popover
    var addMangaViewController: KMAddMangaViewController?
    
    // Is this the first time we've clicked on the add button in the titlebar?
    var addMangaViewFirstLoad : Bool = true;
    
    // The bool to say if we have the info bar showing
    var infoBarOpen : Bool = false;
    
    /// The slider in the info bar that lets us set the size of the grid items
    @IBOutlet weak var infoBarGridSizeSlider: NSSlider!
    
    /// When the value for infoBarGridSizeSlider changes...
    @IBAction func infoBarGridSizeSliderInteracted(sender: AnyObject) {
        // Set the manga collection view's item size to the sliders value(For both width and height so we get a square)
        mangaCollectionView.minItemSize = NSSize(width: infoBarGridSizeSlider.integerValue, height: infoBarGridSizeSlider.integerValue);
    }
    
    // Is the sidebar open?
    var sidebarOpen : Bool = false;
    
    // The button in the titlebar that lets us add manga
    @IBOutlet weak var titlebarAddMangaButton: NSButton!
    
    // When we click titlebarAddMangaButton...
    @IBAction func titlebarAddMangaButtonInteracted(sender: AnyObject) {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.MaxY, fileUrls: []);
    }
    
    // The tab view in the titlebar that lets us sort the manga grid
    @IBOutlet weak var titlebarSortingTabView: NSTabView!
    
    /// The button in the titlebar that lets us toggle between list and grid view
    @IBOutlet var titlebarToggleListViewCheckbox: NSButton!
    
    /// When we interact with titlebarToggleListViewCheckbox...
    @IBAction func titlebarToggleListViewCheckboxAction(sender: AnyObject) {
        // Toggle the view we are in(List or grid)
        toggleView();
    }
    
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
            
            // Reload the l-lewd... manga filter
            mangaGridController.displayLewdMangaAppDelegate();
            
            // If we are searching
            if(mangaGridController.searching) {
                // Redo the search so if the item doesnt match the query it gets hidden
                mangaGridController.searchFor(mangaGridController.lastSearchText);
            }
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add Manga popover");
            
            // Add the manga to the grid, and store the item in a new variable
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
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
        
        // Hide the window so we dont see any ugly loading "artifacts"
        window.alphaValue = 0;
        
        // Set the collections views item prototype to the collection view item we created in Main.storyboard
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the max item size
        mangaCollectionView.maxItemSize = NSSize(width: 300, height: 300);
        
        // Set the addFromEHMenuItem menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).addFromEHMenuItem.action = Selector("showAddFromEHPopover");
        
        // Set the toggle info bar menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).toggleInfoBarMenuItem.action = Selector("toggleInfoBar");
        
        // Set the delete selected manga menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).deleteSelectedMangaMenuItem.action = Selector("removeSelectedItemsFromMangaGrid");
        
        // Set the mark selected manga as read menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).markSelectedAsReadMenuItem.action = Selector("markSelectedItemsAsRead");
        
        // Set the mark selected manga as unread menu items action
        (NSApplication.sharedApplication().delegate as! AppDelegate).markSelectedAsUnreadMenuItem.action = Selector("markSelectedItemsAsUnread");
        
        // Set the delete all manga menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.deleteAllMangaMenuItem.action = Selector("deleteAllManga");
        
        // Set the add / import manga menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.importAddMenuItem.action = Selector("showAddImportPopoverMenuItem");
        
        // Set the set selected items properties menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.setSelectedItemsPropertiesMenuItems.action = Selector("showSetSelectedItemsPropertiesPopover");
        
        // Set the export manga JSON menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.exportJsonForAllMangaMenuItem.action = Selector("exportMangaJSONForSelected");
        
        // Set the export manga JSON for migration menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.exportJsonForAllMangaForMigrationMenuItem.action = Selector("exportMangaJSONForMigration");
        
        // Set the fetch metadata for selected menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.fetchMetadataForSelectedMenuItem.action = Selector("showFetchMetadataForSelectedItemsPopoverAtCenter");
        
        // Set the toggle list view menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.toggleListViewMenuItem.action = Selector("toggleView");
        
        // Set the open menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.openMenuItem.action = Selector("openSelectedManga");
        
        // Set the select search field menubar items action
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.selectSearchFieldMenuItem.action = Selector("selectSearchField");
        
        // Start a 0.1 second loop that will fix the windows look in fullscreen
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
        
        // Set the AppDelegate's manga grid controller
        (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController = mangaGridController;
        
        // Set the AppDelegate's search text field
        (NSApplication.sharedApplication().delegate as! AppDelegate).searchTextField = titlebarSearchField;
        
        // Set the titlebar tab views delegate to self
        titlebarTabView.delegate = self;
        
        // Load the manga we had in the grid
        loadManga();
        
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
        
        // Subscribe to the magnify event
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.EventMaskMagnify, handler: magnifyEvent);
        
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
        
        // Subscribe to the global application will quit notification with the manga grid scale
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveMangaGridScale", name:"Application.WillQuit", object: nil);
        
        // Subscribe to the Drag and Drop add / import notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAddImportPopoverDragAndDrop:", name:"MangaGrid.DropFiles", object: nil);
        
        // Subscribe to the application's preferences saved notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadPreferenceValues", name:"Application.PreferencesLoaded", object: nil);
        
//        let regexTextString : String = "Credits.jpg";
//        let regexPattern : String = "\\w*jpg\\b";
//        
//        if let range = regexTextString.rangeOfString(regexPattern, options: .RegularExpressionSearch) {
//            let found = regexTextString.substringWithRange(range);
//            print("Found \(found)");
//        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // If the keyPath is the one for the manga grids arranged objets...
        if(keyPath == "arrangedObjects") {
            // Update the manga count in the info bar
            updateInfoBarMangaCountLabel();
            
            // Reload the manga table so it gets updated when items change
            mangaListController.mangaListTableView.reloadData();
        }
    }
    
    /// Opens the selected manga in the reader(If in list view it selects the first one and opens that)
    func openSelectedManga() {
        // If we are in list view...
        if(inListView) {
            // Open the first selected manga
            mangaListController.openManga();
        }
        // If we are in grid view...
        else {
            // For every selection index...
            for(_, currentSelectionIndex) in selectedItemIndexes().enumerate() {
                // Get the KMMangaGridCollectionItem at the current selection index and open it in the reader
                (mangaCollectionView.itemAtIndex(currentSelectionIndex) as? KMMangaGridCollectionItem)!.openManga();
            }
        }
    }
    
    /// Makes the search field frontmost
    func selectSearchField() {
        // Make the search field frontmost
        window.makeFirstResponder(titlebarSearchField);
    }
    
    /// Are we in list view?
    var inListView : Bool = false;
    
    /// The sort descriptors that were in the manga grid before we switched to table view
    var oldGridSortDescriptors : [NSSortDescriptor] = [];
    
    /// Toggles between list and grid view
    func toggleView() {
        // Toggle in list view
        inListView = !inListView;
        
        // If we are now in list view...
        if(inListView) {
            // Display list view
            displayListView();
        }
        // If we are now in grid view...
        else {
            // Display grid view
            displayGridView();
        }
    }
    
    /// Switches from the grid view to the table view
    func displayListView() {
        // Print to the log that we are going into list view
        print("Switching to list view");
        
        // Say we are in list view
        inListView = true;
        
        // Store the current sort descriptors
        oldGridSortDescriptors = mangaGridController.arrayController.sortDescriptors;
        
        // Change the toggle list view button to show the list icon
        titlebarToggleListViewCheckbox.state = 1;
        
        // Deselect all the items in the grid and list
        mangaCollectionView.deselectAll(self);
        mangaTableView.deselectAll(self);
        
        // Redraw the table view graphically so we dont get artifacts
        mangaTableViewScrollView.needsDisplay = true;
        mangaTableView.needsDisplay = true;
        
        // Show the list view
        mangaTableViewScrollView.hidden = false;
        
        // Hide the grid view
        mangaCollectionViewScrollView.hidden = true;
        
        // Fade out the manga grid only titlebar items
        titlebarSortingTabView.animator().alphaValue = 0;
        titlebarToggleSortDirectionButton.animator().alphaValue = 0;
    }
    
    /// Switches from the table view to the grid view
    func displayGridView() {
        // Print to the log that we are going into grid view
        print("Switching to grid view");
        
        // Say we arent in list view
        inListView = false;
        
        // Restore the old sort descriptors
        mangaGridController.arrayController.sortDescriptors = oldGridSortDescriptors;
        
        // Change the toggle list view button to show the grid icon
        titlebarToggleListViewCheckbox.state = 0;
        
        // Deselect all the items in the grid and list
        mangaCollectionView.deselectAll(self);
        mangaTableView.deselectAll(self);
        
        // Redraw the grid view graphically so we dont get artifacts
        mangaCollectionView.needsDisplay = true;
        mangaCollectionViewScrollView.needsDisplay = true;
        
        // Hide the list view
        mangaTableViewScrollView.hidden = true;
        
        // Show the grid view
        mangaCollectionViewScrollView.hidden = false;
        
        // Fade in the manga grid only titlebar items
        titlebarSortingTabView.animator().alphaValue = 1;
        titlebarToggleSortDirectionButton.animator().alphaValue = 1;
    }
    
    /// Returns the indexes of the selected manga items
    func selectedItemIndexes() -> NSIndexSet {
        /// The indexes of the selected manga items
        var selectionIndexes : NSIndexSet = NSIndexSet();
        
        // If we are in list view...
        if(inListView) {
            // Set selection indexes to the manga lists selected rows
            selectionIndexes = mangaTableView.selectedRowIndexes;
        }
        // If we are in grid view...
        else {
            // Set selection indexes to the manga grids selection indexes
            selectionIndexes = mangaCollectionView.selectionIndexes;
        }
        
        // Return the selection indexes
        return selectionIndexes;
    }
    
    /// Returns the count of how many manga items we have selected
    func selectedItemCount() -> Int {
        /// The amount of selected items
        var selectedCount : Int = 0;
        
        // If we are in list view...
        if(inListView) {
            // Set selected count to the amount of selected rows in the manga list
            selectedCount = mangaTableView.selectedRowIndexes.count;
        }
        // If we are in grid view...
        else {
            // Set selected count to the amount of selected items in the manga grid
            selectedCount = mangaCollectionView.selectionIndexes.count;
        }
        
        // Return the selected count
        return selectedCount;
    }
    
    /// Returns the selected KMMangaGridItem manga item
    func selectedGridItems() -> [KMMangaGridItem] {
        /// The selected KMMangaGridItem from the manga grid
        var selectedGridItems : [KMMangaGridItem] = [];
        
        // For every selection index of the manga grid...
        for(_, currentIndex) in selectedItemIndexes().enumerate() {
            // Add the item at the set index to the selected items
            selectedGridItems.append((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![currentIndex]);
        }
        
        // Return the selected grid items
        return selectedGridItems;
    }
    
    /// Returns the KMManga of the selected KMMangaGridItem manga item
    func selectedGridItemManga() -> [KMManga] {
        /// The selected KMManga from the manga grid
        var selectedManga : [KMManga] = [];
        
        // For every item in the selected grid items...
        for(_, currentGridItem) in selectedGridItems().enumerate() {
            // Add the current grid item's manga to the selected manga
            selectedManga.append(currentGridItem.manga);
        }
        
        // Return the selected manga
        return selectedManga;
    }
    
    /// Called when the user does a magnify gesture on the trackpad
    func magnifyEvent(event : NSEvent) -> NSEvent {
        // Add the magnification amount to the grid size slider
        infoBarGridSizeSlider.floatValue += Float(event.magnification);
        
        // Update the grid scale
        infoBarGridSizeSliderInteracted(infoBarGridSizeSlider);
        
        // Return the event
        return event;
    }
    
    /// Called after AppDelegate has loaded the preferences from the preferences file
    func loadPreferenceValues() {
        // Load the manga grid scale
        infoBarGridSizeSlider.integerValue = (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.mangaGridScale;
        
        // Update the grid size with the grid size slider
        infoBarGridSizeSliderInteracted(infoBarGridSizeSlider);
    }
    
    /// Saves the scale of the manga grid
    func saveMangaGridScale() {
        // Save the manga grid scale into AppDelegate
        (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.mangaGridScale = infoBarGridSizeSlider.integerValue;
    }
    
    /// Exports JSON for all the selected manga in the grid without internal information
    func exportMangaJSONForSelected() {
        // Print to the log that we are exporting metadata for selected manga
        print("Exporting JSON metadata for selected manga");
        
        /// The selected KMManga in the grid
        let selectedManga : [KMManga] = selectedGridItemManga();
        
        // For every selected manga...
        for(_, currentManga) in selectedManga.enumerate() {
            // Export the current manga's JSON
            KMFileUtilities().exportMangaJSON(currentManga, exportInternalInfo: false);
        }
        
        // Create the new notification to tell the user the Metadata exporting has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finshed exporting Metadata";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        finishedNotification.identifier = NSUUID().UUIDString;
        
        // Deliver the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
    }
    
    /// Exports JSON for all the manga in the grid with internal information(Meant for when the user switches computers or something and wants to keep metadata)
    func exportMangaJSONForMigration() {
        // Call the export JSON function from the grid controller and say to also do internal information
        mangaGridController.exportAllMangaJSON(true);
    }
    
    /// The view controller that will load for the metadata fetching popover
    var fetchMetadataViewController: KMMetadataFetcherViewController?
    
    // Is this the first time opened the fetch metadata popover?
    var fetchMetadataViewFirstLoad : Bool = true;
    
    /// Shows the fetch metadata popover at the given rect on the given side
    func showFetchMetadataForSelectedItemsPopover(relativeToRect: NSRect, preferredEdge: NSRectEdge) {
        // If there are any selected manga...
        if(selectedItemCount() != 0) {
            // Get the main storyboard
            let storyboard = NSStoryboard(name: "Main", bundle: nil);
            
            // Instanstiate the view controller for the fetch metadata popover
            fetchMetadataViewController = storyboard.instantiateControllerWithIdentifier("metadataFetcherViewController") as? KMMetadataFetcherViewController;
            
            // Set the fetch metadata popover's selected manga
            fetchMetadataViewController?.selectedMangaGridItems = selectedGridItems();
            
            // Present the fetchMetadataViewController as a popover at the given relative rect on the given preferred edge
            fetchMetadataViewController!.presentViewController(fetchMetadataViewController!, asPopoverRelativeToRect: relativeToRect, ofView: backgroundVisualEffectView, preferredEdge: preferredEdge, behavior: NSPopoverBehavior.Transient);
            
            // If this is the first time we have opened the popover...
            if(fetchMetadataViewFirstLoad) {
                // Subscribe to the popovers finished notification
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchMetadataForSelectedItemsPopoverFinished:", name:"KMMetadataFetcherViewController.Finished", object: nil);
                
                // Say that all the next loads are not the first
                fetchMetadataViewFirstLoad = false;
            }
        }
    }
    
    /// Calls showFetchMetadataForSelectedItemsPopover so it opens in the center
    func showFetchMetadataForSelectedItemsPopoverAtCenter() {
        // Show the fetch metadata popover in the center of the window with the arrow pointing down
        showFetchMetadataForSelectedItemsPopover(NSRect(x: 0, y: 0, width: window.contentView!.bounds.width, height: window.contentView!.bounds.height / 2), preferredEdge: NSRectEdge.MaxY);
    }
    
    /// Called when the fetch metadata for selected manga popover is done
    func fetchMetadataForSelectedItemsPopoverFinished(notification : NSNotification) {
        // Update the manga
        updateMangaGrid();
        
        // Reload the manga list
        mangaTableView.reloadData();
    }
    
    /// The view controller we will load for the popover that lets us set the selected items properties(Artist, Group, ETC.)
    var setSelectedItemsPropertiesViewController: KMSetSelectedItemsPropertiesViewController?
    
    // Is this the first time opened the set selected items properties popover?
    var setSelectedItemsPropertiesViewFirstLoad : Bool = true;
    
    /// Shows the set selected items properties popover
    func showSetSelectedItemsPropertiesPopover() {
        // If there are any selected manga...
        if(selectedItemCount() != 0) {
            // Get the main storyboard
            let storyboard = NSStoryboard(name: "Main", bundle: nil);
            
            // Instanstiate the view controller for the set selected items properties popover
            setSelectedItemsPropertiesViewController = storyboard.instantiateControllerWithIdentifier("setSelectedItemsPropertiesViewController") as? KMSetSelectedItemsPropertiesViewController;
            
            // Present the setSelectedItemsPropertiesViewController as a popover so it is in the center of the window and the arrow is pointing down
            setSelectedItemsPropertiesViewController!.presentViewController(setSelectedItemsPropertiesViewController!, asPopoverRelativeToRect: NSRect(x: 0, y: 0, width: window.contentView!.bounds.width, height: window.contentView!.bounds.height / 2), ofView: backgroundVisualEffectView, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Transient);
            
            // If this is the first time we have opened the popover...
            if(setSelectedItemsPropertiesViewFirstLoad) {
                // Subscribe to the popovers finished notification
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "setSelectedItemsProperties:", name:"KMSetSelectedItemsPropertiesViewController.Finished", object: nil);
                
                // Say that all the next loads are not the first
                setSelectedItemsPropertiesViewFirstLoad = false;
            }
        }
    }
    
    /// Called by the set selected items properties popover to apply the given values to the selected items
    func setSelectedItemsProperties(notification : NSNotification) {
        // Print to the log thatr we are setting the selected items properties
        print("Setting selected items properties to properties from popover");
        
        /// The manga grid items that we want to set properties of
        let selectionItemsToSetProperties : [KMMangaGridItem] = selectedGridItems();
        
        // Get the notification object as a KMSetSelectedPropertiesHolder
        let propertiesHolder : KMSetSelectedPropertiesHolder = (notification.object as! KMSetSelectedPropertiesHolder);
        
        // For every item in the manga grid that we set the properties of...
        for(_, currentItem) in selectionItemsToSetProperties.enumerate() {
            // Apply the propertie holders values to the current item
            propertiesHolder.applyValuesToManga(currentItem.manga);
        }
        
        // Deselect all the items
        mangaCollectionView.deselectAll(self);
        
        // Resort the grid
        mangaGridController.resort();
    }
    
    /// Shows the add / import popover, without passing variables for the menu item
    func showAddImportPopoverMenuItem() {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.MaxY, fileUrls: []);
    }
    
    /// Shows the add / import popover with the passed notifications object(Should be a list of file URL strings)(Used only by drag and drop import)
    func showAddImportPopoverDragAndDrop(notification : NSNotification) {
        /// The file URLs we will pass to the popover
        var fileUrls : [NSURL] = [];
        
        // For every item in the notifications objects(As a list of strings)...
        for(_, currentStringURL) in (notification.object as! [String]).enumerate() {
            /// The NSURL of the current file
            let currentFileURL : NSURL = NSURL(fileURLWithPath: currentStringURL);
            
            /// The extension of the current file
            let currentFileExtension : String = KMFileUtilities().getFileExtension(currentFileURL);
            
            // If the extension is supported(CBZ, CBR, ZIP or RAR)...
            if(currentFileExtension == "cbz" || currentFileExtension == "cbr" || currentFileExtension == "zip" || currentFileExtension == "rar") {
                // Append the current file URL to the array of files we will pass to the popover
                fileUrls.append(currentFileURL);
            }
            // If the extension is unsupported...
            else {
                // Print to the log that it is unsupported and what the extension is
                print("Unsupported file extension \"" + currentFileExtension + "\"");
            }
        }
        
        // If there were any files that matched the extension...
        if(fileUrls != []) {
            // Show the add / import popover under the add button with the file URLs we dragged in
            showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.MaxY, fileUrls: fileUrls);
        }
    }
    
    /// Shows the add / import popover with the origin rect as where the arrow comes from, and the preferredEdge as to which side to come from. Also if fileUrls is not [], it will not show the file choosing dialog and go staright to the properties popover with the passed file URLs
    func showAddImportPopover(origin : NSRect, preferredEdge : NSRectEdge, fileUrls : [NSURL]) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add manga view controller
        addMangaViewController = storyboard.instantiateControllerWithIdentifier("addMangaViewController") as? KMAddMangaViewController;
        
        // Set the add manga view controllers add manga file URLs that we were passed
        addMangaViewController!.addingMangaURLs = fileUrls;
        
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
            
            // Reload the l-lewd... manga filter
            mangaGridController.displayLewdMangaAppDelegate();
            
            // If we are searching
            if(mangaGridController.searching) {
                // Redo the search so if the item doesnt match the query it gets hidden
                mangaGridController.searchFor(mangaGridController.lastSearchText);
            }
        }
        else {
            // Print to the log that we have recieved it and its name
            print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add From EH Manga popover");
            
            // Add the manga to the grid
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
        }
        
        // Stop the loop so we dont take up precious memory
        addFromEHViewController?.addButtonUpdateLoop.invalidate();
        
        // Tell the manga grid to resort itself
        NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.Resort", object: nil);
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
    
    // Removes the last selected manga item
    func removeSelectItemFromMangaGrid(notification : NSNotification) {
        // Print to the log that we are removing this manga
        print("Removing \"" + (notification.object as? KMManga)!.title + "\" manga item");
        
        // Remove this item from the grid controller
        mangaGridController.removeGridItem((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![selectedItemIndexes().lastIndex], resort: true);
    }
    
    /// Removes all the selected manga items(Use this for multiple)
    func removeSelectedItemsFromMangaGrid() {
        // Print to the log that we are removing the selected manga items
        print("Removing selected manga items");
        
        /// The manga grid items that we want to remove
        let selectionItemsToRemove : [KMMangaGridItem] = selectedGridItems();
        
        // For every item in the manga grid items we want to remove...
        for(_, currentItem) in selectionItemsToRemove.enumerate() {
            // Remove the curent item from the grid, with resorting
            mangaGridController.removeGridItem(currentItem, resort: true);
        }
    }
    
    /// Marks the selected manga items as unread
    func markSelectedItemsAsUnread() {
        // Print to the log that we are marking the selected items as unread
        print("Marking selected manga items as unread");
        
        /// The selected manga items that we will mark as read
        let selectionItemsToMarkAsUnread : [KMMangaGridItem] = selectedGridItems();
        
        // For every manga item that we want to mark as read...
        for(_, currentItem) in selectionItemsToMarkAsUnread.enumerate() {
            // Set the current item's manga's current page to 0 so its marked as 0% done
            currentItem.manga.currentPage = 0;
            
            // Update the current manga's percent finished
            currentItem.manga.updatePercent();
            
            // Update the item's manga
            currentItem.changeManga(currentItem.manga);
        }
        
        // Store the current selected rows
        let listRowSelectionIndexes : NSIndexSet = mangaTableView.selectedRowIndexes;
        
        // Reload the manga list
        mangaTableView.reloadData();
        
        // Reselect the rows(When reloadData is called it deselects all the items)
        mangaTableView.selectRowIndexes(listRowSelectionIndexes, byExtendingSelection: false);
        
        // Update the grid
        updateMangaGrid();
    }
    
    /// Marks the selected manga items as read
    func markSelectedItemsAsRead() {
        // Print to the log that we are marking the selected manga items as read
        print("Marking selected manga items as read");
        
        /// The selected manga items that we will mark as read
        let selectionItemsToMarkAsRead : [KMMangaGridItem] = selectedGridItems();
        
        // For every manga item that we want to mark as read...
        for(_, currentItem) in selectionItemsToMarkAsRead.enumerate() {
            // Set the current item's manga's current page to the last page, so we get it marked as 100% finished
            currentItem.manga.currentPage = currentItem.manga.pageCount - 1;
            
            // Update the current manga's percent finished
            currentItem.manga.updatePercent();
            
            // Update the item's manga
            currentItem.changeManga(currentItem.manga);
        }
        
        // Store the current selected rows
        let listRowSelectionIndexes : NSIndexSet = mangaTableView.selectedRowIndexes;
        
        // Reload the manga list
        mangaTableView.reloadData();
        
        // Reselect the rows(When reloadData is called it deselects all the items)
        mangaTableView.selectRowIndexes(listRowSelectionIndexes, byExtendingSelection: false);
        
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
        if #available(OSX 10.11, *) {
            titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark
        } else {
            titlebarVisualEffectView.material = NSVisualEffectMaterial.Titlebar
        };
        
        // Set the info visual effect view to be ultra dark
        if #available(OSX 10.11, *) {
            infoBarVisualEffectView.material = NSVisualEffectMaterial.UltraDark
        } else {
            infoBarVisualEffectView.material = NSVisualEffectMaterial.Titlebar
        };
        
        // Hide the info bar
        infoBarContainer.alphaValue = 0;
    }
    
    func deleteTitlebarInFullscreen() {
        // If the window is in fullscreen(Window height matches the screen height(This is really cheaty and I need to find a better way to do this))
        if(window.isFullscreen()) {
            // Hide the toolbar so we dont get a grey bar at the top
            window.toolbar?.visible = false;
            
            // Move the toggle list view button over to the edge
            titlebarToggleListViewCheckbox.frame.origin = CGPoint(x: 2, y: titlebarToggleListViewCheckbox.frame.origin.y);
        }
        else {
            // Show the toolbar again in non-fullscreen(So we still get the traffic lights in the right place)
            window.toolbar?.visible = true;
            
            // Move the toggle list view button beside the traffic lights
            titlebarToggleListViewCheckbox.frame.origin = CGPoint(x: 72, y: titlebarToggleListViewCheckbox.frame.origin.y);
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
}

