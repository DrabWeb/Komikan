//
//  ViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa
import SWXMLHash

class ViewController: NSViewController, NSWindowDelegate {
    
    // The main window of the application
    var window : NSWindow = NSWindow();

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
    
    /// The scroll view for groupCollectionView
    @IBOutlet var groupCollectionViewScrollView: NSScrollView!
    
    /// The collection view for showing manga in their groups(Series, Artist, Writer, ETC.)
    @IBOutlet var groupCollectionView: NSCollectionView!
    
    /// The controller for the manga groups(groupCollectionView)
    @IBOutlet var mangaGroupController: KMMangaGroupController!
    
    // The grid controller for the manga grid
    @IBOutlet var mangaGridController: KMMangaGridController!
    
    /// The list controller for the manga list
    @IBOutlet var mangaListController: KMMangaListController!
    
    /// The controller for showing the thumbnail of a manga on hover in the list view
    @IBOutlet var thumbnailImageHoverController: KMThumbnailImageHoverController!
    
    /// The table view the user can switch to to see their manga in a list instead of a grid
    @IBOutlet var mangaTableView: NSTableView!
    
    /// The scroll view for mangaTableView
    @IBOutlet var mangaTableViewScrollView: NSScrollView!
    
    // The search field in the titlebar
    @IBOutlet weak var titlebarSearchField: NSTextField!
    
    // When we finish editing the titlebarSearchField...
    @IBAction func titlebarSearchFieldInteracted(_ sender: AnyObject) {
        // Search for the passed string
        mangaGridController.searchFor((sender as? NSTextField)!.stringValue);
    }
    
    // The disclosure button in the titlebatr that lets you ascend/descend the sort order of the manga grid
    @IBOutlet weak var titlebarToggleSortDirectionButton: NSButton!
    
    // When we interact with titlebarToggleSortDirectionButton...
    @IBAction func titlebarToggleSortDirectionButtonInteracted(_ sender: AnyObject) {
        // Set the current ascending order on the grid controller
        mangaGridController.currentSortAscending = Bool(titlebarToggleSortDirectionButton.state as NSNumber);
        
        // Resort the grid based on which direction we said to sort it in
        mangaGridController.arrayController.sortDescriptors = [NSSortDescriptor(key: mangaGridController.arrayController.sortDescriptors[0].key, ascending: Bool(titlebarToggleSortDirectionButton.state as NSNumber))];
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
    @IBAction func infoBarGridSizeSliderInteracted(_ sender: AnyObject) {
        // Set the manga grid and group's min and max size to the sliders value
        mangaCollectionView.minItemSize = NSSize(width: infoBarGridSizeSlider.integerValue, height: infoBarGridSizeSlider.integerValue);
        mangaCollectionView.maxItemSize = NSSize(width: infoBarGridSizeSlider.integerValue + 100, height: infoBarGridSizeSlider.integerValue + 100);
        
        groupCollectionView.minItemSize = NSSize(width: infoBarGridSizeSlider.integerValue, height: infoBarGridSizeSlider.integerValue);
        groupCollectionView.maxItemSize = NSSize(width: infoBarGridSizeSlider.integerValue + 100, height: infoBarGridSizeSlider.integerValue + 100);
    }
    
    // The button in the titlebar that lets us add manga
    @IBOutlet weak var titlebarAddMangaButton: NSButton!
    
    // When we click titlebarAddMangaButton...
    @IBAction func titlebarAddMangaButtonInteracted(_ sender: AnyObject) {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.maxY, fileUrls: []);
    }
    
    /// The segmented control in the titlebar that allows sorting the manga grid
    @IBOutlet weak var titlebarSortingSegmentedControl: NSSegmentedControl!
    
    /// Called when the selected item in `titlebarSortingSegmentedControl` is changed
    @IBAction func titlebarSortingSegmentedControlChanged(_ sender : NSSegmentedControl) {
        // Sort the manga grid
        mangaGridController.sort(KMMangaGridSortType(rawValue: sender.selectedSegment)!, ascending: Bool(titlebarToggleSortDirectionButton.state as NSNumber));
    }
    
    /// The button in the titlebar that lets us toggle between list and grid view
    @IBOutlet var titlebarToggleListViewCheckbox: NSButton!
    
    /// When we interact with titlebarToggleListViewCheckbox...
    @IBAction func titlebarToggleListViewCheckboxAction(_ sender: AnyObject) {
        // Toggle the view we are in(List or grid)
        toggleView();
    }
    
    /// The button group for saying how the group view items should group
    @IBOutlet var titlebarGroupViewTypeSelectionSegmentedControl: NSSegmentedControl!
    
    /// When we interact with titlebarGroupViewTypeSelectionSegmentedControl...
    @IBAction func titlebarGroupViewTypeSelectionSegmentedControlInteracted(_ sender: AnyObject) {
        // Update the group view to show the now selected group type
        updateGroupViewToSegmentedControl();
    }
    
    /// The text field in the titlebar for searching in the group view
    @IBOutlet var titlebarGroupViewSearchField: KMAlwaysActiveTextField!
    
    /// When we interact with titlebarGroupViewSearchField...
    @IBAction func titlebarGroupViewSearchFieldInteracted(_ sender: AnyObject) {
        // Search for the entered text
        mangaGroupController.searchFor(titlebarGroupViewSearchField.stringValue);
    }
    
