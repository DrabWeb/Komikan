//
//  KMMangaGroupItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGroupItem: NSObject {
    /// The image to display as a "cover" for this group
    var groupImage : NSImage = NSImage(named: "NSCaution")!;
    
    /// The name of the group
    var groupName : String = "Error";
    
    /// The type of group this item is
    var groupType : KMMangaGroupType = KMMangaGroupType.Series;
    
    // Blank init
    override init() {
        super.init();
        
        self.groupImage = NSImage(named: "NSCaution")!;
    }
    
    // Init with an image
    init(groupImage : NSImage) {
        self.groupImage = groupImage;
    }
    
    // Init with an image and group name
    init(groupImage : NSImage, groupName : String) {
        self.groupImage = groupImage;
        self.groupName = groupName;
    }
    
    // Init with an image, group name and group type
    init(groupImage : NSImage, groupName : String, groupType : KMMangaGroupType) {
        self.groupImage = groupImage;
        self.groupName = groupName;
        self.groupType = groupType;
    }
}
