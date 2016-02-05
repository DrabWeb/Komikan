//
//  KMMangaGridController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridController: NSObject {
    
    /// The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!;
    
    /// The items for the manga collection view. THIS IS NOT TO BE MODIFIED DIRECTLY
    var gridItems : [KMMangaGridItem] = [];
    
    /// The current way we are sorting the grid
    var currentSortOrder : KMMangaGridSortType = KMMangaGridSortType.Title;
    
    /// Are we currently ascending the grids sort?
    var currentSortAscending : Bool = false;
    
    /// An array to store all of the manga we are displaying in the collection view
    var manga : NSMutableArray = NSMutableArray();
    
    /// Are we showing l-lewd... manga?
    var showingLewdManga : Bool = false;
    
    override func awakeFromNib() {
        // Subscribe to the MangaGrid.Resort notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resort", name:"MangaGrid.Resort", object: nil);
        
<<<<<<< HEAD
<<<<<<< HEAD
        // Subscribe to the MangaGrid.DisplayGroups notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarTableViewDisplayGroups", name:"MangaGrid.DisplayGroups", object: nil);
        
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
        // Subscribe to the Application.PreferencesSaved notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayLewdMangaAppDelegate", name:"Application.PreferencesSaved", object: nil);
        
        // Subscribe to the Application.PreferencesSaved notification to reload all filters
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAllFilters", name:"Application.PreferencesSaved", object: nil);
        
        // Subscribe to the GridController.ReloadFilters notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAllFilters", name:"GridController.ReloadFilters", object: nil);
    }
    
<<<<<<< HEAD
    /// Reloads all the filters
    func reloadAllFilters() {
        // Reload the filters
        reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
    }
    
    /// Reloads all the filters like l-lewd... mode, groups, etc. Only reloads the ones whose bools you set to true
    func reloadFilters(reloadLewdFilter : Bool, reloadSearch : Bool, reloadGroups : Bool, reloadSort : Bool) {
        // If we said to reload the l-lewd... filter...
        if(reloadLewdFilter) {
            // Reload the l-lewd... filter
            displayLewdMangaAppDelegate();
        }
        
        // If we said to reload the search...
        if(reloadSearch) {
            // If we are searching...
            if(searching) {
                // Redo the last search
                searchFor(lastSearchText);
            }
        }
        
        // If we said to reload groups...
        if(reloadGroups) {
            // Reload the groups
            displayGroupsSidebarController();
        }
        
        // If we said to resort...
        if(reloadSort) {
            // Resort the grid
            resort();
        }
    }
    