    // Called when we hit "Add" in the addmanga popover
    func addMangaFromAddMangaPopover(_ notification: Notification) {
        // Print to the log that we are adding from the add popover
        print("ViewController: Adding from the add popover...");
        
        // If we were passed an array of manga...
        if((notification.object as? [KMManga]) != nil) {
            // Print to the log that we are batch adding
            print("ViewController: Batch adding manga");
            
            // For every manga in the notifications manga array...
            for (_, currentManga) in ((notification.object as? [KMManga])?.enumerated())! {
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
            finishedImportNotification.identifier = UUID().uuidString;
            
            // Deliver the notification
            NSUserNotificationCenter.default.deliver(finishedImportNotification);
            
            // Reload the filters
            mangaGridController.updateFilters();
        }
        else {
            // Print to the log that we have recieved it and its name
            print("ViewController: Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add Manga popover");
            
            // Add the manga to the grid, and store the item in a new variable
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
        }
        
        // Stop addMangaViewController.addButtonUpdateLoop, so it stops eating resources when it doesnt need to
        addMangaViewController?.addButtonUpdateLoop.invalidate();
        
        // If we are in group view...
        if(groupViewOpen) {
            // Update the group view
            updateGroupViewToSegmentedControl();
        }
        
        // Resort the manga grid
        mangaGridController.resort();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Style the window to be fancy
        styleWindow();
        
        // Hide the window so we dont see any ugly loading "artifacts"
        window.alphaValue = 0;
        
        // Set the collections views item prototype to the collection view item we created in Main.storyboard
        mangaCollectionView.itemPrototype = storyboard?.instantiateController(withIdentifier: "mangaCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the group collection view's item prototype
        groupCollectionView.itemPrototype = storyboard?.instantiateController(withIdentifier: "groupCollectionViewItem") as? NSCollectionViewItem;
        
        // Set the min and max item size for the manga grid
        mangaCollectionView.minItemSize = NSSize(width: 200, height: 200);
        mangaCollectionView.maxItemSize = NSSize(width: 300, height: 300);
        
        // Set the max and min item sizes for the group grid
        groupCollectionView.minItemSize = NSSize(width: 200, height: 200);
        groupCollectionView.maxItemSize = NSSize(width: 300, height: 300);
        
        // Set the addFromEHMenuItem menu items action
        (NSApplication.shared().delegate as! AppDelegate).addFromEHMenuItem.action = #selector(ViewController.showAddFromEHPopover);
        
        // Set the toggle info bar menu items action
        (NSApplication.shared().delegate as! AppDelegate).toggleInfoBarMenuItem.action = #selector(ViewController.toggleInfoBar);
        
        // Set the delete selected manga menu items action
        (NSApplication.shared().delegate as! AppDelegate).deleteSelectedMangaMenuItem.action = #selector(ViewController.removeSelectedItemsFromMangaGrid);
        
        // Set the mark selected manga as read menu items action
        (NSApplication.shared().delegate as! AppDelegate).markSelectedAsReadMenuItem.action = #selector(ViewController.markSelectedItemsAsRead);
        
        // Set the mark selected manga as unread menu items action
        (NSApplication.shared().delegate as! AppDelegate).markSelectedAsUnreadMenuItem.action = #selector(ViewController.markSelectedItemsAsUnread);
        
        // Set the delete all manga menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.deleteAllMangaMenuItem.action = #selector(ViewController.deleteAllManga);
        
        // Set the add / import manga menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.importAddMenuItem.action = #selector(ViewController.showAddImportPopoverMenuItem);
        
        // Set the set selected items properties menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.setSelectedItemsPropertiesMenuItems.action = #selector(ViewController.showSetSelectedItemsPropertiesPopover);
        
        // Set the export manga JSON menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.exportJsonForAllMangaMenuItem.action = #selector(ViewController.exportMangaJSONForSelected);
        
        // Set the export manga JSON for migration menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.exportJsonForAllMangaForMigrationMenuItem.action = #selector(ViewController.exportMangaJSONForSelectedForMigration);
        
        // Set the fetch metadata for selected menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.fetchMetadataForSelectedMenuItem.action = #selector(ViewController.showFetchMetadataForSelectedItemsPopoverAtCenter);
        
        // Set the import menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.importMenuItem.action = #selector(ViewController.importMigrationFolder);
        
        // Set the toggle list view menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.toggleListViewMenuItem.action = #selector(ViewController.toggleView);
        
        // Set the open menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.openMenuItem.action = #selector(ViewController.openSelectedManga);
        
        // Set the select search field menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.selectSearchFieldMenuItem.action = #selector(ViewController.selectSearchField);
        
        // Set the edit selected menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.editSelectedMenuItem.action = #selector(ViewController.openEditPopoverForSelected);
        
        // Set the select manga view menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.selectMangaViewMenuItem.action = #selector(ViewController.selectMangaView);
        
        // Set the hide and show Komikan folders menubar items actions
        (NSApplication.shared().delegate as? AppDelegate)?.hideKomikanFoldersMenuItem.action = #selector(ViewController.hideKomikanMetadataFolders);
        (NSApplication.shared().delegate as? AppDelegate)?.showKomikanFoldersMenuItem.action = #selector(ViewController.showKomikanMetadataFolders);
        
        // Set the toggle group view menubar items action
        (NSApplication.shared().delegate as? AppDelegate)?.toggleGroupViewMenuItem.action = #selector(ViewController.toggleGroupView);
        
        // Set the AppDelegate's manga grid controller
        (NSApplication.shared().delegate as! AppDelegate).mangaGridController = mangaGridController;
        
        // Set the AppDelegate's search text field
        (NSApplication.shared().delegate as! AppDelegate).searchTextField = titlebarSearchField;
        
        // Set the AppDelegate's main view controller
        (NSApplication.shared().delegate as! AppDelegate).mainViewController = self;
        
        // Load the manga we had in the grid
        loadManga();
        
        // Do application initialization
        (NSApplication.shared().delegate as! AppDelegate).initialize();
        
        // Scroll to the top of the manga grid
        mangaCollectionViewScrollView.pageUp(self);
        
        // Init the thumbnail image hover controller
        thumbnailImageHoverController.styleWindow();
        
        // Set the main windows delegate to this
        window.delegate = self;
        
        // Sort the manga grid
        mangaGridController.sort(KMMangaGridSortType(rawValue: titlebarSortingSegmentedControl.selectedSegment)!, ascending: Bool(titlebarToggleSortDirectionButton.state as NSNumber));
        
        // Subscribe to the magnify event
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.magnify, handler: magnifyEvent);
        
        // Create some options for the manga grid KVO
        let options = NSKeyValueObservingOptions([.new, .old, .initial, .prior]);
        
        // Subscribe to when the manga grid changes its values in any way
        mangaGridController.arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: options, context: nil);
        
        // Show the window after 0.1 seconds, so we dont get loading artifacts
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(ViewController.showWindowAlpha), userInfo: nil, repeats: false);
        
