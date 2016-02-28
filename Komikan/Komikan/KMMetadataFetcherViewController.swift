//
//  KMMetadataFetcherViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa
import Alamofire

class KMMetadataFetcherViewController: NSViewController {
    
    /// The visual effect view for the background of the popover
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The view to animate transitions between views in the popover
    @IBOutlet var viewContainer: NSView!
    
    /// The view for searching for the series to grab the metadata from
    @IBOutlet var searchViewContainer: NSView!
    
    /// The view for applying the properties of the chosen series
    @IBOutlet var applyingViewContainer: NSView!
    
    /// The NSSearchField for the user to search for the series they want the metadata for
    @IBOutlet var seriesSearchField: NSSearchField!
    
    /// When text is entered into seriesSearchField...
    @IBAction func seriesSearchFieldInteracted(sender: AnyObject) {
        // Clear the results table
        seriesSearchResultsItems.removeAll();
        
        // Search for the entered text
        KMMetadataFetcher().searchForManga(seriesSearchField.stringValue, completionHandler: searchCompletionHandler);
    }
    
    /// The table view for the search results of the series search
    @IBOutlet var seriesSearchResultsTableView: NSTableView!
    
    /// The popup button in the apply properties view to choose whether or not to change the series
    @IBOutlet var applyPropertiesSeriesPopupButton: NSPopUpButton!
    
    /// The popup button in the apply properties view to choose whether or not to change the artist
    @IBOutlet var applyPropertiesArtistPopupButton: NSPopUpButton!
    
    /// The popup button in the apply properties view to choose whether or not to change the writer
    @IBOutlet var applyPropertiesWritersPopupButton: NSPopUpButton!
    
    /// The popup button in the apply properties view to choose whether or not to change the tags
    @IBOutlet var applyPropertiesTagsPopupButton: NSPopUpButton!
    
    /// The popup button in the apply properties view to choose whether or not to change the cover, and if so what cover to use
    @IBOutlet var applyPropertiesCoverPopupButton: KMMetadataFetcherCoverSelectionPopUpButton!
    
    /// The checkbox for the apply properties view to say if we want to append tags
    @IBOutlet var applyPropertiesAppendTagsCheckbox: NSButton!
    
    /// When we click the "Apply" button in the apply properties view...
    @IBAction func applyPropertiesApplyButtonPressed(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        // Apply the metadata
        applyMetadata();
    }
    
    /// The items for the series search results table view
    var seriesSearchResultsItems : [KMMetadataFetcherSeriesSearchResultsItemData] = [];
    
    /// The KMMangaGridItem we have selected in the manga grid
    var selectedMangaGridItems : [KMMangaGridItem] = [];
    
    /// The series metadata the user selected
    var seriesMetadata : KMSeriesMetadata = KMSeriesMetadata();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        /// All the names of the series of the selected manga
        var selectedMangaSeries : [String] = [];
        
        // For every selected manga grid item...
        for(_, currentMangaGridItem) in selectedMangaGridItems.enumerate() {
            // Add this grid item's manga's series to the selected manga's series array
            selectedMangaSeries.append(currentMangaGridItem.manga.series);
        }
        
        // Set the search field to have the most frequent series
        seriesSearchField.stringValue = selectedMangaSeries.frequencies()[0].0;
        
