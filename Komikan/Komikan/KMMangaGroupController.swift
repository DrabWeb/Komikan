//
//  KMMangaGroupController.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//

import Cocoa

class KMMangaGroupController: NSObject {
    /// The KMMangaGroupItems that are kept in the background and pulled from for displaying
    var groupItems : [KMMangaGroupItem] = [];
    
    /// The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!
    
    /// A reference to the manga grid controller
    @IBOutlet weak var mangaGridController : KMMangaGridController!
    
    /// An array to store all of the groups we are displaying in the collection view
    var groups : NSMutableArray = NSMutableArray();
    
    /// Changes the group view to show the new group type
    func showGroupType(_ groupType : KMMangaGroupType) {
        // Clear the current items
        clearGrid(true);
        
        // If the group type is Series...
        if(groupType == .series) {
            // For every series in the user's collection...
            for (_, currentSeries) in mangaGridController.allSeries().enumerated() {
                /// The count of the current series in the user's collection(With parenthesis around it)
                let countOfSeries : String = "(" + String(mangaGridController.countOfSeries(currentSeries)) + ")";
                
                // Add the new series group with the series' name and the count of that series, with the series group type
                addGroupItem(KMMangaGroupItem(groupImage: mangaGridController.firstCoverImageForSeries(currentSeries), groupName: currentSeries, groupType: .series, countLabel: countOfSeries));
            }
        }
        // If the group type is Artist...
        if(groupType == .artist) {
            // For every artist in the user's collection...
            for (_, currentArtist) in mangaGridController.allArtists().enumerated() {
                /// The count of the current artist in the user's collection(With parenthesis around it)
                let countOfArtist : String = "(" + String(mangaGridController.countOfArtist(currentArtist)) + ")";
                
                // Add the new artist group with the artist's name and the count of that artist, with the artist group type
                addGroupItem(KMMangaGroupItem(groupImage: mangaGridController.firstCoverImageForArtist(currentArtist), groupName: currentArtist, groupType: .artist, countLabel: countOfArtist));
            }
        }
        // If the group type is Writer...
        if(groupType == .writer) {
            // For every author in the user's collection...
            for (_, currentWriter) in mangaGridController.allWriters().enumerated() {
                /// The count of the current author in the user's collection(With parenthesis around it)
                let countOfWriter : String = "(" + String(mangaGridController.countOfWriter(currentWriter)) + ")";
                
                // Add the new author group with the author's name and the count of that author, with the author group type
                addGroupItem(KMMangaGroupItem(groupImage: mangaGridController.firstCoverImageForWriter(currentWriter), groupName: currentWriter, groupType: .writer, countLabel: countOfWriter));
            }
        }
        // If the group type is Group...
        if(groupType == .group) {
            // For every group in the user's collection...
            for (_, currentGroup) in mangaGridController.allGroups().enumerated() {
                /// The count of the current group in the user's collection(With parenthesis around it)
                let countOfGroup : String = "(" + String(mangaGridController.countOfGroup(currentGroup)) + ")";
                
                // Add the new group group with the group's name and the count of that group, with the group group type
                addGroupItem(KMMangaGroupItem(groupImage: mangaGridController.firstCoverImageForGroup(currentGroup), groupName: currentGroup, groupType: .group, countLabel: countOfGroup));
            }
        }
        
        // Show groupItems in the grid
        setGridToGroupItems();
        
        // If the last search wasnt blank...
        if(lastSearch != "") {
            // Redo the last search
            searchFor(lastSearch);
        }
    }
    
    /// The last entered search
    var lastSearch : String = "";
    
    /// Searches for the given string and displays the results
    func searchFor(_ searchString : String) {
        // Print to the log what we are searching for
        print("KMMangaGroupController: Searching for \"\(searchString)\" in manga groups");
        
        // Set last search
        lastSearch = searchString;
        
        // If the search string is blank...
        if(searchString == "") {
            // Clear the grid
            clearGrid(false);
            
            // Set the grid to groupItems
            setGridToGroupItems();
        }
        // If the search string has content...
        else {
            /// The itmes we will display after that match the search
            var searchItems : [KMMangaGroupItem] = [];
            
            // For every item in the group items...
            for(_, currentGroupItem) in groupItems.enumerated() {
                // If the search string wasnt an exclusion search...
                if(searchString.substring(to: searchString.characters.index(after: searchString.startIndex)) != "-") {
                    // If the current item's group name contains the search string(In lowercase to be case insensitive)...
                    if(currentGroupItem.groupName.replacingOccurrences(of: currentGroupItem.countLabel, with: "").lowercased().contains(searchString.lowercased())) {
                        // Add the current item to the matching search items
                        searchItems.append(currentGroupItem);
                    }
                }
                // If the search string was an exclusion search...
                else {
                    // If the current item's group name doesnt the search string(In lowercase to be case insensitive)...
                    if(!currentGroupItem.groupName.replacingOccurrences(of: currentGroupItem.countLabel, with: "").lowercased().contains(searchString.substring(from: searchString.characters.index(after: searchString.startIndex)).lowercased())) {
                        // Add the current item to the matching search items
                        searchItems.append(currentGroupItem);
                    }
                }
            }
            
            // Clear the grid
            clearGrid(false);
            
            // Set the grid to searchItems
            // For every item in searchItems...
            for(_, currentSearchItem) in searchItems.enumerated() {
                // Add the current item to the grid
                addGroupItemToGrid(currentSearchItem);
            }
        }
    }
    
    /// Adds the given KMMangaGroupItem to the group items
    func addGroupItem(_ item : KMMangaGroupItem) {
        // Add the item to groupItems
        groupItems.append(item);
    }
    
    /// Adds the given KMMangaGroupItem to the grid
    func addGroupItemToGrid(_ item : KMMangaGroupItem) {
        // Add the item to arrayController
        arrayController.addObject(item);
    }
    
    /// Sets the grid to match groupItems
    func setGridToGroupItems() {
        // Clear the current items
        clearGrid(false);
        
        // I do a for loop because it makes a fancy animation
        // For every item in groupItems...
        for(_, currentItem) in groupItems.enumerated() {
            // Add the current object to the grid
            arrayController.addObject(currentItem);
        }
    }
    
    /// Clears arrayController, also clears groupItems if you set alsoGroupItems to true
    func clearGrid(_ alsoGroupItems : Bool) {
        // Remove all the objects from the grid array controller
        arrayController.remove(contentsOf: arrayController.arrangedObjects as! [AnyObject]);
        
        // if we also want to clear the group items...
        if(alsoGroupItems) {
            // Clear groupItems
            groupItems.removeAll();
        }
    }
}

/// The different type of groups manga group items can have
enum KMMangaGroupType {
    case series
    case artist
    case writer
    case group
}
