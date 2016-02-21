//
//  KMGroupListItemData.swift
//  Komikan
//
//  Created by Seth on 2016-02-14.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMSearchListItemData: NSObject {
    /// The name of this item
    var name : String = "";
    
    /// Is this item checked off?
    var checked : Bool = true;
    
    /// The type this item is
    var type : KMPropertyType?;
    
    // A simple init with no parameters
    override init() {
        self.name = "";
        self.checked = false;
    }
    
    // An init with just a name
    init(name : String) {
        self.name = name;
    }
    
    // An init with a name and type
    init(name : String, type : KMPropertyType) {
        self.name = name;
        self.type = type;
    }
    
    // An init with a group name and defining if its checked off
    init(name : String, checked : Bool) {
        self.name = name;
        self.checked = checked;
    }
}
