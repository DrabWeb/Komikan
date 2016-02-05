//
//  KMSidebarTableCellView.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMSidebarTableCellView: NSTableCellView {
    
    /// The KMSidebarData that this cell will update
    var data : KMSidebarItemData = KMSidebarItemData(groupName: "Group");
    
    /// The checkbox for this item that says if this group is hidden or shown
    @IBOutlet weak var checkbox : NSButton!
    
    /// When we interact with the checkbox...
    @IBAction func checkboxInteracted(sender: AnyObject) {
        // Set the datas group showing bool to the checkboxes state
        data.groupShowing = Bool(checkbox.state);
        
        // Post the notification to update what groups we are displaying in the grid
        NSNotificationCenter.defaultCenter().postNotificationName("MangaGrid.DisplayGroups", object: nil);
    }
    
    /// When we interact with the textfield...
    @IBAction func textFieldInteracted(sender: AnyObject) {
        // Set the datas group name to the text fields string value
        data.groupName = self.textField!.stringValue;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
