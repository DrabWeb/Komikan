//
//  KMMigrationImporter.swift
//  Komikan
//
//  Created by Seth on 2016-03-13.
//

import Cocoa

/// Used for importing your collection that you exported for migration
class KMMigrationImporter {
    /// The manga grid controller to add the imported manga to
    var mangaGridController : KMMangaGridController = KMMangaGridController();
    
    /// Imports all the manga in the passed folder and all it's subfolders. Only imports ones that have metadata exported
    func importFolder(path : String) {
        // Print to the log that we are importing
        print("KMMigrationImporter: Trying to import files in \(path)");
        
        /// The file enumerator for the import folder
        let importFolderFileEnumerator : NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(path)!;
        
        // For every item in all the contents of the import path and its subfolders...
        for(_, currentFilePath) in importFolderFileEnumerator.enumerate() {
            /// The full path to the current file on the system
            let currentFileFullPath : String = path + String(currentFilePath);
            
            /// The extension of the current file
            let currentFileExtension : String = NSString(string: currentFileFullPath).pathExtension;
            
            // If the current file is a CBZ, CBR, ZIP, RAR or Folder...
            if(currentFileExtension == "cbz" || currentFileExtension == "cbr" || currentFileExtension == "zip" || currentFileExtension == "rar" || KMFileUtilities().isFolder(currentFileFullPath)) {
                // If the current file has a Komikan JSON file...
                if(KMFileUtilities().mangaFileHasJSON(currentFileFullPath)) {
                    // Print to the log that we are importing the current manga
                    print("KMMigrationImporter: Importing file \(currentFileFullPath)");
                    
                    /// The manga we will add
                    let manga : KMManga = KMManga();
                    
                    /// The SwiftyJSON object for the manga's JSON info
                    let mangaJson = JSON(data: NSFileManager.defaultManager().contentsAtPath(KMFileUtilities().mangaFileJSONPath(currentFileFullPath))!);
                    
                    // If the title value from the JSON is not "auto" or blank...
                    if(mangaJson["title"].stringValue != "auto" && mangaJson["title"].stringValue != "") {
                        // Set the manga's title to the value in the JSON
                        manga.title = mangaJson["title"].stringValue;
                    }
                    // If the title value is "auto"...
                    else if(mangaJson["title"].stringValue == "auto") {
                        // Set the manga's title to the file's name without the extension
                        manga.title = KMFileUtilities().getFileNameWithoutExtension(currentFileFullPath);
                    }
                    
                    // If the cover image value from the JSON is not "auto" or blank...
                    if(mangaJson["cover-image"].stringValue != "auto" && mangaJson["cover-image"].stringValue != "") {
                        // If the first character is not a "/"...
                        if(mangaJson["cover-image"].stringValue.substringToIndex(mangaJson["cover-image"].stringValue.startIndex.successor()) == "/") {
                            // Set the cover for this manga to the image file at cover-image
                            manga.coverImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: mangaJson["cover-image"].stringValue))!;
                        }
                        // If the cover-image value was local...
                        else {
                            // Get the relative image
                            manga.coverImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: KMFileUtilities().folderPathForFile(currentFileFullPath) + "Komikan/" + mangaJson["cover-image"].stringValue))!;
                        }
                    }
                    
                    // Set the series, artist, and writer
                    manga.series = mangaJson["series"].stringValue;
                    manga.artist = mangaJson["artist"].stringValue;
                    manga.writer = mangaJson["writer"].stringValue;
                    
                    // For every tag in the JSON's tags array...
                    for(_, currentTag) in mangaJson["tags"].arrayValue.enumerate() {
                        // Add the current tag to the manga's tags
                        manga.tags.append(currentTag.stringValue);
                    }
                    
                    // Set the group
                    manga.group = mangaJson["group"].stringValue;
                    
                    // Set if this manga is a favourite
                    manga.favourite = mangaJson["favourite"].boolValue;
                    
                    // Set if this manga is l-lewd...
                    manga.lewd = mangaJson["lewd"].boolValue;
                    
                    // If all the internal values are present...
                    if(mangaJson["current-page"].isExists() && mangaJson["page-count"].isExists() && mangaJson["saturation"].isExists() && mangaJson["brightness"].isExists() && mangaJson["contrast"].isExists() && mangaJson["sharpness"].isExists()) {
                        // Set the current page
                        manga.currentPage = mangaJson["current-page"].intValue - 1;
                        
                        // Set the page count
                        manga.pageCount = mangaJson["page-count"].intValue;
                        
                        // Set the color and sharpness values
                        manga.saturation = CGFloat(mangaJson["saturation"].floatValue);
                        manga.brightness = CGFloat(mangaJson["brightness"].floatValue);
                        manga.contrast = CGFloat(mangaJson["contrast"].floatValue);
                        manga.sharpness = CGFloat(mangaJson["sharpness"].floatValue);
                        
                        // Update the percent
                        manga.updatePercent();
                    }
                    
                    // Set the manga's directory
                    manga.directory = currentFileFullPath;
                    
                    /// The grid item we will add
                    let mangaGridItem : KMMangaGridItem = KMMangaGridItem();
                    
                    // Update the grid item's manga
                    mangaGridItem.changeManga(manga);
                    
                    // Add this manga
                    mangaGridController.addGridItem(mangaGridItem);
                    
                    // Update the filters
                    mangaGridController.updateFilters();
                    
                    // Create the new notification to tell the user the import has finished
                    let finishedNotification = NSUserNotification();
                    
                    // Set the title
                    finishedNotification.title = "Komikan";
                    
                    // Set the informative text
                    finishedNotification.informativeText = "Finished importing manga from \"" + currentFileFullPath + "\"";
                    
                    // Set the notifications identifier to be an obscure string, so we can show multiple at once
                    finishedNotification.identifier = NSUUID().UUIDString;
                    
                    // Show the notification
                    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
                }
            }
        }
    }
}
