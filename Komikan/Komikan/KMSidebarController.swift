//
//  KMSidebarController.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMSidebarController : NSObject {
    
    /// The split view of the window that hodls the sidebar on the left and the grid on the right
    @IBOutlet weak var splitView: KMSidebarSplitView!
    
    /// The items in the table view of the sidebar
    var sidebarTableViewItems : [KMSidebarItemDoc] = [];
    
    /// The table view that holds all the sidebar items
    @IBOutlet weak var sidebarTableView: NSTableView!
    
    /// The little plus button on the bottom right, used for adding groups
    @IBOutlet weak var addButton: NSButton!
    
    /// When we interact with addButton...
    @IBAction func addButtonInteracted(sender: AnyObject) {
        /// The new item we will add to the sidebar
        let newItem : KMSidebarItemDoc = KMSidebarItemDoc(groupName: "Group", groupShowing: true);
        
        // Add the new item to the sidebar
        addItemToSidebar(newItem);
    }
    
    /// The little minus button on the bottom right, used for removing groups
    @IBOutlet weak var removeButton: NSButton!
    
    /// When we interact with removeButton...
    @IBAction func removeButtonInteracted(sender: AnyObject) {
        // Remove the selected item
        removeSelectedItem();
    }
    
    /// Removes the selected item from the sidebar table view
    func removeSelectedItem() {
        // If the selected item is not -1(Which means nothing is selected...)
        if(sidebarTableView.selectedRow != -1) {
            // Remove the selected item from the sidebar items model
            self.sidebarTableViewItems.removeAtIndex(self.sidebarTableView.selectedRow);
            
            // Remove the selected item from the sidebar table view
            self.sidebarTableView.removeRowsAtIndexes(NSIndexSet(index:self.sidebarTableView.selectedRow),
                withAnimation: NSTableViewAnimationOptions.SlideLeft);
        }
<<<<<<< HEAD
        
        // Re hide / show the groups
        mangaGridController.reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
    }
    
    /// Adds item to the sidebar
    func addItemToSidebar(item : KMSidebarItemDoc) {
        // Append the item we were passed to the table view data source
        sidebarTableViewItems.append(item);
        
        // Reload the table view
        sidebarTableView.reloadData();
    }
    
    /// Returns a list of strings for all teh groups that currently exist
    func sidebarGroups() -> [String] {
        /// Hodls all the groups there are
        var groups : [String] = [];
        
        // For every item in the sidebar table view items...
        for(_, currentItem) in sidebarTableViewItems.enumerate() {
            // Append the current item to groups
            groups.append(currentItem.data.groupName);
        }
        
        // Return the groups array
        return groups;
    }
    
    /// The old position of the split view
    var oldSplitViewPosition : CGFloat = 200;
    
    /// Is the sidebar currently open?
    var sidebarOpen : Bool = false;
    
    /// Toggles showing / hiding the sidebar
    func toggleSidebar() {
        // Toggle the sidebarOpen bool
        sidebarOpen = !sidebarOpen;
        
        // If the sidebar is now open...
        if(sidebarOpen) {
            // Show the sidebar
            showSidebar();
        }
        // If the sidebar is now closed...
        else {
            // Hide the sidebar
            hideSidebar();
        }
    }
    
    /// Hides the sidebar
    func hideSidebar() {
        // Set the old split view position to the width of the first pane(The sidebar)
        oldSplitViewPosition = splitView.subviews[0].frame.size.width;
        
        // Set the first panes position to 0
        splitView.setPosition(0, ofDividerAtIndex: 0);
        
        // Set sidebarOpen to false
        sidebarOpen = false;
    }
    
    /// Shows the sidebar
    func showSidebar() {
        // Set the split views first panes size to the old size it was before it was hidden(The first pane is the sidebar)
        splitView.setPosition(oldSplitViewPosition, ofDividerAtIndex: 0);
        
        // Set sidebarOpen to false
        sidebarOpen = true;
    }
    
    /// Saves the sidebars iems to NSUserDefaults
    func saveSidebar() {
        // Create a NSKeyedArchiver data with the sidebars table views items
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.sidebarTableViewItems);
        
        // Set the standard user defaults sidebarTableViewItems key to that data
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "sidebarTableViewItems");
        
        // Synchronize the data
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    /// Loads back the sidebars items from NSUserDefaults
    func loadSidebar() {
        // If we have any data to load...
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("sidebarTableViewItems") as? NSData {
            // For every KMSidebarItemDoc in the saved sidebar table view items...
            for (_, currentItem) in (NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [KMSidebarItemDoc]).enumerate() {
                // Add the current object to the sidebar
                sidebarTableViewItems.append(currentItem);
            }
        }
        
        // Reload the sidebar data
        sidebarTableView.reloadData();
    }
}

extension KMSidebarController : NSTableViewDataSource {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the count of tableViewItems
        return self.sidebarTableViewItems.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view it is asking us about for the data
        let cellView : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView;
        
        // If the column is the SidebarColumn...
        if(tableColumn!.identifier == "SidebarColumn") {
            // Get this items doc
            let sidebarItemDoc = self.sidebarTableViewItems[row];
            
            // Set the text fields value to the groups name
            cellView.textField!.stringValue = sidebarItemDoc.data.groupName;
            
            // Set the checkboxes value to if this group is showing
            (cellView as? KMSidebarTableCellView)?.checkbox.state = Int(sidebarItemDoc.data.groupShowing);
            
            // Set the cell views data so it can update it as it is changed
            (cellView as? KMSidebarTableCellView)?.data = sidebarItemDoc.data;
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we didnt neeed to do anything to this one
        return cellView;
    }
}

extension KMSidebarController : NSTableViewDelegate {
    
}