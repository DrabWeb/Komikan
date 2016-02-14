//
//  KMGroupListItemData.swift
//  Komikan
//
//  Created by Seth on 2016-02-14.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMGroupListItemData: NSObject {
    /// The name of this items group
    var groupName : String = "";
    
    /// Is this group item checked off?
    var checked : Bool = true;
    
    // A simple init with no parameters
    override init() {
        self.groupName = "";
        self.checked = false;
    }
    
    // An init with just a group name
    init(groupName : String) {
        self.groupName = groupName;
    }
    
    // An init with a group name and defining if its checked off
    init(groupName : String, checked : Bool) {
        self.groupName = groupName;
        self.checked = checked;
    }
}