        // Subscribe to the edit manga popovers remove notification
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.removeSelectItemFromMangaGrid(_:)), name:NSNotification.Name(rawValue: "KMEditMangaViewController.Remove"), object: nil);
        
        // Subscribe to the global redraw manga grid notification
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateMangaGrid), name:NSNotification.Name(rawValue: "ViewController.UpdateMangaGrid"), object: nil);
        
        // Subscribe to the global application will quit notification
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveManga), name:NSNotification.Name(rawValue: "Application.WillQuit"), object: nil);
        
        // Subscribe to the global application will quit notification with the manga grid scale
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveMangaGridScale), name:NSNotification.Name(rawValue: "Application.WillQuit"), object: nil);
        
        // Subscribe to the Drag and Drop add / import notification
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showAddImportPopoverDragAndDrop(_:)), name:NSNotification.Name(rawValue: "MangaGrid.DropFiles"), object: nil);
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // If the default screen is the list...
        if((NSApplication.shared().delegate as! AppDelegate).preferences.defaultScreen == 1) {
            // Show the list
            displayListView();
        }
        // If the default screen is the groups...
        else if((NSApplication.shared().delegate as! AppDelegate).preferences.defaultScreen == 2) {
            // Show the groups
            showGroupView();
        }
        
        // Load the preference values
        loadPreferenceValues();
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // If the keyPath is the one for the manga grids arranged objets...
        if(keyPath == "arrangedObjects") {
            // Update the manga count in the info bar
            updateInfoBarMangaCountLabel();
            
            // Reload the manga table so it gets updated when items change
            mangaListController.mangaListTableView.reloadData();
        }
    }
    
    /// Deselects all the items in the list/grid, depending on which we are in
    func clearMangaSelection() {
        // If we are in list view...
        if(inListView) {
            // Deselect all the items in the list
            mangaTableView.deselectAll(self);
        }
        // If we are in grid view...
        else {
            // Deselect all the items in the grid
            mangaCollectionView.deselectAll(self);
        }
    }
    
    /// The grid selection stored by storeCurrentSelection
    var storedGridSelection : IndexSet = IndexSet();
    
    /// The list selection stored by storeCurrentSelection
    var storedListSelection : IndexSet = IndexSet();
    
    /// The grid scroll point stored by storeCurrentSelection
    var storedGridScrollPoint : NSPoint = NSPoint();
    
    /// The list scroll point stored by storeCurrentSelection
    var storedListScrollPoint : NSPoint = NSPoint();
    
    /// Restores the selection that was stored by storeCurrentSelection
    func restoreSelection() {
        // If we are in list view...
        if(inListView) {
            // Restore the selection
            mangaTableView.selectRowIndexes(storedListSelection, byExtendingSelection: false);
            
            // Restore the scroll position
            mangaTableViewScrollView.contentView.scroll(to: storedListScrollPoint);
        }
        // If we are in grid view...
        else {
            // Restore the selection
            mangaCollectionView.selectionIndexes = storedGridSelection;
            
            // Restore the scroll position
            mangaCollectionViewScrollView.contentView.scroll(to: storedGridScrollPoint);
        }
    }
    
    /// Stores the current selection in the grid/list, to be called later by restoreSelection
    func storeCurrentSelection() {
        // Store the scroll point for the grid
        storedGridScrollPoint = mangaCollectionViewScrollView.contentView.bounds.origin;
        
        // Store the selection for the grid
        storedGridSelection = mangaCollectionView.selectionIndexes;
        
        // Store the scroll point for the list
        storedListScrollPoint = mangaTableViewScrollView.contentView.bounds.origin;
        
        // Store the selection for the list
        storedListSelection = mangaTableView.selectedRowIndexes;
    }
    
    /// Selects titlebarGroupViewSearchField
    func selectGroupViewSearchField() {
        // Make titlebarGroupViewSearchField the first responder
        window.makeFirstResponder(titlebarGroupViewSearchField);
    }
    
    /// Shows the selected group in the group view's manga
    func openSelectedGroupItem() {
        /// Display the manga for the selected item
        (groupCollectionView.item(at: groupCollectionView.selectionIndexes.first!) as! KMMangaGroupCollectionItem).displayManga();
    }
    
    /// Updates the group view to match the selected cell in titlebarGroupViewTypeSelectionSegmentedControl
    func updateGroupViewToSegmentedControl() {
        // Switch on the selected segment, no comments(Its pretty obvious what it's doing)
        switch(titlebarGroupViewTypeSelectionSegmentedControl.selectedSegment) {
            case 0:
                mangaGroupController.showGroupType(.series);
                break;
            case 1:
                mangaGroupController.showGroupType(.artist);
                break;
            case 2:
                mangaGroupController.showGroupType(.writer);
                break;
            case 3:
                mangaGroupController.showGroupType(.group);
                break;
            default:
                mangaGroupController.showGroupType(.series);
                break;
        }
        
        // Scroll to the top of the group view(Content insets make it so when you add items they are under the titlebar, this fixes that)
        groupCollectionViewScrollView.pageUp(self);
    }
    
    /// Is the group view open?
    var groupViewOpen : Bool = false;
    
    /// Toggles if the group view is open
    func toggleGroupView() {
        // Toggle groupViewOpen
        groupViewOpen = !groupViewOpen;
        
        // If the group view should now be open...
        if(groupViewOpen) {
            // Show the group
            showGroupView();
        }
        // If the group view should now be closed...
        else {
            // Hide the group view
            hideGroupView();
        }
    }
    
    /// Shows the group view
    func showGroupView() {
        // Say the group view is open
        groupViewOpen = true;
        
        // Update the items in the group view
        updateGroupViewToSegmentedControl();
        
        // Show the group view
        groupCollectionViewScrollView.isHidden = false;
        
        // Select the group view
        self.window.makeFirstResponder(groupCollectionViewScrollView);
        
        // If we are in list view...
        if(inListView) {
            // Hide the list view
            mangaTableViewScrollView.isHidden = true;
            
            // Hide any possible hover thumbnails
            thumbnailImageHoverController.hide();
        }
        // If we are in grid view...
        else {
            // Hide the grid view
            mangaCollectionViewScrollView.isHidden = true;
        }
        
        // Disable/enable
        titlebarGroupViewSearchField.isEnabled = true;
        titlebarSearchField.isEnabled = false;
        titlebarToggleListViewCheckbox.isEnabled = false;
        
        if(!inListView) {
            titlebarSortingSegmentedControl.isEnabled = false;
            titlebarToggleSortDirectionButton.isEnabled = false;
        }
        
        // Fade out/hide
        titlebarToggleListViewCheckbox.animator().alphaValue = 0;
        titlebarAddMangaButton.animator().alphaValue = 0;
        
        if(!inListView) {
            titlebarSortingSegmentedControl.animator().alphaValue = 0;
            titlebarToggleSortDirectionButton.animator().alphaValue = 0;
        }
        
        titlebarGroupViewSearchField.isHidden = false;
        titlebarSearchField.isHidden = true;
        
        // Fade in
        titlebarGroupViewTypeSelectionSegmentedControl.isEnabled = true;
        titlebarGroupViewTypeSelectionSegmentedControl.animator().alphaValue = 1;
        
        // Menubar actions
        (NSApplication.shared().delegate as? AppDelegate)?.selectSearchFieldMenuItem.action = #selector(ViewController.selectGroupViewSearchField);
        (NSApplication.shared().delegate as? AppDelegate)?.openMenuItem.action = #selector(ViewController.openSelectedGroupItem);
    }
    
    /// Hides the group view
    func hideGroupView() {
        // Say the group view is closed
        groupViewOpen = false;
        
        // Hide the group view
        groupCollectionViewScrollView.isHidden = true;
        
        // If we are in list view...
        if(inListView) {
            // Show the list view
            mangaTableViewScrollView.isHidden = false;
            
            // Select the list view
            self.window.makeFirstResponder(mangaTableView);
        }
        // If we are in grid view...
        else {
            // Show the grid view
            mangaCollectionViewScrollView.isHidden = false;
            
            // Select the grid view
            self.window.makeFirstResponder(mangaCollectionView);
        }
        
        // Disable/enable
        titlebarGroupViewSearchField.isEnabled = false;
        titlebarGroupViewTypeSelectionSegmentedControl.isEnabled = false;
        titlebarSearchField.isEnabled = true;
        titlebarToggleListViewCheckbox.isEnabled = true;
        
        if(!inListView) {
            titlebarSortingSegmentedControl.isEnabled = true;
            titlebarToggleSortDirectionButton.isEnabled = true;
        }
        
        // Fade out/hide
        titlebarToggleListViewCheckbox.animator().alphaValue = 1;
        titlebarAddMangaButton.animator().alphaValue = 1;
        titlebarGroupViewTypeSelectionSegmentedControl.animator().alphaValue = 0;
        
        if(!inListView) {
            titlebarSortingSegmentedControl.animator().alphaValue = 1;
            titlebarToggleSortDirectionButton.animator().alphaValue = 1;
        }
        
        titlebarGroupViewSearchField.isHidden = true;
        titlebarSearchField.isHidden = false;
        
        // Fade in
        titlebarToggleListViewCheckbox.animator().alphaValue = 1;
        titlebarAddMangaButton.animator().alphaValue = 1;
        
        // Menubar actions
        (NSApplication.shared().delegate as? AppDelegate)?.selectSearchFieldMenuItem.action = #selector(ViewController.selectSearchField);
        (NSApplication.shared().delegate as? AppDelegate)?.openMenuItem.action = #selector(ViewController.openSelectedManga);
    }
    
    /// Asks the user for a folder, then hides all the Komikan metadata folders in that folder and it's subfolders
    func hideKomikanMetadataFolders() {
        /// The open panel for asking the user which folder to hide Komikan folders in
        let hideOpenPanel : NSOpenPanel = NSOpenPanel();
        
        // Dont allow any files to be selected
        hideOpenPanel.allowedFileTypes = [""];
        
        // Allow folders to be selected
        hideOpenPanel.canChooseDirectories = true;
        
        // Set the prompt
        hideOpenPanel.prompt = "Select";
        
        // Run the modal, and if they clicked "Select"...
        if(Bool(hideOpenPanel.runModal() as NSNumber)) {
            /// The path to the folder we want to hide Komikan folders in
            let hideFolderPath : String = hideOpenPanel.url!.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "");
            
            /// The file enumerator for the folder we want to hide Komikan folders in
            let hideFolderFileEnumerator : FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: hideFolderPath)!;
            
            // For every file in the folder we want to hide Komikan folders in...
            for(_, currentFile) in hideFolderFileEnumerator.enumerated() {
                // If the current file is a folder...
                if(NSString(string: hideFolderPath + String(describing: currentFile)).pathExtension == "") {
                    // If the current file's name is "Komikan"...
                    if(NSString(string: hideFolderPath + String(describing: currentFile)).lastPathComponent == "Komikan") {
                        // Hide the current folder
                        _ = KMCommandUtilities().runCommand("/usr/bin/chflags", arguments: ["hidden", hideFolderPath + String(describing: currentFile)], waitUntilExit: true);
                    }
                }
            }
        }
    }
    
    /// Asks the user for a folder, then shows all the Komikan metadata folders in that folder and it's subfolders
    func showKomikanMetadataFolders() {
        /// The open panel for asking the user which folder to show Komikan folders in
        let showOpenPanel : NSOpenPanel = NSOpenPanel();
        
        // Dont allow any files to be selected
        showOpenPanel.allowedFileTypes = [""];
        
        // Allow folders to be selected
        showOpenPanel.canChooseDirectories = true;
        
        // Set the prompt
        showOpenPanel.prompt = "Select";
        
        // Run the modal, and if they clicked "Select"...
        if(Bool(showOpenPanel.runModal() as NSNumber)) {
            /// The path to the folder we want to show Komikan folders in
            let showFolderPath : String = showOpenPanel.url!.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "");
            
            /// The file enumerator for the folder we want to show Komikan folders in
            let showFolderFileEnumerator : FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: showFolderPath)!;
            
            // For every file in the folder we want to show Komikan folders in...
            for(_, currentFile) in showFolderFileEnumerator.enumerated() {
                // If the current file is a folder...
                if(NSString(string: showFolderPath + String(describing: currentFile)).pathExtension == "") {
                    // If the current file's name is "Komikan"...
                    if(NSString(string: showFolderPath + String(describing: currentFile)).lastPathComponent == "Komikan") {
                        // Show the current folder
                        _ = KMCommandUtilities().runCommand("/usr/bin/chflags", arguments: ["nohidden", showFolderPath + String(describing: currentFile)], waitUntilExit: true);
                    }
                }
            }
        }
    }
    
    /// Prompts the user for a folder to import from migration, and then imports them.
    func importMigrationFolder() {
        /// The open panel for asking the user which folder to import
        let importOpenPanel : NSOpenPanel = NSOpenPanel();
        
        // Dont allow any single files to be selected
        importOpenPanel.allowedFileTypes = [""];
        
        // Allow folders to be selected
        importOpenPanel.canChooseDirectories = true;
        
        // Set the prompt
        importOpenPanel.prompt = "Import";
        
        // Run the modal, and if they click "Choose"....
        if(Bool(importOpenPanel.runModal() as NSNumber)) {
            /// The path to the folder the user said to import
            let importFolderPath : String = (importOpenPanel.url!.absoluteString.removingPercentEncoding?.replacingOccurrences(of: "file://", with: ""))!;
            
            /// The migration importer we will use
            let migrationImporter : KMMigrationImporter = KMMigrationImporter();
            
            // Set the migration importer's manga grid controller
            migrationImporter.mangaGridController = mangaGridController;
            
            // Tell the migration importer to import the chosen folder
            migrationImporter.importFolder(importFolderPath);
        }
    }
    
    /// Selects the manga list/grid
    func selectMangaView() {
        // If we are in list view...
        if(inListView) {
            // Make the manga list the first responder
            window.makeFirstResponder(mangaTableView);
        }
        // If we are in grid view...
        else {
            // Make the manga grid the first responder
            window.makeFirstResponder(mangaCollectionView);
        }
    }
    
    /// Opens the edit popover for the selected manga items
    func openEditPopoverForSelected() {
        /// The index of the item we want to open the edit popover for(The first index in the selection indexes)
        let indexToPopover : Int = selectedItemIndexes().first!;
        
        // If we are in list view...
        if(inListView) {
            // Deselect all the list items
            mangaListController.mangaListTableView.deselectAll(self);
            
            // Select the one we wanted to popover
            mangaListController.mangaListTableView.selectRowIndexes(IndexSet(integer: indexToPopover), byExtendingSelection: false);
            
            // Open the popover for the selected item
            mangaListController.openPopover(false, manga: mangaListController.selectedManga());
        }
        // If we are in grid view...
        else {
            // Deselect all the grid items
            mangaCollectionView.deselectAll(self);
            
            // Select the item at indexToPopover
            mangaCollectionView.item(at: indexToPopover)?.isSelected = true;
            
            // Open the popover for the item at indexToPopover
            (mangaCollectionView.item(at: indexToPopover) as! KMMangaGridCollectionItem).openPopover(false);
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
            for(_, currentSelectionIndex) in selectedItemIndexes().enumerated() {
                // Get the KMMangaGridCollectionItem at the current selection index and open it in the reader
                (mangaCollectionView.item(at: currentSelectionIndex) as? KMMangaGridCollectionItem)!.openManga();
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
        // If the group view isn't open...
        if(!groupViewOpen) {
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
    }
    
    /// Switches from the grid view to the table view
    func displayListView() {
        // Print to the log that we are going into list view
        print("ViewController: Switching to list view");
        
        // Say we are in list view
        inListView = true;
        
        // Store the current sort descriptors
        oldGridSortDescriptors = mangaGridController.arrayController.sortDescriptors;
        
        // Change the toggle list view button to show the list icon
        titlebarToggleListViewCheckbox.state = 1;
        
        // Deselect all the items in the list
        mangaTableView.deselectAll(self);
        
        // Select every item in the list that we had selected in the grid
        mangaTableView.selectRowIndexes(mangaCollectionView.selectionIndexes, byExtendingSelection: false);
        
        // Deselect all the items in the grid
        mangaCollectionView.deselectAll(self);
        
        // Redraw the table view graphically so we dont get artifacts
        mangaTableViewScrollView.needsDisplay = true;
        mangaTableView.needsDisplay = true;
        
        // Show the list view
        mangaTableViewScrollView.isHidden = false;
        
        // Hide the grid view
        mangaCollectionViewScrollView.isHidden = true;
        
        // Hide the group search field
        titlebarGroupViewSearchField.isHidden = true;
        titlebarGroupViewSearchField.isEnabled = false;
        
        // Hide the group view tabs
        titlebarGroupViewTypeSelectionSegmentedControl.isEnabled = false;
        titlebarGroupViewTypeSelectionSegmentedControl.alphaValue = 0;
        
        // Hide the thumbnail window
        thumbnailImageHoverController.hide();
        
        // Fade out the manga grid only titlebar items
        titlebarSortingSegmentedControl.animator().alphaValue = 0;
        titlebarToggleSortDirectionButton.animator().alphaValue = 0;
        
        // Select the list view
        window.makeFirstResponder(mangaListController.mangaListTableView);
    }
    
    /// Switches from the table view to the grid view
    func displayGridView() {
        // Print to the log that we are going into grid view
        print("ViewController: Switching to grid view");
        
        // Say we arent in list view
        inListView = false;
        
        // Restore the old sort descriptors
        mangaGridController.arrayController.sortDescriptors = oldGridSortDescriptors;
        
        // Change the toggle list view button to show the grid icon
        titlebarToggleListViewCheckbox.state = 0;
        
        // Deselect all the items in the grid
        mangaCollectionView.deselectAll(self);
        
        // For every selected index in the list...
        for(_, currentIndexSet) in mangaTableView.selectedRowIndexes.enumerated() {
            // Select the item at the given index in the grid
            mangaCollectionView.item(at: currentIndexSet)?.isSelected = true;
        }
        
        // Deselect all the items in the list
        mangaTableView.deselectAll(self);
        
        // Redraw the grid view graphically so we dont get artifacts
        mangaCollectionView.needsDisplay = true;
        mangaCollectionViewScrollView.needsDisplay = true;
        
        // Hide the list view
        mangaTableViewScrollView.isHidden = true;
        
        // Show the grid view
        mangaCollectionViewScrollView.isHidden = false;
        
        // Hide the thumbnail window
        thumbnailImageHoverController.hide();
        
        // Fade in the manga grid only titlebar items
        titlebarSortingSegmentedControl.animator().alphaValue = 1;
        titlebarToggleSortDirectionButton.animator().alphaValue = 1;
        
        // Select the grid view
        window.makeFirstResponder(mangaCollectionView);
    }
    
    /// Returns the indexes of the selected manga items
    func selectedItemIndexes() -> IndexSet {
        /// The indexes of the selected manga items
        var selectionIndexes : IndexSet = IndexSet();
        
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
        for(_, currentIndex) in selectedItemIndexes().enumerated() {
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
        for(_, currentGridItem) in selectedGridItems().enumerated() {
            // Add the current grid item's manga to the selected manga
            selectedManga.append(currentGridItem.manga);
        }
        
        // Return the selected manga
        return selectedManga;
    }
    
    /// Called when the user does a magnify gesture on the trackpad
    func magnifyEvent(_ event : NSEvent) -> NSEvent {
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
        infoBarGridSizeSlider.integerValue = (NSApplication.shared().delegate as! AppDelegate).preferences.mangaGridScale;
        
        // Update the grid size with the grid size slider
        infoBarGridSizeSliderInteracted(infoBarGridSizeSlider);
    }
    
    /// Saves the scale of the manga grid
    func saveMangaGridScale() {
        // Save the manga grid scale into AppDelegate
        (NSApplication.shared().delegate as! AppDelegate).preferences.mangaGridScale = infoBarGridSizeSlider.integerValue;
    }
    
    /// Exports JSON for all the selected manga in the grid without internal information
    func exportMangaJSONForSelected() {
        // Print to the log that we are exporting metadata for selected manga
        print("ViewController: Exporting JSON metadata for selected manga");
        
        /// The selected KMManga in the grid
        let selectedManga : [KMManga] = selectedGridItemManga();
        
        // For every selected manga...
        for(_, currentManga) in selectedManga.enumerated() {
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
        finishedNotification.identifier = UUID().uuidString;
        
        // Deliver the notification
        NSUserNotificationCenter.default.deliver(finishedNotification);
    }
    
    /// Exports the internal JSON for the selected manga items(Meant for when the user switches computers or something and wants to keep metadata)
    func exportMangaJSONForSelectedForMigration() {
        // For every selected manga item...
        for(_, currentGridItem) in selectedGridItems().enumerated() {
            // Export this items manga's info
            KMFileUtilities().exportMangaJSON(currentGridItem.manga, exportInternalInfo: true);
        }
        
        // Create the new notification to tell the user the Metadata exporting has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finshed exporting Metadata";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        finishedNotification.identifier = UUID().uuidString;
        
        // Deliver the notification
        NSUserNotificationCenter.default.deliver(finishedNotification);
    }
    
    /// The view controller that will load for the metadata fetching popover
    var fetchMetadataViewController: KMMetadataFetcherViewController?
    
    // Is this the first time opened the fetch metadata popover?
    var fetchMetadataViewFirstLoad : Bool = true;
    
    /// Shows the fetch metadata popover at the given rect on the given side
    func showFetchMetadataForSelectedItemsPopover(_ relativeToRect: NSRect, preferredEdge: NSRectEdge) {
        // If there are any selected manga...
        if(selectedItemCount() != 0) {
            // Get the main storyboard
            let storyboard = NSStoryboard(name: "Main", bundle: nil);
            
            // Instanstiate the view controller for the fetch metadata popover
            fetchMetadataViewController = storyboard.instantiateController(withIdentifier: "metadataFetcherViewController") as? KMMetadataFetcherViewController;
            
            // Set the fetch metadata popover's selected manga
            fetchMetadataViewController?.selectedMangaGridItems = selectedGridItems();
            
            // Present the fetchMetadataViewController as a popover at the given relative rect on the given preferred edge
            fetchMetadataViewController!.presentViewController(fetchMetadataViewController!, asPopoverRelativeTo: relativeToRect, of: backgroundVisualEffectView, preferredEdge: preferredEdge, behavior: NSPopoverBehavior.transient);
            
            // If this is the first time we have opened the popover...
            if(fetchMetadataViewFirstLoad) {
                // Subscribe to the popovers finished notification
                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fetchMetadataForSelectedItemsPopoverFinished(_:)), name:NSNotification.Name(rawValue: "KMMetadataFetcherViewController.Finished"), object: nil);
                
                // Say that all the next loads are not the first
                fetchMetadataViewFirstLoad = false;
            }
        }
    }
    
    /// Calls showFetchMetadataForSelectedItemsPopover so it opens in the center
    func showFetchMetadataForSelectedItemsPopoverAtCenter() {
        // Show the fetch metadata popover in the center of the window with the arrow pointing down
        showFetchMetadataForSelectedItemsPopover(NSRect(x: 0, y: 0, width: window.contentView!.bounds.width, height: window.contentView!.bounds.height / 2), preferredEdge: NSRectEdge.maxY);
    }
    
    /// Called when the fetch metadata for selected manga popover is done
    func fetchMetadataForSelectedItemsPopoverFinished(_ notification : Notification) {
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
            setSelectedItemsPropertiesViewController = storyboard.instantiateController(withIdentifier: "setSelectedItemsPropertiesViewController") as? KMSetSelectedItemsPropertiesViewController;
            
            // Present the setSelectedItemsPropertiesViewController as a popover so it is in the center of the window and the arrow is pointing down
            setSelectedItemsPropertiesViewController!.presentViewController(setSelectedItemsPropertiesViewController!, asPopoverRelativeTo: NSRect(x: 0, y: 0, width: window.contentView!.bounds.width, height: window.contentView!.bounds.height / 2), of: backgroundVisualEffectView, preferredEdge: NSRectEdge.maxY, behavior: NSPopoverBehavior.transient);
            
            // If this is the first time we have opened the popover...
            if(setSelectedItemsPropertiesViewFirstLoad) {
                // Subscribe to the popovers finished notification
                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.setSelectedItemsProperties(_:)), name:NSNotification.Name(rawValue: "KMSetSelectedItemsPropertiesViewController.Finished"), object: nil);
                
                // Say that all the next loads are not the first
                setSelectedItemsPropertiesViewFirstLoad = false;
            }
        }
    }
    
    /// Called by the set selected items properties popover to apply the given values to the selected items
    func setSelectedItemsProperties(_ notification : Notification) {
        // Print to the log thatr we are setting the selected items properties
        print("ViewController: Setting selected items properties to properties from popover");
        
        /// The manga grid items that we want to set properties of
        let selectionItemsToSetProperties : [KMMangaGridItem] = selectedGridItems();
        
        // Get the notification object as a KMSetSelectedPropertiesHolder
        let propertiesHolder : KMSetSelectedPropertiesHolder = (notification.object as! KMSetSelectedPropertiesHolder);
        
        // For every item in the manga grid that we set the properties of...
        for(_, currentItem) in selectionItemsToSetProperties.enumerated() {
            // Apply the propertie holders values to the current item
            propertiesHolder.applyValuesToManga(currentItem.manga);
        }
        
        // Store the selection and scroll position
        storeCurrentSelection();
        
        // Resort the grid
        mangaGridController.resort();
        
        // Reload the filters
        mangaGridController.updateFilters();
        
        // Restore the selection and scroll position
        restoreSelection();
        
        // Clear the selection
        clearMangaSelection();
    }
    
    /// Shows the add / import popover, without passing variables for the menu item
    func showAddImportPopoverMenuItem() {
        // Show the add / import popover
        showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.maxY, fileUrls: []);
    }
    
    /// Shows the add / import popover with the passed notifications object(Should be a list of file URL strings)(Used only by drag and drop import)
    func showAddImportPopoverDragAndDrop(_ notification : Notification) {
        /// The file URLs we will pass to the popover
        var fileUrls : [URL] = [];
        
        // For every item in the notifications objects(As a list of strings)...
        for(_, currentStringURL) in (notification.object as! [String]).enumerated() {
            /// The NSURL of the current file
            let currentFileURL : URL = URL(fileURLWithPath: currentStringURL);
            
            /// The extension of the current file
            let currentFileExtension : String = KMFileUtilities().getFileExtension(currentFileURL);
            
            // If the extension is supported(CBZ, CBR, ZIP, RAR or Folder)...
            if(currentFileExtension == "cbz" || currentFileExtension == "cbr" || currentFileExtension == "zip" || currentFileExtension == "rar" || KMFileUtilities().isFolder(currentStringURL)) {
                // Append the current file URL to the array of files we will pass to the popover
                fileUrls.append(currentFileURL);
            }
            // If the extension is unsupported...
            else {
                // Print to the log that it is unsupported and what the extension is
                print("ViewController: Unsupported file extension \"" + currentFileExtension + "\"");
            }
        }
        
        // If there were any files that matched the extension...
        if(fileUrls != []) {
            // Show the add / import popover under the add button with the file URLs we dragged in
            showAddImportPopover(titlebarAddMangaButton.bounds, preferredEdge: NSRectEdge.maxY, fileUrls: fileUrls);
        }
    }
    
    /// Shows the add / import popover with the origin rect as where the arrow comes from, and the preferredEdge as to which side to come from. Also if fileUrls is not [], it will not show the file choosing dialog and go staright to the properties popover with the passed file URLs
    func showAddImportPopover(_ origin : NSRect, preferredEdge : NSRectEdge, fileUrls : [URL]) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add manga view controller
        addMangaViewController = storyboard.instantiateController(withIdentifier: "addMangaViewController") as? KMAddMangaViewController;
        
        // Set the add manga view controllers add manga file URLs that we were passed
        addMangaViewController!.addingMangaURLs = fileUrls;
        
        // Present the addMangaViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addMangaViewController!.presentViewController(addMangaViewController!, asPopoverRelativeTo: origin, of: titlebarAddMangaButton, preferredEdge: preferredEdge, behavior: NSPopoverBehavior.semitransient);
        
        // If this is the first time we have pushed this button...
        if(addMangaViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.addMangaFromAddMangaPopover(_:)), name:NSNotification.Name(rawValue: "KMAddMangaViewController.Finished"), object: nil);
            
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
        mangaCollectionView.itemPrototype = storyboard?.instantiateController(withIdentifier: "mangaCollectionViewItem") as? NSCollectionViewItem;
    }
    
    // The view controller we will load for the add manga popover
    var addFromEHViewController: KMEHViewController?
    
    // Is this the first time weve clicked on the add button in the titlebar?
    var addFromEHViewFirstLoad : Bool = true;
    
    func showAddFromEHPopover() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the add from eh view controller
        addFromEHViewController = storyboard.instantiateController(withIdentifier: "addFromEHViewController") as? KMEHViewController;
        
        // Present the addFromEHViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addFromEHViewController!.presentViewController(addFromEHViewController!, asPopoverRelativeTo: titlebarAddMangaButton.bounds, of: titlebarAddMangaButton, preferredEdge: NSRectEdge.maxY, behavior: NSPopoverBehavior.semitransient);
        
        // If this is the first time we have opened the popover...
        if(addFromEHViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.addMangaFromEHPopover(_:)), name:NSNotification.Name(rawValue: "KMEHViewController.Finished"), object: nil);
            
            // Say that all the next loads are not the first
            addFromEHViewFirstLoad = false;
        }
    }
    
    func addMangaFromEHPopover(_ notification : Notification) {
        // Print to the log that we are adding a manga from the EH popover
        print("ViewController: Adding from EH...");
        
        // If we were passed an array of manga...
        if((notification.object as? [KMManga]) != nil) {
            /// Print to the log that we are batch adding
            print("ViewController: Batch adding manga from EH");
            
            // For every manga in the passed manga...
            for (_, currentManga) in ((notification.object as? [KMManga])?.enumerated())! {
                // Add the current manga to the grid
                mangaGridController.addManga(currentManga, updateFilters: false);
            }
            
            // Reload the filters
            mangaGridController.updateFilters();
        }
        // If we only passed a single manga...
        else {
            // Print to the log that we have recieved it and its name
            print("ViewController: Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add From EH Manga popover");
            
            // Add the manga to the grid
            mangaGridController.addManga((notification.object as? KMManga)!, updateFilters: true);
        }
        
        // Stop the loop so we dont take up precious memory
        addFromEHViewController?.addButtonUpdateLoop.invalidate();
        
        /// Resort the grid
        mangaGridController.resort();
        
        // If we are in group view...
        if(groupViewOpen) {
            // Update the group view
            updateGroupViewToSegmentedControl();
        }
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
    func removeSelectItemFromMangaGrid(_ notification : Notification) {
        // Print to the log that we are removing this manga
        print("ViewController: Removing \"" + (notification.object as? KMManga)!.title + "\" manga item");
        
        // Remove this item from the grid controller
        mangaGridController.removeGridItem((mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![selectedItemIndexes().last!], resort: true);
    }
    
    /// Removes all the selected manga items(Use this for multiple)
    func removeSelectedItemsFromMangaGrid() {
        // Print to the log that we are removing the selected manga items
        print("ViewController: Removing selected manga items");
        
        /// The manga grid items that we want to remove
        let selectionItemsToRemove : [KMMangaGridItem] = selectedGridItems();
        
        // For every item in the manga grid items we want to remove...
        for(_, currentItem) in selectionItemsToRemove.enumerated() {
            // Remove the curent item from the grid, with resorting
            mangaGridController.removeGridItem(currentItem, resort: true);
        }
    }
    
    /// Marks the selected manga items as unread
    func markSelectedItemsAsUnread() {
        // Print to the log that we are marking the selected items as unread
        print("ViewController: Marking selected manga items as unread");
        
        /// The selected manga items that we will mark as read
        let selectionItemsToMarkAsUnread : [KMMangaGridItem] = selectedGridItems();
        
        // For every manga item that we want to mark as read...
        for(_, currentItem) in selectionItemsToMarkAsUnread.enumerated() {
            // Set the current item's manga's current page to 0 so its marked as 0% done
            currentItem.manga.currentPage = 0;
            
            // Update the current manga's percent finished
            currentItem.manga.updatePercent();
            
            // Update the item's manga
            currentItem.changeManga(currentItem.manga);
        }
        
        // Save the scroll position and selection
        storeCurrentSelection();
        
        // Reload the manga list
        mangaTableView.reloadData();
        
        // Update the grid
        updateMangaGrid();
        
        // Redo the current search, if we are searching
        mangaGridController.redoSearch();
        
        // Restore the selection and scroll position
        restoreSelection();
    }
    
    /// Marks the selected manga items as read
    func markSelectedItemsAsRead() {
        // Print to the log that we are marking the selected manga items as read
        print("ViewController: Marking selected manga items as read");
        
        /// The selected manga items that we will mark as read
        let selectionItemsToMarkAsRead : [KMMangaGridItem] = selectedGridItems();
        
        // For every manga item that we want to mark as read...
        for(_, currentItem) in selectionItemsToMarkAsRead.enumerated() {
            // Set the current item's manga's current page to the last page, so we get it marked as 100% finished
            currentItem.manga.currentPage = currentItem.manga.pageCount - 1;
            
            // Update the current manga's percent finished
            currentItem.manga.updatePercent();
            
            // Update the item's manga
            currentItem.changeManga(currentItem.manga);
        }
        
        // Save the scroll position and selection
        storeCurrentSelection();
        
        // Reload the manga list
        mangaTableView.reloadData();
        
        // Update the grid
        updateMangaGrid();
        
        // Redo the current search, if we are searching
        mangaGridController.redoSearch();
        
        // Restore the selection and scroll position
        restoreSelection();
    }
    
    func toggleInfoBar() {
        // Set infoBarOpen to the opposite of its current value
        infoBarOpen = !infoBarOpen;
        
        // If the info bar is now open...
        if(infoBarOpen) {
            // Enable the grid size slider
            infoBarGridSizeSlider.isEnabled = true;
            
            // Fade it in
            infoBarContainer.animator().alphaValue = 1;
        }
        // If the info bar is now closed...
        else {
            // Disable the grid size slider
            infoBarGridSizeSlider.isEnabled = false;
            
            // Fade it out
            infoBarContainer.animator().alphaValue = 0;
        }
    }
    
    func styleWindow() {
        // Get a reference to the main window
        window = NSApplication.shared().windows.last!;
        
        // Set the main window to have a full size content view
        window.styleMask.insert(NSFullSizeContentViewWindowMask);
        
        // Hide the titlebar background
        window.titlebarAppearsTransparent = true;
        
        // Hide the titlebar title
        window.titleVisibility = NSWindowTitleVisibility.hidden;
        
        // Set the background visual effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.dark;
        
        // Set the titlebar visual effect view to be ultra dark
        if #available(OSX 10.11, *) {
            titlebarVisualEffectView.material = NSVisualEffectMaterial.ultraDark
        } else {
            titlebarVisualEffectView.material = NSVisualEffectMaterial.titlebar
        };
        
        // Set the info visual effect view to be ultra dark
        if #available(OSX 10.11, *) {
            infoBarVisualEffectView.material = NSVisualEffectMaterial.ultraDark
        } else {
            infoBarVisualEffectView.material = NSVisualEffectMaterial.titlebar
        };
        
        // Hide the info bar
        infoBarContainer.alphaValue = 0;
        
        // Disable the grid size slider
        infoBarGridSizeSlider.isEnabled = false;
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        // Move the toggle list view button over to the edge
        titlebarToggleListViewCheckbox.frame.origin = CGPoint(x: 2, y: titlebarToggleListViewCheckbox.frame.origin.y);
        
        // Set the appearance back to vibrant dark
        self.window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        // Hide the toolbar so we dont get a grey bar at the top
        window.toolbar?.isVisible = false;
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        // Show the toolbar again in non-fullscreen(So we still get the traffic lights in the right place)
        window.toolbar?.isVisible = true;
        
        // Move the toggle list view button beside the traffic lights
        titlebarToggleListViewCheckbox.frame.origin = CGPoint(x: 72, y: titlebarToggleListViewCheckbox.frame.origin.y);
        
        // Set the appearance back to aqua
        self.window.appearance = NSAppearance(named: NSAppearanceNameAqua);
    }
    
    func updateInfoBarMangaCountLabel() {
        // Set the manga count labels label to the manga count awith "Manga" on the end
        infoBarMangaCountLabel.stringValue = String(mangaGridController.gridItems.count) + " Manga";
    }
    
    // Saves the manga in the grid
    func saveManga() {
        // Create a NSKeyedArchiver data with the manga grid controllers grid items
        let data = NSKeyedArchiver.archivedData(withRootObject: mangaGridController.gridItems);
        
        // Set the standard user defaults mangaArray key to that data
        UserDefaults.standard.set(data, forKey: "mangaArray");
        
        // Synchronize the data
        UserDefaults.standard.synchronize();
    }
    
    // Load the saved manga back to the grid
    func loadManga() {
        // If we have any data to load...
        if let data = UserDefaults.standard.object(forKey: "mangaArray") as? Data {
            // For every KMMangaGridItem in the saved manga grids items...
            for (_, currentManga) in (NSKeyedUnarchiver.unarchiveObject(with: data) as! [KMMangaGridItem]).enumerated() {
                // Add the current object to the manga grid
                mangaGridController.addGridItem(currentManga);
            }
        }
        
        // Update the grid
        updateMangaGrid();
    }
    
    func windowDidResignKey(_ notification: Notification) {
        // Hide the thumbnail hover window
        thumbnailImageHoverController.hide();
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

