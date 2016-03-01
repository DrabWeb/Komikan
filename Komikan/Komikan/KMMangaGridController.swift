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
    @IBOutlet weak var arrayController : NSArrayController!
    
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
        
        // Subscribe to the Application.PreferencesSaved notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayLewdMangaAppDelegate", name:"Application.PreferencesSaved", object: nil);
    }
    
    /// Exports the JSON information for every manga in the grid(Also exports thre internal info if exportInternalInfo is true)
    func exportAllMangaJSON(exportInternalInfo : Bool) {
        // For every single grid item...
        for(_, currentGridItem) in gridItems.enumerate() {
            // Export this items manga's info
            KMFileUtilities().exportMangaJSON(currentGridItem.manga, exportInternalInfo: exportInternalInfo);
        }
        
        // Create the new notification to tell the user the Metadata exporting has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finshed exporting Metadata";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        finishedNotification.identifier = NSUUID().UUIDString;
        
        // Deliver the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
    }
    
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
        setGridToItems(gridItems);
        
        // Resort the grid
        resort();
    }
    
    /// Shows all the items in objects to the manga grid
    func setGridToItems(objects : [KMMangaGridItem]) {
        // Clear the grid
        removeAllGridItems(false);
        
        // Add objects to the manga grid
        arrayController.addObjects(objects);
        
        // Resort the grid
        resort();
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
    
    /// Retuns all the series the user has in their collection
    func allSeries() -> [String] {
        /// The array of strings that we will return at the end of the function to say what all the series are
        var series : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we havent already added this series and this series isnt blank...
            if(!series.contains(currentGridItem.manga.series) && currentGridItem.manga.series != "") {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this items series to the list of series
                    series.append(currentGridItem.manga.series);
                }
            }
        }
        
        // Return the series
        return series;
    }
    
    /// Returns the amount of manga that are in the guven series
    func countOfSeries(series : String) -> Int {
        /// All the series
        var allSeries : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we arent in l-lewd... mode and this manga is lewd...
            if(!showingLewdManga && currentGridItem.manga.lewd) {
                // Do nothing
            }
            else {
                // Add the current series
                allSeries.append(currentGridItem.manga.series);
            }
        }
        
        // Return the count of the passed series in all the series
        return allSeries.occurenceCountOf(series);
    }
    
    /// Retuns all the artists the user has in their collection
    func allArtists() -> [String] {
        /// The array of strings that we will return at the end of the function to say what all the artists are
        var artists : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we havent already added this artist and this artist isnt blank...
            if(!artists.contains(currentGridItem.manga.artist) && currentGridItem.manga.artist != "") {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this items artist to the list of artists
                    artists.append(currentGridItem.manga.artist);
                }
            }
        }
        
        // Return the artists
        return artists;
    }
    
    /// Returns the amount of manga that are drawn by the given artist
    func countOfArtist(writer : String) -> Int {
        /// All the artists
        var artists : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we arent in l-lewd... mode and this manga is lewd...
            if(!showingLewdManga && currentGridItem.manga.lewd) {
                // Do nothing
            }
            else {
                // Add the current artist
                artists.append(currentGridItem.manga.artist);
            }
        }
        
        // Return the count of the passed artist in all the artists
        return artists.occurenceCountOf(writer);
    }
    
    /// Retuns all the writers the user has in their collection
    func allWriters() -> [String] {
        /// The array of strings that we will return at the end of the function to say what all the writers are
        var writers : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we havent already added this writer and this writer isnt blank...
            if(!writers.contains(currentGridItem.manga.writer) && currentGridItem.manga.writer != "") {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this items writer to the list of writers
                    writers.append(currentGridItem.manga.writer);
                }
            }
        }
        
        // Return the writers
        return writers;
    }
    
    /// Returns the amount of manga that are written by the given writer
    func countOfWriter(writer : String) -> Int {
        /// All the writers
        var writers : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we arent in l-lewd... mode and this manga is lewd...
            if(!showingLewdManga && currentGridItem.manga.lewd) {
                // Do nothing
            }
            else {
                // Add the current writer
                writers.append(currentGridItem.manga.writer);
            }
        }
        
        // Return the count of the passed writer in all the writers
        return writers.occurenceCountOf(writer);
    }
    
    /// Retuns all the tags the user has in their collection
    func allTags() -> [String] {
        /// The array of strings that we will return at the end of the function to say what all the tags are
        var tags : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // For every tag in this item's tags...
            for(_, currentTag) in currentGridItem.manga.tags.enumerate() {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // If we havent already added this tag and this tag isnt blank...
                    if(!tags.contains(currentTag) && currentTag != "") {
                        // Add this tag to the list of tags
                        tags.append(currentTag);
                    }
                }
            }
        }
        
        // Return the tags
        return tags;
    }
    
    /// Returns the amount of manga that have the given tag
    func countOfTag(tag : String) -> Int {
        /// All the tags
        var tags : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we arent in l-lewd... mode and this manga is lewd...
            if(!showingLewdManga && currentGridItem.manga.lewd) {
                // Do nothing
            }
            else {
                // For every tag in this item's tags...
                for(_, currentTag) in currentGridItem.manga.tags.enumerate() {
                    // Add the current tag
                    tags.append(currentTag);
                }
            }
        }
        
        // Return the count of the passed tag in all the tags
        return tags.occurenceCountOf(tag);
    }
    
    /// Retuns all the groups the user has for their collection
    func allGroups() -> [String] {
        /// The array of strings that we will return at the end of the function to say what all the groups are
        var groups : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we havent already added this group and this group isnt blank...
            if(!groups.contains(currentGridItem.manga.group) && currentGridItem.manga.group != "") {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this items group to the list of groups
                    groups.append(currentGridItem.manga.group);
                }
            }
        }
        
        // Return the groups
        return groups;
    }
    
    /// Returns the amount of manga that are in the given group
    func countOfGroup(group : String) -> Int {
        /// All the groups
        var groups : [String] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If we arent in l-lewd... mode and this manga is lewd...
            if(!showingLewdManga && currentGridItem.manga.lewd) {
                // Do nothing
            }
            else {
                // Add the current group
                groups.append(currentGridItem.manga.group);
            }
        }
        
        // Return the count of the passed group in all the groups
        return groups.occurenceCountOf(group);
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
                // Restore the grid back to gridItems
                updateGridToMatchGridItems();
                
                // Say we arent searching
                searching = false;
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
            var seriesSearch : [String] = [];
            
            /// The artist search content(If we search for a artist)
            var artistSearch : [String] = [];
            
            /// The writer search content(If we search for a writer)
            var writerSearch : [String] = [];
            
            /// The tags search content(If we search for a tags)(Already split into an array)
            var tagsSearch : [String] = [];
            
            /// The tags search content(If we search for a groups)(Already split into an array)
            var groupsSearch : [String] = [];
            
            /// The favourites search content(If we search for favourites)
            var favouritesSearch : String = "";
            
            /// The read search content(If we search for read manga)
            var readSearch : String = "";
            
            /// The percent finished search content(If we search for percent finished)
            var percentSearch : String = "";
            
            /// The search string without the possible " on the end
            var cleanedSearchText : String = searchText;
            
            // If the last character in the search string is a "...
            if(cleanedSearchText.characters.last! == "\"") {
                // Remove the last character of the string(Why does Swift make you do this like this?)
                cleanedSearchText = cleanedSearchText.substringToIndex(cleanedSearchText.endIndex.predecessor());
            }
            
            /// Tjhe search string split at every "; "
            let searchStringSplit : [String] = cleanedSearchText.componentsSeparatedByString("\" ");
            
            // Print the split search string
            print("Search string split at every \"\" \": " + String(searchStringSplit));
            
            // For every item in the split search string
            for(_, currentString) in searchStringSplit.enumerate() {
                // Switch for the first part of the current search item(The type(title, writer, tags, ETC.))
                switch currentString.componentsSeparatedByString(":\"").first! {
                    // If its title...
                    case "title", "t":
                        // Set the appropriate variable to the current strings search content
                        titleSearch = currentString.componentsSeparatedByString(":\"").last!;
                        break;
                    // If its series...
                    case "series", "s":
                        // Set the appropriate variable to the current strings search content
                        seriesSearch = currentString.lowercaseString.componentsSeparatedByString(":\"").last!.componentsSeparatedByString(", ");
                        break;
                    // If its artist...
                    case "artist", "a":
                        // Set the appropriate variable to the current strings search content
                        artistSearch = currentString.lowercaseString.componentsSeparatedByString(":\"").last!.componentsSeparatedByString(", ");
                        break;
                    // If its writer...
                    case "writer", "w":
                        // Set the appropriate variable to the current strings search content
                        writerSearch = currentString.lowercaseString.componentsSeparatedByString(":\"").last!.componentsSeparatedByString(", ");
                        break;
                    // If its tags...
                    case "tags", "tg":
                        // Set the appropriate variable to the current strings search content
                        tagsSearch = currentString.componentsSeparatedByString(":\"").last!.componentsSeparatedByString(", ");
                        break;
                    // If its groups...
                    case "groups", "g":
                        // Set the appropriate variable to the current strings search content
                        groupsSearch = currentString.componentsSeparatedByString(":\"").last!.componentsSeparatedByString(", ");
                        break;
                    // If its favourites...
                    case "favourites", "f":
                        // Set the appropriate variable to the current strings search content
                        favouritesSearch = currentString.componentsSeparatedByString(":\"").last!;
                        break;
                    // If its read...
                    case "read", "r":
                        // Set the appropriate variable to the current strings search content
                        readSearch = currentString.componentsSeparatedByString(":\"").last!;
                        break;
                    // If its percent...
                    case "percent", "p":
                        // Set the appropriate variable to the current strings search content
                        percentSearch = currentString.componentsSeparatedByString(":\"").last!;
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
            let searchedBySeries : Bool = (seriesSearch != []);
            
            /// Did we search by an artist?
            let searchedByArtist : Bool = (artistSearch != []);
            
            /// Did we search by a writer?
            let searchedByWriter : Bool = (writerSearch != []);
            
            /// Did we search by tags?
            let searchedByTags : Bool = (tagsSearch != []);
            
            /// Did we search by groups?
            let searchedByGroups : Bool = (groupsSearch != []);
            
            /// Did we search by favourites?
            let searchedByFavourites : Bool = (favouritesSearch != "");
            
            /// Did we search by read?
            let searchedByRead : Bool = (readSearch != "");
            
            /// Did we search by percent finished?
            let searchedByPercent : Bool = (percentSearch != "");
            
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
                
                /// Do we have matching groups?
                var matchingGroups : Bool = false;
                
                /// Do we have matching favourites?
                var matchingFavourites : Bool = false;
                
                /// Do we have matching read manga?
                var matchingRead : Bool = false;
                
                /// Do we have matching percent finished?
                var matchingPercent : Bool = false;
                
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
                    if(seriesSearch.contains(currentItem.manga.series.lowercaseString)) {
                        // Say there is a matching series
                        matchingSeries = true;
                    }
                }
                
                // If we searched by artist...
                if(searchedByArtist) {
                    // If the current items artist contain the artist search... (In lowercase to be case insensitive)
                    if(artistSearch.contains(currentItem.manga.artist.lowercaseString)) {
                        // Say there is a matching artist
                        matchingArtist = true;
                    }
                }
                
                // If we searched by writer...
                if(searchedByWriter) {
                    // If the current items writer contain the writer search... (In lowercase to be case insensitive)
                    if(writerSearch.contains(currentItem.manga.writer.lowercaseString)) {
                        // Say there is a matching writer
                        matchingWriter = true;
                    }
                }
                
                // If we searched by favourites...
                if(searchedByFavourites) {
                    // If the current items favourite value is the same as the favourites value we searched for...
                    if(currentItem.manga.favourite == favouritesSearch.toBool()) {
                        // Say there is a matching favourite
                        matchingFavourites = true;
                    }
                }
                
                // If we searched by read manga...
                if(searchedByRead) {
                    // If the current items read value is the same as the favourites value we searched for...
                    if(currentItem.manga.read == readSearch.toBool()) {
                        // Say there is a matching read manga
                        matchingRead = true;
                    }
                }
                
                // If we searched by percent finished...
                if(searchedByPercent) {
                    // If the first character in the percent search is a >...
                    if(percentSearch.substringToIndex(percentSearch.startIndex.successor()) == ">") {
                        // If the current manga's percent finished is greater then the searched number...
                        if(currentItem.manga.percentFinished > NSString(string: percentSearch.substringFromIndex(percentSearch.startIndex.successor())).integerValue) {
                            // Say the percent matched
                            matchingPercent = true;
                        }
                    }
                    // If the first character in the percent search is a <...
                    else if(percentSearch.substringToIndex(percentSearch.startIndex.successor()) == "<") {
                        // If the current manga's percent finished is less then the searched number...
                        if(currentItem.manga.percentFinished < NSString(string: percentSearch.substringFromIndex(percentSearch.startIndex.successor())).integerValue) {
                            // Say the percent matched
                            matchingPercent = true;
                        }
                    }
                    // If we just searched by a number...
                    else {
                        // If the current manga's percent finished is equal to the searched number...
                        if(currentItem.manga.percentFinished == NSString(string: percentSearch).integerValue) {
                            // Say the percent matched
                            matchingPercent = true;
                        }
                    }
                }
                
                // If we searched by tags...
                if(searchedByTags) {
                    /// How many matching tags do we have?
                    var matchingTagCount : Int = 0;
                    
                    // Have we already matched exclusion tags?
                    var alreadyMatchedExclusionTag : Bool = false;
                    
                    /// How many exclusion tags do we have in our search?
                    var exclusionTagCount : Int = 0;
                    
                    // For every search tag...
                    for(_, currentSearchTag) in tagsSearch.enumerate() {
                        // If the first character in the string is a "-"...
                        if(currentSearchTag.substringToIndex(currentSearchTag.startIndex.successor()) == "-") {
                            // Add one to the exclusion tag count
                            exclusionTagCount++;
                        }
                    }
                    
                    // Resort the search tags(For some reason my exclusion method doesnt work very well when you put exclusion tags first, so this is the solution)
                    tagsSearch = tagsSearch.sort();
                    
                    // Flip the search tags(For the same reason as above)
                    tagsSearch = tagsSearch.reverse();
                    
                    /// Are we only searching by exclusion tags?
                    let onlySearchingForExclusionTags : Bool = ((tagsSearch.count - exclusionTagCount) == 0);
                    
                    // For every tag in the current items tags...
                    for(_, currentTag) in currentItem.manga.tags.enumerate() {
                        // For every tag in the search tags....
                        for(_, currentSearchTag) in tagsSearch.enumerate() {
                            /// The current search tag without the possible "-" in front for exclusion tags
                            var searchTagWithoutPossibleMinus : String = currentSearchTag.lowercaseString;
                            
                            /// Is the current search tag an exclusion tag?
                            var searchTagIsExclusion : Bool = false;
                            
                            // If the first character in searchTagWithoutPossibleMinus is a "-"...
                            if(searchTagWithoutPossibleMinus.substringToIndex(currentSearchTag.startIndex.successor()) == "-") {
                                // Remove the first character from searchTagWithoutPossibleMinus
                                searchTagWithoutPossibleMinus = searchTagWithoutPossibleMinus.substringFromIndex(searchTagWithoutPossibleMinus.startIndex.successor());
                                
                                // Set searchTagIsExclusion to true
                                searchTagIsExclusion = true;
                            }
                            
                            // If we arent only searching by exclusion tags...
                            if(!onlySearchingForExclusionTags) {
                                // If the current tag matches the current search tag... (In lowercase to be case insensitive)
                                if(currentTag.lowercaseString.containsString(searchTagWithoutPossibleMinus)) {
                                    // If the current search tag is an exclusion search tag...
                                    if(searchTagIsExclusion) {
                                        // Say we dont matching tags
                                        matchingTags = false;
                                        
                                        // Set the matching tag count to the search tags count
                                        matchingTagCount = tagsSearch.count;
                                        
                                        // Say we already have matched an exclusion tag
                                        alreadyMatchedExclusionTag = true;
                                    }
                                    else {
                                        // If we dont already have a matching exclusion tag...
                                        if(!alreadyMatchedExclusionTag) {
                                            // Say we have matching tags
                                            matchingTags = true;
                                            
                                            // Add one to the matching tag count
                                            matchingTagCount++;
                                        }
                                    }
                                }
                            }
                            
                            // If we only searched for exclusion tags and we havent already had a matching exclusion tag...
                            if(onlySearchingForExclusionTags && !alreadyMatchedExclusionTag) {
                                // If the current tag doesnt match the exclusion tag...
                                if(currentTag != searchTagWithoutPossibleMinus) {
                                    // Say we have matching tags
                                    matchingTags = true;
                                    
                                    // Add one to the matching tag count
                                    matchingTagCount++;
                                }
                                else {
                                    // Say we dont have matching tags
                                    matchingTags = false;
                                    
                                    // Say we already matched an exclusion tag
                                    alreadyMatchedExclusionTag = true;
                                }
                            }
                        }
                    }
                    
                    // If the amount of matching tags is less than the search tags count, and we arent only searching for exclusion tags...
                    if((matchingTagCount < tagsSearch.count - (exclusionTagCount)) && !onlySearchingForExclusionTags) {
                        // Say the tags dont match
                        matchingTags = false;
                    }
                }
                
                // If we searched by groups...
                if(searchedByGroups) {
                    // Have we already matched exclusion groups?
                    var alreadyMatchedExclusionGroup : Bool = false;
                    
                    /// How many exclusion groups do we have in our search?
                    var exclusionGroupCount : Int = 0;
                    
                    // For every search group...
                    for(_, currentSearchGroup) in groupsSearch.enumerate() {
                        // If the first character in the current search group is a "-"...
                        if(currentSearchGroup.substringToIndex(currentSearchGroup.startIndex.successor()) == "-") {
                            // Add one to the exclusion group count
                            exclusionGroupCount++;
                        }
                    }
                    
                    // Resort the search groups(For some reason my exclusion method doesnt work very well when you put exclusion tags first, so this is the solution)
                    groupsSearch = groupsSearch.sort();
                    
                    // Flip the search groups(For the same reason as above)
                    groupsSearch = groupsSearch.reverse();
                    
                    /// Are we only searching by exclusion groups?
                    let onlySearchingForExclusionGroups : Bool = ((groupsSearch.count - exclusionGroupCount) == 0);
                    
                    // For every group in the search groups....
                    for(_, currentSearchGroup) in groupsSearch.enumerate() {
                        /// The current search group without the possible "-" in front for exclusion tags
                        var searchGroupWithoutPossibleMinus : String = currentSearchGroup.lowercaseString;
                        
                        /// Is the current search group an exclusion group?
                        var searchGroupIsExclusion : Bool = false;
                        
                        // If the first character in searchGroupWithoutPossibleMinus is a "-"...
                        if(searchGroupWithoutPossibleMinus.substringToIndex(currentSearchGroup.startIndex.successor()) == "-") {
                            // Remove the first character from searchGroupWithoutPossibleMinus
                            searchGroupWithoutPossibleMinus = searchGroupWithoutPossibleMinus.substringFromIndex(searchGroupWithoutPossibleMinus.startIndex.successor());
                            
                            // Set searchGroupIsExclusion to true
                            searchGroupIsExclusion = true;
                        }
                        
                        // If we only searched for exclusion tags and we havent already had a matching exclusion group...
                        if(onlySearchingForExclusionGroups && !alreadyMatchedExclusionGroup) {
                            // If the current group doesnt match the exclusion group...
                            if(currentItem.manga.group.lowercaseString != searchGroupWithoutPossibleMinus) {
                                // Say we have matching groups
                                matchingGroups = true;
                            }
                            else {
                                // Say we dont have matching groups
                                matchingGroups = false;
                                
                                // Say we already matched an exclusion group
                                alreadyMatchedExclusionGroup = true;
                            }
                        }
                        // If we are searching for more than just exclusion groups...
                        else {
                            if(currentItem.manga.group.lowercaseString.containsString(searchGroupWithoutPossibleMinus)) {
                                // If the current search tag is an exclusion search tag...
                                if(searchGroupIsExclusion) {
                                    // Say we dont matching tags
                                    matchingGroups = false;
                                    
                                    // Say we already have matched an exclusion tag
                                    alreadyMatchedExclusionGroup = true;
                                }
                                else {
                                    // If we dont already have a matching exclusion group...
                                    if(!alreadyMatchedExclusionGroup) {
                                        // Say the group matches
                                        matchingGroups = true;
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Example search
                // title:"v007" series:"Yuru Yuri" artist:"namori" writer:"namori" tags:"school, comedy, -drama" groups:"reading, -dropped" favourites:"yes" read:"yes" percent:"<50"
                
                // Or you can use the simplified search term names
                // t:"v007" s:"Yuru Yuri" a:"namori" w:"namori" tg:"school, comedy, -drama" g:"reading, -dropped" f:"y" r:"y" p:"<50"
                
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
                // If we didnt search by groups...
                if(!searchedByGroups) {
                    // Say the groups matched
                    matchingGroups = true;
                }
                // If we didnt search by favourites...
                if(!searchedByFavourites) {
                    // Say the favourites matched
                    matchingFavourites = true;
                }
                // If we didnt search by read manga...
                if(!searchedByRead) {
                    // Say the read matched
                    matchingRead = true;
                }
                // If we didnt search by percent finished...
                if(!searchedByPercent) {
                    // Say the percent finished matched
                    matchingPercent = true;
                }
                
                // If everything matched...
                if(matchingTitle && matchingSeries && matchingArtist && matchingWriter && matchingTags && matchingGroups && matchingFavourites && matchingRead && matchingPercent) {
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
            setGridToItems(searchItems);
            
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
            setGridToItems(gridItems);
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
            setGridToItems(nonLewdManga);
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