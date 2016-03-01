//
//  KMMangaListController.swift
//  Komikan
//
//  Created by Seth on 2016-02-29.
//  Copyright © 2016 DrabWeb. All rights reserved.
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
    @IBAction func mangaListTableViewClicked(sender: AnyObject) {
        // If we double clicked...
        if(NSApplication.sharedApplication().currentEvent?.clickCount == 2) {
            // Open the selected manga
            openManga();
        }
    }
    
    /// A little bool to stop the manga list from resorting at launch, otherwise it messes stuff up
    var firstSortChange : Bool = true;
    
    // The view controller we will load for the edit/open manga popover
    var editMangaViewController: KMEditMangaViewController?
    
    /// Returns the selected manga from the table view
    func selectedManga() -> KMManga {
        // Get the manga at the selected row in the array controller
        return ((self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![mangaListTableView.selectedRow].manga);
    }
    
    func openPopover(hidden : Bool) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the edit/open manga view controller
        editMangaViewController = storyboard.instantiateControllerWithIdentifier("editMangaViewController") as? KMEditMangaViewController;
        
        // If we said to hide the popover...
        if(hidden) {
            // Only load the view, but not display
            editMangaViewController?.loadView();
        }
        else {
            // Show the popover
            editMangaViewController!.presentViewController(editMangaViewController!, asPopoverRelativeToRect: viewController.backgroundVisualEffectView.bounds, ofView: viewController.backgroundVisualEffectView, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Semitransient);
        }
        
        // Say that we want to edit or open this manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMMangaGridCollectionItem.Editing", object: selectedManga());
        
        // Subscribe to the popovers saved function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveMangaFromPopover:", name:"KMEditMangaViewController.Saving", object: nil);
        
        // Subscribe to the readers update percent finished function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePercentFinished:", name:"KMMangaGridCollectionItem.UpdatePercentFinished", object: nil);
    }
    
    func openManga() {
        // Open the popover
        openPopover(false);
        
        // Open the selected manga manga
        (NSApplication.sharedApplication().delegate as! AppDelegate).openManga(selectedManga(), page: selectedManga().currentPage);
    }
    
    func saveMangaFromPopover(notification : NSNotification) {
        // If the UUID matches...
        if(selectedManga().uuid == (notification.object as? KMManga)!.uuid) {
            // Print to the log the manga we received
            print("Saving manga \"" + selectedManga().title + "\"");
            
            // Set the selected manga to the notifications manga
            viewController.selectedGridItems()[0].changeManga((notification.object as? KMManga)!);
            
            // Remove the observer so we dont get duplicate calls
            NSNotificationCenter.defaultCenter().removeObserver(self);
            
            // Reload the view to match its contents
            NSNotificationCenter.defaultCenter().postNotificationName("ViewController.UpdateMangaGrid", object: nil);
            
            // Tell the manga grid to resort itself
            NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.Resort", object: nil);
        }
    }
    
    func updatePercentFinished(notification : NSNotification) {
        // If the UUID matches...
        if(selectedManga().uuid == (notification.object as? KMManga)!.uuid) {
            // Update the passed mangas percent finished
            (notification.object as? KMManga)!.updatePercent();
            
            // Set the selected manga's percent done to the passed mangas percent done
            selectedManga().percentFinished = ((notification.object as? KMManga)!.percentFinished);
        }
    }
    
    override func awakeFromNib() {
        // Set the manga list controller's table view reference
        mangaListTableView.mangaListController = self;
    }
}

extension KMMangaListController : NSTableViewDataSource {
    
    func tableView(tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        /// The width we will set the cell to at the end
        var width : CGFloat = 0;
        
        // For every item in the table view's rows...
        for i in 0...(tableView.numberOfRows - 1) {
            /// The cell view at the current column
            let view = tableView.viewAtColumn(column, row: i, makeIfNecessary: true) as! NSTableCellView;
            
            /// The size of this cell's text
            let size = view.textField!.attributedStringValue.size();
            
            // Set width to the to the greatest number in widthand the label's width
            width = max(width, size.width);
        }
        
        // Return the width with 20px of padding
        return width + 20;
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the number of items in the manga grid array controller
        return (self.mangaGridController.arrayController.arrangedObjects as? [AnyObject])!.count;
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
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
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the row we are trying to get an item from is in range of the array controller...
        if(row < (self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])!.count) {
            /// This manga list items data
            let searchListItemData = (self.mangaGridController.arrayController.arrangedObjects as? [KMMangaGridItem])![row];
            
            // If the column is the Title Column...
            if(tableColumn!.identifier == "Title Column") {
                // Set the text of this cell to be the title of this manga
                cellView.textField!.stringValue = searchListItemData.manga.title;
                
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