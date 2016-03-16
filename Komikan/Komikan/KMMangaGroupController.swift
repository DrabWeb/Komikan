//
//  KMMangaGroupController.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGroupController: NSObject {
    /// The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!
    
    /// A reference to the manga grid controller
    @IBOutlet weak var mangaGridController : KMMangaGridController!
    
    /// An array to store all of the groups we are displaying in the collection view
    var groups : NSMutableArray = NSMutableArray();
    
    /// Changes the group view to show the new group type
    func showGroupType(groupType : KMMangaGroupType) {
        // Clear all the current items
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // If the group type is Series...
        if(groupType == .Series) {
            for (_, currentSeries) in mangaGridController.allSeries().enumerate() {
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentSeries));
            }
        }
        // If the group type is Artist...
        if(groupType == .Artist) {
            for (_, currentArtist) in mangaGridController.allArtists().enumerate() {
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentArtist));
            }
        }
        // If the group type is Writer...
        if(groupType == .Writer) {
            for (_, currentWriter) in mangaGridController.allWriters().enumerate() {
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentWriter));
            }
        }
        // If the group type is Group...
        if(groupType == .Group) {
            for (_, currentGroup) in mangaGridController.allGroups().enumerate() {
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentGroup));
            }
        }
    }
}

/// The different type of groups manga group items can have
enum KMMangaGroupType {
    case Series
    case Artist
    case Writer
    case Group
}