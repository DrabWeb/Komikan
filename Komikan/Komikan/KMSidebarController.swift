//
//  KMSidebarController.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMSidebarController : NSObject {
    
<<<<<<< HEAD
=======
    /// The split view of the window that hodls the sidebar on the left and the grid on the right
    @IBOutlet weak var splitView: KMSidebarSplitView!
    
    /// The items in the table view of the sidebar
    var sidebarTableViewItems : [KMSidebarItemDoc] = [];
    
    /// The manga grid controller
    @IBOutlet weak var mangaGridController: KMMangaGridController!
    
    /// The table view that holds all the sidebar items
    @IBOutlet weak var sidebarTableView: NSTableView!
    
    /// The little plus button on the bottom right, used for adding groups
>>>>>>> fb5ef9b9784add74fe9f4ca33dae94834e161ce8
    @IBOutlet weak var addButton: NSButton!
    
    @IBAction func addButtonInteracted(sender: AnyObject) {
        print("Add");
    }
    
    @IBOutlet weak var removeButton: NSButton!
    
    @IBAction func removeButtonInteracted(sender: AnyObject) {
<<<<<<< HEAD
        print("Remove");
=======
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
        
        // Re hide / show the groups
        mangaGridController.displayGroupsSidebarController();
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
>>>>>>> fb5ef9b9784add74fe9f4ca33dae94834e161ce8
    }
}