<<<<<<< HEAD
    /// Shows / hides all the passed item datas(Groups) based on their groupShowing variable
    func displayGroups(groups : [KMSidebarItemData]) {
        // Print to the log that we are showing / hiding manga groups
        print("Showing / Hiding Manga groups");
        
        // Clear the array controller
        arrayController.removeObjects((arrayController.arrangedObjects as? [AnyObject])!);
        
        // For every item in the passed groups...
        for(_, currentGroup) in groups.enumerate() {
            for(_, currentGridItem) in gridItems.enumerate() {
                // If this grid items group is the same as the current group...
                if(currentGridItem.manga.group == currentGroup.groupName) {
                    // if we said to show this group...
                    if(currentGroup.groupShowing) {
                        // Add the current item to the array controller
                        arrayController.addObject(currentGridItem);
                    }
                }
                // If the manga doesnt have a group...
                else if(currentGridItem.manga.group == "") {
                    // Add the current item to the array controller
                    arrayController.addObject(currentGridItem);
                    
                    print("No group match");
                }
            }
        }
        
        // Resort
        resort();
    }
    
    /// The special function only meant for the sidebar table view to call
    func sidebarTableViewDisplayGroups() {
        reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
    }
    
    /// Shows / hides all the groups from the sidebar controller based on their groupShowing variable
    func displayGroupsSidebarController() {
        /// The array of all the KMSidebarItemData of the sidebar table view
        var sidebarDataItems : [KMSidebarItemData] = [];
        
        // For every KMSidebarItemDoc in the sidebar table view items...
        for(_, currentDoc) in (NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.sidebarTableViewItems.enumerate() {
            // Add the current docs data to sidebarDataItems
            sidebarDataItems.append(currentDoc.data);
        }
        
        // Call displayGroups with the new data we got
        displayGroups(sidebarDataItems);
    }
    
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
    /// Removes gridItem from the manga grid
    func removeGridItem(gridItem : KMMangaGridItem, resort : Bool) {
        // For every item in gridItems...
        for(currentIndex, currentItem) in gridItems.enumerate() {
            // If the current item is the same as the grid item we want to remove...
            if(currentItem == gridItem) {
                // Remove the object at the current index from gridItems
                gridItems.removeAtIndex(currentIndex);
                
                // Remove the current object from the array controller
                arrayController.removeObject(currentItem);
                
                // If the manga is from EH and we said in the preferences to delete them...
                if(currentItem.manga.directory.containsString("/Library/Application Support/Komikan/EH") && (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.deleteLLewdMangaWhenRemovingFromTheGrid) {
                    // Also delete the file
                    do {
                        // Try to delete the file at the mangas directory
                        try NSFileManager.defaultManager().removeItemAtPath(currentItem.manga.directory);
                        
                        // Print to the log that we deleted it
                        print("Deleted manga \"" + currentItem.manga.title + "\"'s file");
                    }
                        // If there is an error...
                    catch _ as NSError {
                        // Do nothing
                    }
                }
            }
        }
        
        // If we said to resort...
        if(resort) {
            // Resort the grid
            self.resort();
        }
    }
    
    /// Adds the passed KMMangaGridItem to the manga grid
    func addGridItem(gridItem : KMMangaGridItem) {
        // Append gridItem to gridItems
        gridItems.append(gridItem);
        
        // Add gridItem to the array controller
        arrayController.addObject(gridItem);
    }
    
    /// Clears the entire manga grid (If clearGridItems is true, it also clears gridItems)
    func removeAllGridItems(clearGridItems : Bool) {
        // Remove all objects from the array controller
        arrayController.removeObjects(arrayController.arrangedObjects as! [AnyObject]);
        
        // If we said to clear gridItems...
        if(clearGridItems) {
            // Clear gridItems
            gridItems.removeAll();
        }
    }
    
    /// Updates the manga grid to match the items in gridItems
    func updateGridToMatchGridItems() {
        // Remove all the grid items from the array controller
        removeAllGridItems(false);
        
        // Add all the items in gridItems
        setGridToItems(gridItems, shouldReloadFilters: true);
        
        // Resort the grid
        resort();
    }
    
    /// Shows all the items in objects to the manga grid. Reloads the filters if shouldReloadFilters is true
    func setGridToItems(objects : [KMMangaGridItem], shouldReloadFilters : Bool) {
        // Clear the grid
        removeAllGridItems(false);
        
        // Add objects to the manga grid
        arrayController.addObjects(objects);
        
        // If we said to reload the filters...
        if(shouldReloadFilters) {
            // Reload the filters
            reloadFilters(true, reloadSearch: true, reloadGroups: true, reloadSort: true);
        }
    }
    
    /// Adds the given manga to the manga grid, and redos the search / show/hide l-lewd... manga
    func addManga(manga : KMManga, updateFilters : Bool) {
        // Print to the log that we are adding a manga to the grid and what its name is
        print("Adding manga \"" + manga.title + "\" to the manga grid");
        
        // Create a new item
        let newItem : KMMangaGridItem = KMMangaGridItem();
        
        // Set the cover image to the mangas cover image
        newItem.coverImage = manga.coverImage;
        
        // Set the title to the mangas title
        newItem.title = manga.title;
        
        // Set the manga to the manga
        newItem.manga = manga;
        
        // Add the object
        addGridItem(newItem);
        
        // If we said to update the grid filters on add...
        if(updateFilters) {
            // Reload the l-lewd... manga filter
            displayLewdMangaAppDelegate();
            
            // If we are searching
            if(searching) {
                // Redo the search so if the item doesnt match the query it gets hidden
                searchFor(lastSearchText);
            }
        }
    }
    
    // A bool to say if we are currently searching
    var searching : Bool = false;
    
    var lastSearchText : String = "";
    
    // Stores all the items that match the search
    var searchItems : [KMMangaGridItem] = [];
    
    /// Searches the manga grid for the passed string, and updates it accordingly
    func searchFor(searchText : String) {
        // RIP old search, you werent good enough. 2016-2016
        // Reset searchItems
        searchItems.removeAll();
        
        // Set lastSearchText to the search text
        lastSearchText = searchText;
        
        // If we arent searching for anything..
        if(searchText == "") {
            // If we have searched before...
            if(searching) {
<<<<<<< HEAD
                // Reload all the filters except search
                reloadFilters(false, reloadSearch: false, reloadGroups: true, reloadSort: true);
                
                // Remove all the objects in searchingGridItems
                searchingGridItems.removeAll();
=======
                // Restore the grid back to gridItems
                updateGridToMatchGridItems();
                
                // Say we arent searching
                searching = false;
<<<<<<< HEAD
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
=======
>>>>>>> parent of 16a2ccc... Grouping is now functional. Removes the group from a manga if the group gets deleted, always shows manga that have no group, and shows / hides manga basbased on l-lewd... mode enabled even when in a group. There could still be bugs though, so keep a look out
            }
        }
        else {
            // Say we are searching
            searching = true;
            
            // Print to the log what we are searching for
            print("Searching for \"" + searchText + "\"");
            
            // Remove all items from the array controller
            removeAllGridItems(false);
            
            /// The title search content(If we search for a title)
            var titleSearch : String = "";
            
            /// The series search content(If we search for a series)
            var seriesSearch : String = "";
            
            /// The artist search content(If we search for a artist)
            var artistSearch : String = "";
            
            /// The writer search content(If we search for a writer)
            var writerSearch : String = "";
            
            /// The tags search content(If we search for a tags)(Already split into an array)
            var tagsSearch : [String] = [];
            
            /// The search string without the possible ; on the end
            var cleanedSearchText : String = searchText;
            
            // If the last character in the search string is a ;...
            if(cleanedSearchText.characters.last! == ";") {
                // Remove the last character of the string(Why does Swift make you do this like this?)
                cleanedSearchText = cleanedSearchText.substringToIndex(cleanedSearchText.endIndex.predecessor());
            }
            
            /// Tjhe search string split at every "; "
            let searchStringSplit : [String] = cleanedSearchText.componentsSeparatedByString("; ");
            
            // Print the split search string
            print("Search string split at every \"; \": " + String(searchStringSplit));
            
            // For every item in the split search string
            for(_, currentString) in searchStringSplit.enumerate() {
                // Switch for the first part of the current search item(The type(title, writer, tags, ETC.))
                switch currentString.componentsSeparatedByString(":").first! {
                    // If its title...
                    case "title":
                        // Set the appropriate variable to the current strings search content
                        titleSearch = currentString.componentsSeparatedByString(":").last!;
                        break;
                    // If its series...
                    case "series":
                        // Set the appropriate variable to the current strings search content
                        seriesSearch = currentString.componentsSeparatedByString(":").last!;
                        break;
                    // If its artist...
                    case "artist":
                        // Set the appropriate variable to the current strings search content
                        artistSearch = currentString.componentsSeparatedByString(":").last!;
                        break;
                    // If its writer...
                    case "writer":
                        // Set the appropriate variable to the current strings search content
                        writerSearch = currentString.componentsSeparatedByString(":").last!;
                        break;
                    // If its tags...
                    case "tags":
                        // Set the appropriate variable to the current strings search content
                        tagsSearch = currentString.componentsSeparatedByString(":").last!.componentsSeparatedByString(", ");
                        break;
                    // If it is one that we dont have...
                    default:
                        // Print to the log that it didnt match any types we search by
                        print("Did not match any search types");
                        break;
                }
            }
            
            /// Did we search by a title?
            let searchedByTitle : Bool = (titleSearch != "");
            
            /// Did we search by a series?
            let searchedBySeries : Bool = (seriesSearch != "");
            
            /// Did we search by an artist?
            let searchedByArtist : Bool = (artistSearch != "");
            
            /// Did we search by a writer?
            let searchedByWriter : Bool = (writerSearch != "");
            
            /// Did we search by tags?
            let searchedByTags : Bool = (tagsSearch != []);
            
            // For every manga we have...
            for(_, currentItem) in gridItems.enumerate() {
                /// Does this manga overall match the search?
                var matching : Bool = false;
                
                /// Do we have a matching title?
                var matchingTitle : Bool = false;
                
                /// Do we have a matching writer?
                var matchingSeries : Bool = false;
                
                // Do we have a matching artist?
                var matchingArtist : Bool = false;
                
                /// Do we have a matching writer?
                var matchingWriter : Bool = false;
                
                /// Do we have matching tags?
                var matchingTags : Bool = false;
                
                // If we searched by title...
                if(searchedByTitle) {
                    // If the current items title contain the title search... (In lowercase to be case insensitive)
                    if(currentItem.manga.title.lowercaseString.containsString(titleSearch.lowercaseString)) {
                        // Say there is a matching title
                        matchingTitle = true;
                    }
                }
                
                // If we searched by series...
                if(searchedBySeries) {
                    // If the current items series contain the series search... (In lowercase to be case insensitive)
                    if(currentItem.manga.series.lowercaseString.containsString(seriesSearch.lowercaseString)) {
                        // Say there is a matching series
                        matchingSeries = true;
                    }
                }
                
                // If we searched by artist...
                if(searchedByArtist) {
                    // If the current items artist contain the artist search... (In lowercase to be case insensitive)
                    if(currentItem.manga.artist.lowercaseString.containsString(artistSearch.lowercaseString)) {
                        // Say there is a matching artist
                        matchingArtist = true;
                    }
                }
                
                // If we searched by writer...
                if(searchedByWriter) {
                    // If the current items writer contain the writer search... (In lowercase to be case insensitive)
                    if(currentItem.manga.artist.lowercaseString.containsString(writerSearch.lowercaseString)) {
                        // Say there is a matching writer
                        matchingWriter = true;
                    }
                }
                
                // If we searched by tags...
                if(searchedByTags) {
                    /// How many matching tags do we have?
                    var matchingTagCount : Int = 0;
                    
                    // For every tag in the current items tags...
                    for(_, currentTag) in currentItem.manga.tags.enumerate() {
                        // For every tag in the search tags....
                        for(_, currentSearchTag) in tagsSearch.enumerate() {
                            // If the current tag matches the current search tag... (In lowercase to be case insensitive)
                            if(currentTag.lowercaseString.containsString(currentSearchTag.lowercaseString)) {
                                // Say we have matching tags
                                matchingTags = true;
                                
                                // Add one to the matching tag count
                                matchingTagCount++;
                            }
                        }
                    }
                    
                    // If the amount of matching tags is less than the search tags count...
                    if(matchingTagCount < tagsSearch.count) {
                        // Say the tags dont match
                        matchingTags = false;
                    }
                }
                
                // Example search
                // title:v007; series:Yuru Yuri; artist:namori; writer:namori; tags:school, comedy;
                
                // If we didnt search by title...
                if(!searchedByTitle) {
                    // Say the title matched
                    matchingTitle = true;
                }
                // If we didnt search by series...
                if(!searchedBySeries) {
                    // Say the series matched
                    matchingSeries = true;
                }
                // If we didnt search by artist...
                if(!searchedByArtist) {
                    // Say the artist matched
                    matchingArtist = true;
                }
                // If we didnt search by writer...
                if(!searchedByWriter) {
                    // Say we searched by writer
                    matchingWriter = true;
                }
                // If we didnt search by tags...
                if(!searchedByTags) {
                    // Say the tags matched
                    matchingTags = true;
                }
                
                // If everything matched...
                if(matchingTitle && matchingSeries && matchingArtist && matchingWriter && matchingTags) {
                    // Say the manga passed, and matches everything
                    matching = true;
                }
                
                // If the manga matched...
                if(matching) {
                    // Add this manga to the search items
                    searchItems.append(currentItem);
                }
            }
            
            // Set the grid to show all the items that match the search
            setGridToItems(searchItems, shouldReloadFilters: false);
            
            // Resort the grid
            resort();
        }
    }
    
    // All the non l-lewd... manga
    var nonLewdManga : [KMMangaGridItem] = [];
    
    /// Shows/hides all the l-lewd... manga based on show
    func displayLewdManga(show : Bool) {
        // Make sure nonLewdManga is empty
        nonLewdManga.removeAll();
        
        // Set showingLewdManga to show
        showingLewdManga = show;
        
        // If we said to show l-lewd... manga...
        if(show) {
            // Print to the log that we are showing l-lewd... manga
            print("Showing l-lewd... manga");
            
            // Set the manga grid to show gridItems
            setGridToItems(nonLewdManga, shouldReloadFilters: false);
            
            // Reload the filters
            reloadFilters(false, reloadSearch: true, reloadGroups: false, reloadSort: true);
        }
        // If we said to show l-lewd... manga(B-but thats l-lewd...!)
        else {
            // Print to the log that we are hiding l-lewd... manga
            print("Hiding l-lewd... manga");
            
            // For every item in gridItems...
            for(_, currentItem) in gridItems.enumerate() {
                // If the current item's manga isnt l-lewd...
                if(!currentItem.manga.lewd) {
                    // Add the current manga to the grid
                    nonLewdManga.append(currentItem);
                }
            }
            
            // Show all items in nonLewdManga in the manga grid
            setGridToItems(nonLewdManga, shouldReloadFilters: false);
            
            // Reload the filters
            reloadFilters(false, reloadSearch: true, reloadGroups: false, reloadSort: true);
        }
    }
    
    /// Shows/hides all the l-lewd... manga based on the preferences keeper in AppDelegate
    func displayLewdMangaAppDelegate() {
        displayLewdManga((NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.llewdModeEnabled);
    }
    
    /// Resort the manga grid(Based on the last chosen sorting method)
    func resort() {
        // Call the rearrange function on the array
        arrayController.rearrangeObjects();
    }
    
    /// Sorts the manga grid by sortType and ascends/decends based on ascending
    func sort(sortType : KMMangaGridSortType, ascending : Bool) {
        // Print to the log how we are sorting
        print("Sorting manga grid by " + String(sortType));
        
        // Set the current sort type to be the type we are sorting as
        currentSortOrder = sortType;
        
        // Set the current sort ascending to be what we are passing
        currentSortAscending = ascending;
        
        // If the sort type is by series...
        if(sortType == KMMangaGridSortType.Series) {
            // Sort by series
            arrayController.sortDescriptors = [NSSortDescriptor(key: "series", ascending: ascending)];
        }
        // If the sort type is by artist...
        else if(sortType == KMMangaGridSortType.Artist) {
            // Sort by artist
            arrayController.sortDescriptors = [NSSortDescriptor(key: "artist", ascending: ascending)];
        }
        // If the sort type is by title...
        else if(sortType == KMMangaGridSortType.Title) {
            // Sort by title
            arrayController.sortDescriptors = [NSSortDescriptor(key: "title", ascending: ascending)];
        }
    }
}