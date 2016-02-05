//
//  KMSidebarItemData.swift
//  Komikan
//
//  Created by Seth on 2016-02-05.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMSidebarItemData : NSObject, NSCoding {
    /// The name for this group
    var groupName : String = "";
    
    /// Is this group showing?
    var groupShowing : Bool = true;
    
    /// An init with a name
    init(groupName: String) {
        self.groupName = groupName;
    }
    
    /// An init with a name and setting if the group is showing
    init(groupName : String, groupShowing : Bool) {
        self.groupName = groupName;
        self.groupShowing = groupShowing;
    }
    
    func encodeWithCoder(coder: NSCoder) {
        // Encode the name and showing values
        coder.encodeObject(self.groupName, forKey: "groupName");
        coder.encodeObject(self.groupShowing, forKey: "groupShowing");
    }
    
    required convenience init(coder decoder: NSCoder) {
        // Init with a default name
        self.init(groupName: "Group");
        
        // Decode and load the name and showing values
        self.groupName = (decoder.decodeObjectForKey("groupName") as? String)!;
        self.groupShowing = (decoder.decodeObjectForKey("groupShowing") as? Bool)!;
    }
}