//
//  KMMangaListController.swift
//  Komikan
//
//  Created by Seth on 2016-02-29.
//

import Cocoa

/// Controls the manga list. Not nearly as powerful as KMMangaGridController, as it only controls filling in the table view from the grid controller
class KMMangaListController: NSObject {
    
    /// A reference to the manga grid controller
    @IBOutlet weak var mangaGridController: KMMangaGridController!
    
    /// The main view controller
    @IBOutlet weak var viewController: ViewController!
    
    /// The table view this list controller is filling in
    @IBOutlet weak var mangaListTableView: KMMangaListTableView!
    
    /// When we click on mangaListTableView...
    @IBAction func mangaListTableViewClicked(_ sender: AnyObject) {
        // If we double clicked...
        if(NSApplication.shared().currentEvent?.clickCount == 2) {
            // Open the selected manga
            openManga();
        }
    }
    
    /// The opened manga of the list
    var openedManga : [KMManga] = [];
    
    /// A little bool to stop the manga list from resorting at launch, otherwise it messes stuff up
    var firstSortChange : Bool = true;
    
    // The view controller we will load for the edit/open manga popover
    var editMangaViewController: KMEditMangaViewController?
    
    /// Returns the list of selected manga from the table view
    func selectedMangaList() -> [KMManga] {
        /// The list of selected manga we will return at the end
        var manga : [KMManga] = [];
        
        // For every selected row...
        for(_, currentIndex) in self.mangaListTableView.selectedRowIndexes.enumerated() {
            // Add the manga at the current index to the manga list
            manga.append(((self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![currentIndex].manga));
        }
        
        // Return the manga list
        return manga;
    }
    
    /// Returns the single selected manga from the table view
    func selectedManga() -> KMManga {
        // Get the manga at the selected row in the array controller
        return ((self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![mangaListTableView.selectedRow].manga);
    }
    
    /// Have we already subscribed to the popover and readers notifications?
    var alreadySubscribed : Bool = false;
    
    /// Is the edit popover open?
    var editPopoverOpen : Bool = false;
    
    func openPopover(_ hidden : Bool, manga : KMManga) {
        // Hide the thumbnail window
        viewController.thumbnailImageHoverController.hide();
        
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the edit/open manga view controller
        editMangaViewController = storyboard.instantiateController(withIdentifier: "editMangaViewController") as? KMEditMangaViewController;
        
        // If we said to hide the popover...
        if(hidden) {
            // Only load the view, but not display
            editMangaViewController?.loadView();
        }
        else {
            // Show the popover
            editMangaViewController!.presentViewController(editMangaViewController!, asPopoverRelativeTo: viewController.backgroundVisualEffectView.bounds, of: viewController.backgroundVisualEffectView, preferredEdge: NSRectEdge.maxY, behavior: NSPopoverBehavior.semitransient);
            
            // Set editPopoverOpen to true
            editPopoverOpen = true;
        }
        
        // Add the selected manga to the list of opened manga
        openedManga.append(manga);
        
        // Say that we want to edit or open this manga
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMMangaGridCollectionItem.Editing"), object: manga);
        
        // If we havent already subscribed to the notifications...
        if(!alreadySubscribed) {
            // Subscribe to the popovers saved function
            NotificationCenter.default.addObserver(self, selector: #selector(KMMangaListController.saveMangaFromPopover(_:)), name:NSNotification.Name(rawValue: "KMEditMangaViewController.Saving"), object: nil);
            
            // Subscribe to the readers update percent finished function
            NotificationCenter.default.addObserver(self, selector: #selector(KMMangaListController.updatePercentFinished(_:)), name:NSNotification.Name(rawValue: "KMMangaGridCollectionItem.UpdatePercentFinished"), object: nil);
            
            // Say we subscribed
            alreadySubscribed = true;
        }
    }
    
    /// Opens all the selected manga
    func openManga() {
        // For every selected manga...
        for(_, currentSelectedManga) in selectedMangaList().enumerated() {
            print("KMMangaListController: Opening \"" + currentSelectedManga.title + "\"");
            
            // Open the popover
            openPopover(true, manga: currentSelectedManga);
            
            // Open the current manga
            (NSApplication.shared().delegate as! AppDelegate).openManga(currentSelectedManga, page: currentSelectedManga.currentPage);
        }
    }
    
    func saveMangaFromPopover(_ notification : Notification) {
        // For every manga in the opened manga...
        for(_, currentManga) in openedManga.enumerated() {
            // If the UUID matches...
            if(currentManga.uuid == (notification.object as? KMManga)!.uuid) {
                print("KMMangaListController: UUID matched for \"" + currentManga.title + "\"");
                
                // Print to the log the manga we received
                print("KMMangaListController: Saving manga \"" + currentManga.title + "\"");
                
                // For every manga inside the opened manga...
                for(_, _) in openedManga.enumerated() {
                    // For every item in the array controller...
                    for(_, currentMangaGridItem) in (self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])!.enumerated() {
                        // If the current grid item's manga's UUID is the same as the notification's manga's UUID...
                        if(currentMangaGridItem.manga.uuid == (notification.object as? KMManga)!.uuid) {
                            // Set the current manga to the notifications manga
                            currentMangaGridItem.changeManga((notification.object as? KMManga)!);
                        }
                    }
                }
                
                // Store the current scroll position and selection
                mangaGridController.storeCurrentSelection();
                
                // Reload the view to match its contents
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ViewController.UpdateMangaGrid"), object: nil);
                
                // Resort the grid
                mangaGridController.resort();
                
                // Redo the search, if there was one
                mangaGridController.redoSearch();
                
                // Restore the scroll position and selection
                mangaGridController.restoreSelection();
            }
        }
    }
    
    func updatePercentFinished(_ notification : Notification) {
        print("KMMangaListController: Updating percent...");
        
        // For every manga in the opened manga...
        for(_, currentManga) in openedManga.enumerated() {
            // If the UUID matches...
            if(currentManga.uuid == (notification.object as? KMManga)!.uuid) {
                print("KMMangaListController: UUID matched for \"" + currentManga.title + "\"");
                
                // Update the passed mangas percent finished
                (notification.object as? KMManga)!.updatePercent();
                
                // Set the current manga's percent done to the passed mangas percent done
                currentManga.percentFinished = ((notification.object as? KMManga)!.percentFinished);
                
                mangaListTableView.reloadData();
            }
        }
    }
    
    /// Sets editPopoverOpen to false
    func sayEditPopoverIsClosed() {
        // Set editPopoverOpen to false
        editPopoverOpen = false;
    }
    
    override func awakeFromNib() {
        // Set the manga list controller's table view reference
        mangaListTableView.mangaListController = self;
        
        // Subscribe to the edit popover's closing notification
        NotificationCenter.default.addObserver(self, selector: #selector(KMMangaListController.sayEditPopoverIsClosed), name: NSNotification.Name(rawValue: "KMEditMangaViewController.Closing"), object: nil);
    }
}

extension KMMangaListController : NSTableViewDataSource {
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        // If the selected row isnt blank and the edit popover is open...
        if(self.mangaListTableView.selectedRowIndexes.first != -1 && self.editPopoverOpen) {
            // Dismiss the edit popover
            self.editMangaViewController?.dismiss(self);
            
            // Show the edit popover with the newly selected manga
            self.openPopover(false, manga: self.selectedManga());
        }
    }
    
    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        /// The width we will set the cell to at the end
        var width : CGFloat = 0;
        
        // For every item in the table view's rows...
        for i in 0...(tableView.numberOfRows - 1) {
            /// The cell view at the current column
            let view = tableView.view(atColumn: column, row: i, makeIfNecessary: true) as! NSTableCellView;
            
            /// The size of this cell's text
            let size = view.textField!.attributedStringValue.size();
            
            // Set width to the to the greatest number in between width and the label's width
            width = max(width, size.width);
        }
        
        // Return the width with 20px of padding
        return width + 20;
    }
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        // Return the number of items in the manga grid array controller
        return (self.mangaGridController.arrayController.arrangedObjects as? [AnyObject])!.count;
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // If this isnt the first time this was called...
        if(!firstSortChange) {
            // Set the sort descriptors of the manga array controller to the sort descriptors to use
            self.mangaGridController.arrayController.sortDescriptors = tableView.sortDescriptors;
            
            // Rearrange the array controller
            self.mangaGridController.arrayController.rearrangeObjects();
        }
        
        // Say any more times after this this is called are not the first
        firstSortChange = false;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the row we are trying to get an item from is in range of the array controller...
        if(row < (self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])!.count) {
            /// This manga list items data
            let searchListItemData = (self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![row];
            
            // If the column is the Title Column...
            if(tableColumn!.identifier == "Title Column") {
                // Set the text of this cell to be the title of this manga
                cellView.textField!.stringValue = searchListItemData.manga.title;
                
                // Set the cells thumbnail image
                (cellView as! KMMangaListTableCellView).thumbnailImage = searchListItemData.manga.coverImage;
                
                // Set the cells thumbnail hover controller
                (cellView as! KMMangaListTableCellView).thumbnailImageHoverController = viewController.thumbnailImageHoverController;
                
                // Set the cells manga list controller
                (cellView as! KMMangaListTableCellView).mangaListController = self;
                
                // Return the modified cell view
                return cellView;
            }
            // If the column is the Series Column...
            else if(tableColumn!.identifier == "Series Column") {
                // Set the text of this cell to be the series of this manga
                cellView.textField!.stringValue = searchListItemData.manga.series;
                
                // Return the modified cell view
                return cellView;
            }
            // If the column is the Author Column...
            else if(tableColumn!.identifier == "Writer Column") {
                // Set the text of this cell to be the author of this manga
                cellView.textField!.stringValue = searchListItemData.manga.writer;
                
                // Return the modified cell view
                return cellView;
            }
            // If the column is the Artist Column...
            else if(tableColumn!.identifier == "Artist Column") {
                // Set the text of this cell to be the artist of this manga
                cellView.textField!.stringValue = searchListItemData.manga.artist;
                
                // Return the modified cell view
                return cellView;
            }
            // If the column is the Percent Column...
            else if(tableColumn!.identifier == "Percent Column") {
                // Set the text of this cell to be the percent finished of this manga with a % on the end
                cellView.textField!.stringValue = String(searchListItemData.manga.percentFinished) + "%";
                
                // Return the modified cell view
                return cellView;
            }
            // If the column is the Favourite Column...
            else if(tableColumn!.identifier == "Favourite Column") {
                // If this item is favourite...
                if(searchListItemData.manga.favourite) {
                    // Set the text of this cell to be a filled star
                    cellView.textField!.stringValue = "★";
                }
                else {
                    // Set the text of this cell to be an empty star
                    cellView.textField!.stringValue = "☆";
                }
                
                // Return the modified cell view
                return cellView;
            }
        }
        
        // Return the unmodified cell view, we didnt need to do anything to this one
        return cellView;
    }
}

extension KMMangaListController : NSTableViewDelegate {
    
}
