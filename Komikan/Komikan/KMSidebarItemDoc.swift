//
//  KMSidebarItemDoc.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMSidebarItemDoc : NSObject, NSCoding {
    /// This items data
    var data : KMSidebarItemData = KMSidebarItemData(groupName: "");
    
    /// An init with a group name
    init(groupName : String) {
        self.data = KMSidebarItemData(groupName: groupName);
    }
    
    /// An init with a group name and if the group is showing
    init(groupName : String, groupShowing : Bool) {
        self.data = KMSidebarItemData(groupName: groupName, groupShowing: groupShowing);
    }
    
    func encodeWithCoder(coder: NSCoder) {
        // Encode the data object
        coder.encodeObject(self.data, forKey: "data");
    }
    
    required convenience init(coder decoder: NSCoder) {
        // Init with a default name
        self.init(groupName: "Group");
        
        // Decode and load the data object
        self.data = (decoder.decodeObjectForKey("data") as? KMSidebarItemData)!;
    }
}