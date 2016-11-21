//
//  KMGroupListViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-14.
//

import Cocoa

class KMSearchListViewController: NSViewController {

    /// The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The table view for the search list
    @IBOutlet weak var searchListTableView: NSTableView!
    
    /// When we click the "Filter" button...
    @IBAction func filterButtonPressed(_ sender: AnyObject) {
        // Apply the search filter
        applyFilter();
    }
    
    /// When we click the "Select All" button...
    @IBAction func selectAllButtonPressed(_ sender: AnyObject) {
        // For every search list item...
        for(_, currentSearchListItem) in searchListItems.enumerated() {
            // Set the current search list item to be selected
            currentSearchListItem.checked = true;
        }
        
        // Reload the table view
        searchListTableView.reloadData();
    }
    
    /// When we click the "Deselect All" button...
    @IBAction func deselectAllButtonPressed(_ sender: AnyObject) {
        // For every search list item...
        for(_, currentSearchListItem) in searchListItems.enumerated() {
            // Set the current search list item to be deselected
            currentSearchListItem.checked = false;
        }
        
        // Reload the table view
        searchListTableView.reloadData();
    }
    
    /// The search list items for the search list table view
    var searchListItems : [KMSearchListItemData] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Load the items
        loadItems();
        
        // Deselect all the items
        // For every search list item...
        for(_, currentSearchListItem) in searchListItems.enumerated() {
            // Set the current search list item to be deselected
            currentSearchListItem.checked = false;
        }
        
