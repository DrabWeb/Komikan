//
//  KMSidebarController.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMSidebarController : NSObject {
    
    @IBOutlet weak var addButton: NSButton!
    
    @IBAction func addButtonInteracted(sender: AnyObject) {
        print("Add");
    }
    
    @IBOutlet weak var removeButton: NSButton!
    
    @IBAction func removeButtonInteracted(sender: AnyObject) {
        print("Remove");
    }
}