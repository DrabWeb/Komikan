//
//  KMGroupListTableViewCell.swift
//  Komikan
//
//  Created by Seth on 2016-02-14.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMSearchListTableViewCell: NSTableCellView {
    
    /// The checkbox for the table view
    @IBOutlet weak var checkbox: NSButton!
    
    /// When we click on the checkbox...
    @IBAction func checkboxInteracted(sender: AnyObject) {
        // Update the datas checked value to match the checkbox
        data.checked = Bool(checkbox.state);
    }
    
    /// The text field to tell the user what type this item is
    @IBOutlet weak var typeLabel: NSTextField!
    
    /// The data object to update with the checkbox
    var data : KMSearchListItemData = KMSearchListItemData();
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
