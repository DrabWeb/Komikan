//
//  KMMassSetGroupViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMassSetGroupViewController: NSViewController {
    
    // KMMassSetGroupViewController.Finished
    
    /// The visual effect view for the background of the popover
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The combo box that lets you set the group
    @IBOutlet weak var groupSelectionComboBox: NSComboBox!

    /// When we interact with groupSelectionComboBox...
    @IBAction func groupSelectionComboBoxInteracted(sender: AnyObject) {
        print(groupSelectionComboBox.stringValue);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    func loadGroups() {
        // Set the group selection combo boxes dropdown items to all the groups we have made
        groupSelectionComboBox.addItemsWithObjectValues((NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.sidebarGroups());
    }
    
    func styleWindow() {
        // Set the background visual effect views material to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