        // Search for the series search fields string value
        KMMetadataFetcher().searchForManga(seriesSearchField.stringValue, completionHandler: searchCompletionHandler);
    }
    
    /// Applys the chosen metadata to the selected manga
    func applyMetadata() {
        // Print to the log that we are applying metadata
        print("Applying metadata to selected manga");
        
        // For every manga grid item in the selected manga grid item...
        for(_, currentMangaGridItem) in selectedMangaGridItems.enumerate() {
            /// The current items manga with the new modified values
            let modifiedManga : KMManga = currentMangaGridItem.manga;
            
            // If we said to set the series...
            if(applyPropertiesSeriesPopupButton.selectedItem?.title != "Dont Change") {
                // Set the series of the current manga to the selected series
                modifiedManga.series = applyPropertiesSeriesPopupButton.selectedItem!.title;
            }
            
            // If we said to set the artists...
            if(applyPropertiesArtistPopupButton.selectedItem?.title != "Dont Change") {
                // Set the artists of the current manga to the selected artists
                modifiedManga.artist = applyPropertiesArtistPopupButton.selectedItem!.title;
            }
            
            // If we said to set the writers...
            if(applyPropertiesWritersPopupButton.selectedItem?.title != "Dont Change") {
                // Set the writers of the current manga to the selected writers
                modifiedManga.writer = applyPropertiesWritersPopupButton.selectedItem!.title;
            }
            
            // If we said to set the tags...
            if(applyPropertiesTagsPopupButton.selectedItem?.title != "Dont Change") {
                // If we said to append the tags...
                if(Bool(applyPropertiesAppendTagsCheckbox.state)) {
                    // Append the metadatas tags to the current manga's tags
                    modifiedManga.tags.appendContentsOf(seriesMetadata.tags);
                }
                // If we said to replace the tags...
                else {
                    // Replace the current manga's tags with the metadata's tags
                    modifiedManga.tags = seriesMetadata.tags;
                }
            }
            
            // If we said to set the cover...
            if(applyPropertiesCoverPopupButton.selectedItem?.title != "Dont Change") {
                // Set the current manga's cover to the chosen cover
                modifiedManga.coverImage = applyPropertiesCoverPopupButton.selectedItem!.image!;
            }
            
            // Change the current grid items manga to the modified manga
            currentMangaGridItem.changeManga(modifiedManga);
            
            // Print to the log what manga we applied the metadata to
            print("Applied fetched metadata to \"" + modifiedManga.title + "\"");
        }
        
        // Post the notification to say we are done applying metadata
        NSNotificationCenter.defaultCenter().postNotificationName("KMMetadataFetcherViewController.Finished", object: nil);
    }
    
    // This will get called when the series search is completed
    func searchCompletionHandler(searchResults : [KMMetadataInfo]?, error : NSError?) {
        // If there were any search results...
        if(!(searchResults!.isEmpty)) {
            // For every item in the results of the search...
            for(_, currentItem) in searchResults!.enumerate() {
                // Add the current item's title and MU ID to the series search results table
                seriesSearchResultsItems.append(KMMetadataFetcherSeriesSearchResultsItemData(seriesName: currentItem.title, seriesId: currentItem.id));
            }
            
            // Reload the search results table view
            seriesSearchResultsTableView.reloadData();
        }
        // If there were no search results...
        else {
            // Clear the search results table
            seriesSearchResultsItems.removeAll();
            
            // Reload the search results table view
            seriesSearchResultsTableView.reloadData();
        }
    }
    
    // This will get called when the metadata fetching is completed
    func seriesMetadataCompletionHandler(metadata : KMSeriesMetadata?, error : NSError?) {
        // Set the series metadata
        seriesMetadata = metadata!;
        
        // Transition in the applying view
        viewContainer.animator().replaceSubview(searchViewContainer, with: applyingViewContainer);
        
        // Add the title and alternate titles to the series popup
        applyPropertiesSeriesPopupButton.addItemWithTitle(metadata!.title);
        applyPropertiesSeriesPopupButton.addItemsWithTitles(metadata!.alternateTitles);
        
        // Add the writers to the writers popup
        applyPropertiesWritersPopupButton.addItemWithTitle(metadata!.writers.listString());
        
        // Add the artists to the artists popup
        applyPropertiesArtistPopupButton.addItemWithTitle(metadata!.artists.listString());
        
        // Add the tags to the tags popup
        applyPropertiesTagsPopupButton.addItemWithTitle(metadata!.tags.listString());
        
        // For evert cover URL...
        for(_, currentCover) in metadata!.coverURLs.enumerate() {
            // Download the image with Alamofire...
            Alamofire.request(.GET, currentCover.absoluteString.stringByRemovingPercentEncoding!).response { (request, response, data, error) in
                // The new menu item we will add to the covers popup
                let newCoverItem : NSMenuItem = NSMenuItem();
                
                // Set the new items image to the cover we downloaded
                newCoverItem.image = NSImage(data: data!);
                
                // Clear the title of the new item
                newCoverItem.title = "";
                
                // Resize the new items cover to 400 height
                newCoverItem.image = newCoverItem.image?.resizeToHeight(400);
                
                // Add the new itme to the covers popup
                self.applyPropertiesCoverPopupButton.menu?.addItem(newCoverItem);
                
                // Select the first cover
                self.applyPropertiesCoverPopupButton.selectItemAtIndex(2);
            }
        }
        
        // Select the first added item in all the popups
        applyPropertiesSeriesPopupButton.selectItemAtIndex(2);
        applyPropertiesWritersPopupButton.selectItemAtIndex(2);
        applyPropertiesArtistPopupButton.selectItemAtIndex(2);
        applyPropertiesTagsPopupButton.selectItemAtIndex(2);
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the background to be more vibrant
        backgroundVisualEffectView.material = .Dark;
    }
}

extension KMMetadataFetcherViewController: NSTableViewDelegate {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the amount of series search result items
        return self.seriesSearchResultsItems.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the column is the Main Column...
        if(tableColumn!.identifier == "Main Column") {
            // If the item at the wanted index exists...
            if(row < self.seriesSearchResultsItems.count) {
                /// This items search result item data
                let seriesSearchResultListItemData = self.seriesSearchResultsItems[row];
                
                // Set the label's string value to the search results item data
                cellView.textField!.stringValue = seriesSearchResultListItemData.seriesName;
                
                /// Set the data of the cell
                (cellView as? KMMetadataFetcherSeriesSearchResultsTableViewCell)?.data = seriesSearchResultListItemData;
                
                /// Set the cell's button's action to call seriesSearchResultItemPressed
                (cellView as? KMMetadataFetcherSeriesSearchResultsTableViewCell)?.selectButton.action = Selector("seriesSearchResultItemPressed:");
                
                // Return the modified cell view
                return cellView;
            }
        }
        
        // Return the unmodified cell view, we didnt need to do anything to this one
        return cellView;
    }
    
    /// Called when we click on an item in the series search results
    func seriesSearchResultItemPressed(sender : AnyObject?) {
        /// The sender converted to KMMetadataFetcherSeriesSearchResultsTableViewCell
        let senderCell : KMMetadataFetcherSeriesSearchResultsTableViewCell = ((sender as! NSButton).superview as? KMMetadataFetcherSeriesSearchResultsTableViewCell)!;
        
        // Print to the log what teh user selectedand its ID
        print("Chose \"" + senderCell.data.seriesName + "\", ID:", senderCell.data.seriesId);
        
        /// The metadata info we will use to get the metadata for the selected item
        let metadataInfo : KMMetadataInfo = KMMetadataInfo(title: senderCell.data.seriesName, id: senderCell.data.seriesId);
        
        // Call the metadata getter so we can load the metadata
        KMMetadataFetcher().getSeriesMetadata(metadataInfo, completionHandler: seriesMetadataCompletionHandler);
    }
}

extension KMMetadataFetcherViewController: NSTableViewDataSource {
    
}
