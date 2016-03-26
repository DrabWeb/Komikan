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
    
    /// An instance to the main View Controller
    @IBOutlet weak var viewController: ViewController!
    
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
        // Convert grid items to a mutable array, remove the object we want to remove, and save it back to gridItems
        let gridItemsMutableArray : NSMutableArray = NSMutableArray(array: gridItems);
        gridItemsMutableArray.removeObject(gridItem);
        gridItems = Array(gridItemsMutableArray) as! [KMMangaGridItem];
                
        // Remove the grid object from the array controller
        arrayController.removeObject(gridItem);
        
        // If the manga is from EH and we said in the preferences to delete them...
        if(gridItem.manga.directory.containsString("/Library/Application Support/Komikan/EH") && (NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.deleteLLewdMangaWhenRemovingFromTheGrid) {
            // Also delete the file
            do {
                // Move the manga file to the trash
                try NSFileManager.defaultManager().trashItemAtURL(NSURL(fileURLWithPath: gridItem.manga.directory), resultingItemURL: nil);
                
                // Print to the log that we deleted it
                print("Deleted manga \"" + gridItem.manga.title + "\"'s file");
            }
                // If there is an error...
            catch _ as NSError {
                // Do nothing
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
            // Update the filters
            self.updateFilters();
        }
    }
    
    /// Updates the l-lewd... and search filters
    func updateFilters() {
        // Reload the l-lewd... manga filter
        displayLewdMangaAppDelegate();
        
        // Redo the last search
        redoSearch();
    }
    
    /// Redos the current search(If we are currently searching)
    func redoSearch() {
        // If we are searching...
        if(searching) {
            // Redo the search
            searchFor(lastSearchText);
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
    func countOfArtist(artist : String) -> Int {
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
        return artists.occurenceCountOf(artist);
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
    
    /// Returns a random cover image from all the manga in the given series
    func firstCoverImageForSeries(series : String) -> NSImage {
        /// All the manga in the given series
        var matchingManga : [KMManga] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If the current item's manga's series isnt blank and the series matches...
            if(currentGridItem.manga.series != "" && currentGridItem.manga.series == series) {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this manga to the list of matching manga
                    matchingManga.append(currentGridItem.manga);
                }
            }
        }
        
        // If the matching manga isnt blank...
        if(!matchingManga.isEmpty) {
            // Return a random manga in the matchingManga array's cover image
            return matchingManga[Int(arc4random_uniform(UInt32(matchingManga.count)))].coverImage;
        }
        // If the matching manga is blank...
        else {
            // Return a caution
            return NSImage(named: "NSCaution")!;
        }
    }
    
    /// Returns a random cover image from all the manga by the given artist
    func firstCoverImageForArtist(artist : String) -> NSImage {
        /// All the manga in the given series
        var matchingManga : [KMManga] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If the current item's manga's artist isnt blank and the artist matches...
            if(currentGridItem.manga.artist != "" && currentGridItem.manga.artist == artist) {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this manga to the list of matching manga
                    matchingManga.append(currentGridItem.manga);
                }
            }
        }
        
        // If the matching manga isnt blank...
        if(!matchingManga.isEmpty) {
            // Return a random manga in the matchingManga array's cover image
            return matchingManga[Int(arc4random_uniform(UInt32(matchingManga.count)))].coverImage;
        }
        // If the matching manga is blank...
        else {
            // Return a caution 
            return NSImage(named: "NSCaution")!;
        }
    }
    
    /// Returns a random cover image from all the manga by the given author
    func firstCoverImageForWriter(writer : String) -> NSImage {
        /// All the manga in the given series
        var matchingManga : [KMManga] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If the current item's manga's author isnt blank and the author matches...
            if(currentGridItem.manga.artist != "" && currentGridItem.manga.writer == writer) {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this manga to the list of matching manga
                    matchingManga.append(currentGridItem.manga);
                }
            }
        }
        
        // If the matching manga isnt blank...
        if(!matchingManga.isEmpty) {
            // Return a random manga in the matchingManga array's cover image
            return matchingManga[Int(arc4random_uniform(UInt32(matchingManga.count)))].coverImage;
        }
        // If the matching manga is blank...
        else {
            // Return a caution
            return NSImage(named: "NSCaution")!;
        }
    }
    
    /// Returns a random cover image from all the manga that have the given tag
    func firstCoverImageForTag(tag : String) -> NSImage {
        /// All the manga in the given series
        var matchingManga : [KMManga] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If the current item's manga's tags contains the given tag...
            if(currentGridItem.manga.tags.contains(tag)) {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this manga to the list of matching manga
                    matchingManga.append(currentGridItem.manga);
                }
            }
        }
        
        // If the matching manga isnt blank...
        if(!matchingManga.isEmpty) {
            // Return a random manga in the matchingManga array's cover image
            return matchingManga[Int(arc4random_uniform(UInt32(matchingManga.count)))].coverImage;
        }
        // If the matching manga is blank...
        else {
            // Return a caution
            return NSImage(named: "NSCaution")!;
        }
    }
    
    /// Returns a random cover image from all the manga in the given group
    func firstCoverImageForGroup(group : String) -> NSImage {
        /// All the manga in the given series
        var matchingManga : [KMManga] = [];
        
        // For every item in the grid items...
        for(_, currentGridItem) in gridItems.enumerate() {
            // If the current item's manga's group isnt blank and the group matches...
            if(currentGridItem.manga.group != "" && currentGridItem.manga.group == group) {
                // If we arent in l-lewd... mode and this manga is lewd...
                if(!showingLewdManga && currentGridItem.manga.lewd) {
                    // Do nothing
                }
                else {
                    // Add this manga to the list of matching manga
                    matchingManga.append(currentGridItem.manga);
                }
            }
        }
        
        // If the matching manga isnt blank...
        if(!matchingManga.isEmpty) {
            // Return a random manga in the matchingManga array's cover image
            return matchingManga[Int(arc4random_uniform(UInt32(matchingManga.count)))].coverImage;
        }
        // If the matching manga is blank...
        else {
            // Return a caution
            return NSImage(named: "NSCaution")!;
        }
    }
    
    // A bool to say if we are currently searching
    var searching : Bool = false;
    
    /// The last entered search text
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
                
                // Resort the manga items
                sort(currentSortOrder, ascending: currentSortAscending);
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
            
            /// The thing we want to sort by(If we search for sort)
            var sortSearch : String = "";
            
            /// The l-lewd... search content(If we search by l-lewd...)
            var lewdSearch : String = "";
            
            /// The search string without the possible " on the end
            var cleanedSearchText : String = searchText;
            
            // If the last character in the search string is a "...
            if(cleanedSearchText.characters.last! == "\"") {
                // Remove the last character of the string(Why does Swift make you do this like this?)
                cleanedSearchText = cleanedSearchText.substringToIndex(cleanedSearchText.endIndex.predecessor());
            }
            
            /// The search string split at every "" "
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
                    // If its sort...
                    case "sort", "so":
                        // Set the appropriate variable to the current strings search content
                        sortSearch = currentString.componentsSeparatedByString(":\"").last!;
                        break;
                    // If its l-lewd...
                    case "lewd", "l":
                        // Set the appropriate variable to the current strings search content
                        lewdSearch = currentString.componentsSeparatedByString(":\"").last!;
                        break;
                    // If it is one that we dont have...
                    default:
                        // Print to the log that it didnt match any types we search by
                        print("Did not match any search types, defaulting to title");
                        
                        // Set the title search to this search
                        titleSearch = currentString;
                        
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
            
            /// Did we search for sort?
            let searchedBySort : Bool = (sortSearch != "");
            
            /// Did we search by l-lewd...?
            let searchedByLewd : Bool = (lewdSearch != "");
            
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
                
                /// Do we have matching l-lewd...?
                var matchingLewd : Bool = false;
                
                // If we searched by title...
                if(searchedByTitle) {
                    // If we had a "-" in front(Meaning we dont want to show manga with the title search in their name)...
                    if(titleSearch.substringToIndex(titleSearch.startIndex.successor()) == "-") {
                        // If the current items title doesnt contain the title search... (In lowercase to be case insensitive)
                        if(!currentItem.manga.title.lowercaseString.containsString(titleSearch.lowercaseString.substringFromIndex(titleSearch.startIndex.successor()))) {
                            // Say there is a matching title
                            matchingTitle = true;
                        }
                    }
                    // If we want to show manga that have the title search in their name...
                    else {
                        // If the current items title contain the title search... (In lowercase to be case insensitive)
                        if(currentItem.manga.title.lowercaseString.containsString(titleSearch.lowercaseString)) {
                            // Say there is a matching title
                            matchingTitle = true;
                        }
                    }
                }
                
                // If we searched by series...
                if(searchedBySeries) {
                    /// Did we search for any exclusion series?
                    var searchedForExclusion : Bool = false;
                    
                    /// Did this manga end up having an exclusion series in it?
                    var matchedExclusionSeries : Bool = false;
                    
                    /// Did this manga end up having a non exclusion series in it?
                    var matchedSeries : Bool = false;
                    
                    // For every series search...
                    for(_, currentSeriesSearch) in seriesSearch.enumerate() {
                        /// Are we doing an exclusion search for this series?
                        let exclusionSearch : Bool = (currentSeriesSearch.substringToIndex(currentSeriesSearch.startIndex.successor()) == "-");
                        
                        /// The current series search without the possible "-" in front
                        var currentSeriesSearchWithoutPossibleMinus : String = currentSeriesSearch;
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // Set the series search without possible minus to the series search without the first character
                            currentSeriesSearchWithoutPossibleMinus = currentSeriesSearch.substringFromIndex(currentSeriesSearch.startIndex.successor());
                        }
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // If this manga's series equals the current series search...
                            if(currentItem.manga.series.lowercaseString == currentSeriesSearchWithoutPossibleMinus) {
                                // Say we matched exclusion series
                                matchedExclusionSeries = true;
                            }
                        }
                        // If this wasnt an exclusion search...
                        else {
                            // If this manga's series equals the current series search...
                            if(currentItem.manga.series.lowercaseString == currentSeriesSearchWithoutPossibleMinus) {
                                // Say we matched series
                                matchedSeries = true;
                            }
                        }
                        
                        // Set searchedForExclusion to exclusionSearch
                        searchedForExclusion = exclusionSearch;
                    }
                    
                    // If we didnt match exclusion series but matched series...
                    if(!matchedExclusionSeries && matchedSeries) {
                        // Say the series matched
                        matchingSeries = true;
                    }
                    // If we matched exclusion series but didnt match series...
                    else if(matchedExclusionSeries && !matchedSeries) {
                        // Say the series didnt match
                        matchingSeries = false;
                    }
                    // If we matched both...
                    else if(!matchedExclusionSeries && !matchedSeries) {
                        // If we searched for any exclusion series...
                        if(searchedForExclusion) {
                            // Say the series matched
                            matchingSeries = true;
                        }
                        // If we didnt search for any exclusion series...
                        else {
                            // Say the series didnt match
                            matchingSeries = false;
                        }
                    }
                    // If we matched neither...
                    else if(matchedExclusionSeries && matchedSeries) {
                        // Say the series didnt match
                        matchingSeries = false;
                    }
                }
                
                // If we searched by artist...
                if(searchedByArtist) {
                    /// Did we search for any exclusion artists?
                    var searchedForExclusion : Bool = false;
                    
                    /// Did this manga end up having an exclusion artists in it?
                    var matchedExclusionArtist : Bool = false;
                    
                    /// Did this manga end up having a non exclusion artist in it?
                    var matchedArtist : Bool = false;
                    
                    // For every artist search...
                    for(_, currentArtistSearch) in artistSearch.enumerate() {
                        /// Are we doing an exclusion search for this artist?
                        let exclusionSearch : Bool = (currentArtistSearch.substringToIndex(currentArtistSearch.startIndex.successor()) == "-");
                        
                        /// The current artist search without the possible "-" in front
                        var currentArtistSearchWithoutPossibleMinus : String = currentArtistSearch;
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // Set the artist search without possible minus to the artist search without the first character
                            currentArtistSearchWithoutPossibleMinus = currentArtistSearch.substringFromIndex(currentArtistSearch.startIndex.successor());
                        }
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // If this manga's artist equals the current artist search...
                            if(currentItem.manga.artist.lowercaseString == currentArtistSearchWithoutPossibleMinus) {
                                // Say we matched exclusion artists
                                matchedExclusionArtist = true;
                            }
                        }
                        // If this wasnt an exclusion search...
                        else {
                            // If this manga's artist equals the current artist search...
                            if(currentItem.manga.artist.lowercaseString == currentArtistSearchWithoutPossibleMinus) {
                                // Say we matched artists
                                matchedArtist = true;
                            }
                        }
                        
                        // Set searchedForExclusion to exclusionSearch
                        searchedForExclusion = exclusionSearch;
                    }
                    
                    // If we didnt match exclusion artist but matched artist...
                    if(!matchedExclusionArtist && matchedArtist) {
                        // Say the artist matched
                        matchingArtist = true;
                    }
                    // If we matched exclusion artist but didnt match artist...
                    else if(matchedExclusionArtist && !matchedArtist) {
                        // Say the artist didnt match
                        matchingArtist = false;
                    }
                    // If we matched both...
                    else if(!matchedExclusionArtist && !matchedArtist) {
                        // If we searched for any exclusion artists...
                        if(searchedForExclusion) {
                            // Say the artist matched
                            matchingArtist = true;
                        }
                        // If we didnt search for any exclusion artists...
                        else {
                            // Say the artist didnt match
                            matchingArtist = false;
                        }
                    }
                    // If we matched neither...
                    else if(matchedExclusionArtist && matchedArtist) {
                        // Say the artist didnt match
                        matchingArtist = false;
                    }
                }
                
                // If we searched by writer...
                if(searchedByWriter) {
                    /// Did we search for any exclusion authors?
                    var searchedForExclusion : Bool = false;
                    
                    /// Did this manga end up having an exclusion author in it?
                    var matchedExclusionWriter : Bool = false;
                    
                    /// Did this manga end up having a non exclusion author in it?
                    var matchedWriter : Bool = false;
                    
                    // For every artist search...
                    for(_, currentWriterSearch) in writerSearch.enumerate() {
                        /// Are we doing an exclusion search for this author?
                        let exclusionSearch : Bool = (currentWriterSearch.substringToIndex(currentWriterSearch.startIndex.successor()) == "-");
                        
                        /// The current author search without the possible "-" in front
                        var currentWriterSearchWithoutPossibleMinus : String = currentWriterSearch;
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // Set the author search without possible minus to the author search without the first character
                            currentWriterSearchWithoutPossibleMinus = currentWriterSearch.substringFromIndex(currentWriterSearch.startIndex.successor());
                        }
                        
                        // If this is an exclusion search...
                        if(exclusionSearch) {
                            // If this manga's author equals the current author search...
                            if(currentItem.manga.writer.lowercaseString == currentWriterSearchWithoutPossibleMinus) {
                                // Say we matched exclusion author
                                matchedExclusionWriter = true;
                            }
                        }
                        // If this wasnt an exclusion search...
                        else {
                            // If this manga's author equals the current author search...
                            if(currentItem.manga.writer.lowercaseString == currentWriterSearchWithoutPossibleMinus) {
                                // Say we matched authors
                                matchedWriter = true;
                            }
                        }
                        
                        // Set searchedForExclusion to exclusionSearch
                        searchedForExclusion = exclusionSearch;
                    }
                    
                    // If we didnt match exclusion authors but matched author...
                    if(!matchedExclusionWriter && matchedWriter) {
                        // Say the author matched
                        matchingWriter = true;
                    }
                    // If we matched exclusion authors but didnt match author...
                    else if(matchedExclusionWriter && !matchedWriter) {
                        // Say the artist didnt match
                        matchingWriter = false;
                    }
                    // If we matched both...
                    else if(!matchedExclusionWriter && !matchedWriter) {
                        // If we searched for any exclusion authors...
                        if(searchedForExclusion) {
                            // Say the author matched
                            matchingWriter = true;
                        }
                        // If we didnt search for any exclusion authors...
                        else {
                            // Say the author didnt match
                            matchingWriter = false;
                        }
                    }
                    // If we matched neither...
                    else if(matchedExclusionWriter && matchedWriter) {
                        // Say the author didnt match
                        matchingWriter = false;
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
                    // If we searched for a percentage between two percentages...
                    else if(percentSearch.containsString("<") && percentSearch.containsString(">")) {
                        /// The minimum percent we want to find manga by
                        let minPercent : Int = NSString(string: percentSearch.componentsSeparatedByString(">").first!).integerValue;
                        
                        /// The maximum percent we want to find manga by
                        let maxPercent : Int = NSString(string: percentSearch.componentsSeparatedByString("<").last!).integerValue;
                        
                        // If the current manga's percent finished is in between the minimum and maximum percent...
                        if(currentItem.manga.percentFinished > minPercent && currentItem.manga.percentFinished < maxPercent) {
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
                
                // If we searched by sort...
                if(searchedBySort) {
                    // Sort the manga items by the given key
                    self.arrayController.sortDescriptors = [NSSortDescriptor(key: sortSearch, ascending: currentSortAscending)];
                }
                
                // If we searched by l-lewd...
                if(searchedByLewd) {
                    // If the current items l-lewd... value is the same as the l-lewd... value we searched for...
                    if(currentItem.manga.lewd == lewdSearch.toBool()) {
                        // Say there is a matching l-lewd... manga
                        matchingLewd = true;
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
                            if(currentItem.manga.group.lowercaseString == searchGroupWithoutPossibleMinus) {
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
                // title:"v007" series:"Yuru Yuri, -Non Non Biyori" artist:"namori, -atto" writer:"namori, -atto" tags:"school, comedy, -drama" groups:"reading, -dropped" favourites:"yes" read:"yes" percent:"<50" lewd:"no"
                
                // Or you can use the simplified search term names
                // t:"v007" s:"Yuru Yuri, -Non Non Biyori" a:"namori, -atto" w:"namori, -atto" tg:"school, comedy, -drama" g:"reading, -dropped" f:"y" r:"y" p:"<50" l:"n"
                
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
                // If we didnt search by l-lewd...
                if(!searchedByLewd) {
                    // Say l-lewd... search matched
                    matchingLewd = true;
                }
                
                // If everything matched...
                if(matchingTitle && matchingSeries && matchingArtist && matchingWriter && matchingTags && matchingGroups && matchingFavourites && matchingRead && matchingPercent && matchingLewd) {
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
        // Display l-lewd... manga based on the AppDelegate's preferences keeper
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
    
    /// Wrapper to ViewController.clearMangaSelection
    func clearMangaSelection() {
        viewController.clearMangaSelection();
    }
    
    /// Wrapper to ViewController.restoreSelection
    func restoreSelection() {
        viewController.restoreSelection();
    }
    
    /// Wrapper to ViewController.storeCurrentSelection
    func storeCurrentSelection() {
        viewController.storeCurrentSelection();
    }
}