        // Reload the table view
        searchListTableView.reloadData();
    }
    
    func loadItems() {
        // Remove all the group items
        searchListItems.removeAll();
        
        // For every series the user has in the manga grid...
        for(_, currentSeries) in (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allSeries().enumerated() {
            // Add the current series to the search list items
            searchListItems.append(KMSearchListItemData(name: currentSeries, type: KMPropertyType.series));
            
            // Set the items count to the amount of times it's series appears
            searchListItems.last!.count = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.countOfSeries(currentSeries);
        }
        
        // For every artist the user has in the manga grid...
        for(_, currentArtist) in (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allArtists().enumerated() {
            // Add the current artist to the search list items
            searchListItems.append(KMSearchListItemData(name: currentArtist, type: KMPropertyType.artist));
            
            // Set the items count to the amount of times it's artist appears
            searchListItems.last!.count = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.countOfArtist(currentArtist);
        }
        
        // For every writer the user has in the manga grid...
        for(_, currentWriter) in (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allWriters().enumerated() {
            // Add the current writer to the search list items
            searchListItems.append(KMSearchListItemData(name: currentWriter, type: KMPropertyType.writer));
            
            // Set the items count to the amount of times it's writer appears
            searchListItems.last!.count = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.countOfWriter(currentWriter);
        }
        
        // For every tag the user has in the manga grid...
        for(_, currentTag) in (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allTags().enumerated() {
            // Add the current tag to the search list items
            searchListItems.append(KMSearchListItemData(name: currentTag, type: KMPropertyType.tags));
            
            // Set the items count to the amount of times it's tag appears
            searchListItems.last!.count = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.countOfTag(currentTag);
        }
        
        // For every group the user has in the manga grid...
        for(_, currentGroup) in (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allGroups().enumerated() {
            // Add the current group to the search list items
            searchListItems.append(KMSearchListItemData(name: currentGroup, type: KMPropertyType.group));
            
            // Set the items count to the amount of times it's group appears
            searchListItems.last!.count = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.countOfGroup(currentGroup);
        }
        
        // Reload the table view
        searchListTableView.reloadData();
    }
    
    /// Takes everything we checked/unchecked and filters by them
    func applyFilter() {
        /// The string we will search by
        var searchString : String = "";
        
        /// Is this the first series search item?
        var firstOfSeriesSearch : Bool = true;
        
        /// Is this the first artist search item?
        var firstOfArtistSearch : Bool = true;
        
        /// Is this the first writer search item?
        var firstOfWriterSearch : Bool = true;
        
        /// Is this the first tags search item?
        var firstOfTagsSearch : Bool = true;
        
        /// Is this the first group search item?
        var firstOfGroupSearch : Bool = true;
        
        // For every item in the search list items...
        for(_, currentItem) in searchListItems.enumerated() {
            // If the current item is checked...
            if(currentItem.checked) {
                // If the current item is for a series...
                if(currentItem.type == .series) {
                    // If this is the first series search term...
                    if(firstOfSeriesSearch) {
                        // Add the series search group marker
                        searchString += "s:\"";
                        
                        // Say this is no longer the first series search term
                        firstOfSeriesSearch = false;
                    }
                    
                    // Add the current series to the search string
                    searchString += currentItem.name + ", ";
                }
                // If the current item is for an artist...
                else if(currentItem.type == .artist) {
                    // If this is the first artist search term...
                    if(firstOfArtistSearch) {
                        // If the search string isnt blank...
                        if(searchString != "") {
                            // Remove the extra ", " from the search string
                            searchString = searchString.substring(to: searchString.index(before: searchString.characters.index(before: searchString.endIndex)));
                            
                            // Add the "" a:"" to the search string to denote a new search type
                            searchString += "\" a:\"";
                        }
                        else {
                            // Add the artist search group marker
                            searchString += "a:\"";
                        }
                        
                        // Say this is no longer the first artist search term
                        firstOfArtistSearch = false;
                    }
                    
                    // Add the current artist to the search string
                    searchString += currentItem.name + ", ";
                }
                // If the current item is for a writer...
                else if(currentItem.type == .writer) {
                    // If this is the first writer search term...
                    if(firstOfWriterSearch) {
                        // If the search string isnt blank...
                        if(searchString != "") {
                            // Remove the extra ", " from the search string
                            searchString = searchString.substring(to: searchString.index(before: searchString.characters.index(before: searchString.endIndex)));
                            
                            // Add the "" w:"" to the search string to denote a new search type
                            searchString += "\" w:\"";
                        }
                        else {
                            // Add the writer search group marker
                            searchString += "w:\"";
                        }
                        
                        // Say this is no longer the first writer search term
                        firstOfWriterSearch = false;
                    }
                    
                    // Add the current artist to the search string
                    searchString += currentItem.name + ", ";
                }
                // If the current item is for tags...
                else if(currentItem.type == .tags) {
                    // If this is the first tag search term...
                    if(firstOfTagsSearch) {
                        // If the search string isnt blank...
                        if(searchString != "") {
                            // Remove the extra ", " from the search string
                            searchString = searchString.substring(to: searchString.index(before: searchString.characters.index(before: searchString.endIndex)));
                            
                            // Add the "" tg:"" to the search string to denote a new search type
                            searchString += "\" tg:\"";
                        }
                        else {
                            // Add the tags search group marker
                            searchString += "tg:\"";
                        }
                        
                        // Say this is no longer the first tags search term
                        firstOfTagsSearch = false;
                    }
                    
                    // Add the current artist to the search string
                    searchString += currentItem.name + ", ";
                }
                // If the current item is for a group...
                else if(currentItem.type == .group) {
                    // If this is the first group search term...
                    if(firstOfGroupSearch) {
                        // If the search string isnt blank...
                        if(searchString != "") {
                            // Remove the extra ", " from the search string
                            searchString = searchString.substring(to: searchString.index(before: searchString.characters.index(before: searchString.endIndex)));
                            
                            // Add the "" g:"" to the search string to denote a new search type
                            searchString += "\" g:\"";
                        }
                        else {
                            // Add the group search group marker
                            searchString += "g:\"";
                        }
                        
                        // Say this is no longer the first group search term
                        firstOfGroupSearch = false;
                    }
                    
                    // Add the current artist to the search string
                    searchString += currentItem.name + ", ";
                }
            }
        }
        
        // If the search string isnt blank...
        if(searchString != "") {
            // Remove the extra ", " from the search string
            searchString = searchString.substring(to: searchString.index(before: searchString.characters.index(before: searchString.endIndex)));
            
            // Add the """ at the end of the search string to denote the end of the final search term
            searchString += "\"";
        }
        
        // Set the search fields value to the search string we created
        (NSApplication.shared().delegate as! AppDelegate).searchTextField.stringValue = searchString;
        
        // Search for the search string
        (NSApplication.shared().delegate as! AppDelegate).mangaGridController.searchFor(searchString);
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the background to be more vibrant
        backgroundVisualEffectView.material = NSVisualEffectMaterial.dark;
    }
}

extension KMSearchListViewController: NSTableViewDelegate {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        // Return the amount of search list items
        return self.searchListItems.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the column is the Main Column...
        if(tableColumn!.identifier == "Main Column") {
            /// This items search list data
            let searchListItemData = self.searchListItems[row];
            
            // Set the label's string value to the search list items name
            cellView.textField!.stringValue = searchListItemData.name;
            
            // Set the checkbox to be checked/unchecked based on if the cell view item is checked
            (cellView as? KMSearchListTableViewCell)?.checkbox.state = Int(searchListItemData.checked as NSNumber);
            
            // Set the type label's string value to be this item's type with the count at the end in parenthesis
            (cellView as? KMSearchListTableViewCell)?.typeLabel.stringValue = KMEnumUtilities().propertyTypeToString(searchListItemData.type!) + "(" + String(searchListItemData.count) + ")";
            
            // Set the cell views data so it can update it as it is changed
            (cellView as? KMSearchListTableViewCell)?.data = searchListItemData;
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we didnt need to do anything to this one
        return cellView;
    }
}

extension KMSearchListViewController: NSTableViewDataSource {
    
}
