//
//  KMMangaGroupItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//

import Cocoa

class KMMangaGroupItem: NSObject {
    /// The image to display as a "cover" for this group
    var groupImage : NSImage = NSImage(named: "NSCaution")!;
    
    /// The name of the group
    var groupName : String = "Error";
    
    /// The type of group this item is
    var groupType : KMMangaGroupType = KMMangaGroupType.series;
    
    /// The label for how many items are in this group
    var countLabel : String = "(nil)";
    
    // Blank init
    override init() {
        super.init();
        
        self.groupImage = NSImage(named: "NSCaution")!;
        
        self.groupName = self.groupName + self.countLabel;
    }
    
    // Init with an image
    init(groupImage : NSImage) {
        self.groupImage = groupImage;
        
        self.groupName = self.groupName + self.countLabel;
    }
    
    // Init with an image and group name
    init(groupImage : NSImage, groupName : String) {
        self.groupImage = groupImage;
        self.groupName = groupName;
        
        self.groupName = self.groupName + self.countLabel;
    }
    
    // Init with an image, group name and group type
    init(groupImage : NSImage, groupName : String, groupType : KMMangaGroupType) {
        self.groupImage = groupImage;
        self.groupName = groupName;
        self.groupType = groupType;
        
        self.groupName = self.groupName + self.countLabel;
    }
    
    // Init with an image, group name, group type and count label
    init(groupImage : NSImage, groupName : String, groupType : KMMangaGroupType, countLabel : String) {
        self.groupImage = groupImage;
        self.groupName = groupName;
        self.groupType = groupType;
        self.countLabel = countLabel;
        
        self.groupName = self.groupName + self.countLabel;
    }
}
