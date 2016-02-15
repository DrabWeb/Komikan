//
//  KMGroupListViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-14.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMGroupListViewController: NSViewController {

    /// The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The table view for the group list
    @IBOutlet weak var groupListTableView: NSTableView!
    
    /// When we click the "Filter" button...
    @IBAction func filterButtonPressed(sender: AnyObject) {
        filterGroups();
    }
    
    /// The group lists table view items
    var groupItems : [KMGroupListItemData] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Load the group items
        loadGroupItems();
    }
    
    func loadGroupItems() {
        // Remove all the group items
        groupItems.removeAll();
        
        // For every group the user has in the manga grid...
        for(_, currentGroup) in (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allGroups().enumerate() {
            // Add the current group to the group items
            groupItems.append(KMGroupListItemData(groupName: currentGroup));
        }
        
        // Reload the table view
        groupListTableView.reloadData();
    }
    
    /// Takes groupItems and searches by their groups
    func filterGroups() {
        /// The string we will search by groups for
        var searchString : String = "g:";
        
        /// How many selected groups did we have?
        var checkedGroupCount : Int = 0;
        
        // For every group item in the group items
        for(_, currentFilterGroup) in groupItems.enumerate() {
            // If the group item is checked...
            if(currentFilterGroup.checked) {
                // Append a ", "
                searchString.appendContentsOf(currentFilterGroup.groupName + ", ");
                
                // Add 1 to the checked group count
                checkedGroupCount++;
            }
        }
        
        // Remove the last two characters of the string
        searchString = searchString.substringToIndex(searchString.endIndex.predecessor().predecessor());
        
        // If the search string isnt blank...
        if(searchString != "") {
            // Append a ";" to the search string
            searchString.appendContentsOf(";");
        }
        
        // If the checked group count is equal to the amount of group items we have...
        if(checkedGroupCount == groupItems.count) {
            // Clear the search string
            searchString = "";
        }
        
        // Set the search fields value to the search string we created
        (NSApplication.sharedApplication().delegate as! AppDelegate).searchTextField.stringValue = searchString;
        
        // Search for the search string
        (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.searchFor(searchString);
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the background to be more vibrant
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}

extension KMGroupListViewController: NSTableViewDelegate {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the amount of group items
        return self.groupItems.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the column is the SidebarColumn...
        if(tableColumn!.identifier == "MainColumn") {
            /// This items group data
            let groupItemData = self.groupItems[row];
            
            // Set the checkboxes string value to the group items group name
            cellView.textField!.stringValue = groupItemData.groupName;
            
            // Set the cell views data so it can update it as it is changed
            (cellView as? KMGroupListTableViewCell)?.data = groupItemData;
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we didnt need to do anything to this one
        return cellView;
    }
}

extension KMGroupListViewController: NSTableViewDataSource {
    
}