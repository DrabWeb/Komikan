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
            // For every series in the user's collection...
            for (_, currentSeries) in mangaGridController.allSeries().enumerate() {
                /// The count of the current series in the user's collection(With parenthesis around it)
                let countOfSeries : String = "(" + String(mangaGridController.countOfSeries(currentSeries)) + ")";
                
                // Add the new series group with the series' name and the count of that series, with the series group type
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentSeries, groupType: .Series, countLabel: countOfSeries));
            }
        }
        // If the group type is Artist...
        if(groupType == .Artist) {
            // For every artist in the user's collection...
            for (_, currentArtist) in mangaGridController.allArtists().enumerate() {
                /// The count of the current artist in the user's collection(With parenthesis around it)
                let countOfArtist : String = "(" + String(mangaGridController.countOfArtist(currentArtist)) + ")";
                
                // Add the new artist group with the artist's name and the count of that artist, with the artist group type
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentArtist, groupType: .Artist, countLabel: countOfArtist));
            }
        }
        // If the group type is Writer...
        if(groupType == .Writer) {
            // For every author in the user's collection...
            for (_, currentWriter) in mangaGridController.allWriters().enumerate() {
                /// The count of the current author in the user's collection(With parenthesis around it)
                let countOfWriter : String = "(" + String(mangaGridController.countOfWriter(currentWriter)) + ")";
                
                // Add the new author group with the author's name and the count of that author, with the author group type
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentWriter, groupType: .Writer, countLabel: countOfWriter));
            }
        }
        // If the group type is Group...
        if(groupType == .Group) {
            // For every group in the user's collection...
            for (_, currentGroup) in mangaGridController.allGroups().enumerate() {
                /// The count of the current group in the user's collection(With parenthesis around it)
                let countOfGroup : String = "(" + String(mangaGridController.countOfGroup(currentGroup)) + ")";
                
                // Add the new group group with the group's name and the count of that group, with the group group type
                arrayController.addObject(KMMangaGroupItem(groupImage: NSImage(named: "DrabWeb")!, groupName: currentGroup, groupType: .Group, countLabel: countOfGroup));
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