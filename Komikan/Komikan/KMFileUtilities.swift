//
//  KMFileUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-01-01.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation
import Cocoa

class KMFileUtilities {
    /// Is the given file an image?
    func isImage(path : String) -> Bool {
        // Return if teh image file types contains the passed file's extension
        return NSImage.imageFileTypes().contains(KMFileUtilities().getFileExtension(NSURL(fileURLWithPath: path)));
    }
    
    /// Is the given file a folder?
    func isFolder(path : String) -> Bool {
        // If the contents of the file at the given path arent nil(Meaning its a file)...
        if(NSFileManager.defaultManager().contentsAtPath(path) != nil) {
            // Return false
            return false;
        }
        // If the contents of the file at the given path are nil(Meaning its a folder)...
        else {
            // Return true
            return true;
        }
    }
    
    /// Returns the path to the encasing folder for the file at the given path
    func folderPathForFile(filePath : String) -> String {
        /// The path to the file's folder
        var folderPath : String = filePath;
        
        // Remove everything after the last "/" in the string so we can get the folder
        folderPath = folderPath.substringToIndex(folderPath.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)!.startIndex);
        
        // Append a slash to the end because it removes it
        folderPath += "/";
        
        // Remove the file:// from the folder path string(Theres a chance there could be one)
        folderPath = folderPath.stringByReplacingOccurrencesOfString("file://", withString: "");
        
        // Remove the percent encoding from the folder path string
        folderPath = folderPath.stringByRemovingPercentEncoding!;
        
        // Return the folder path
        return folderPath;
    }
    
    /// Exports the passed KMManga's info into a Komikan readable JSON file in the correc directory. Also exports the internal info like current page, bookmarks, brightness, ETC. if exportInternalInfo is true
    func exportMangaJSON(manga : KMManga, exportInternalInfo : Bool) {
        /// The JSON string that we will write to a JSON file at the end
        var jsonString : String = "{\n";
        
        // Add the title
        jsonString += "    \"title\":\"" + manga.title + "\",\n";
        
        // Add the cover image data
        jsonString += "    \"cover-image\":\"" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".png" + "\", \n";
        
        // Add the series
        jsonString += "    \"series\":\"" + manga.series + "\",\n";
        
        // Add the artist
        jsonString += "    \"artist\":\"" + manga.artist + "\",\n";
        
        // Add the writer
        jsonString += "    \"writer\":\"" + manga.writer + "\",\n";
        
        // Add the tags
        jsonString += "    \"tags\":["
        
        // For every tag in the manga...
        for(_, currentTag) in manga.tags.enumerate() {
            jsonString += "\"" + currentTag + "\", ";
        }
        
        // If the manga had any tags...
        if(manga.tags.count > 0) {
            // Remove the last character from the JSON string(It would be a ", " if we had any tags to add)
            jsonString = jsonString.substringToIndex(jsonString.endIndex.predecessor().predecessor());
        }
        
        // Add the closing bracket and the "," to the JSON string
        jsonString += "], \n";
        
        // Add the group
        jsonString += "    \"group\":\"" + manga.group + "\",\n";
        
        // Add if this is a favourite
        jsonString += "    \"favourite\":" + String(manga.favourite) + ",\n";
        
        // If we said to export internal info...
        if(exportInternalInfo) {
            // Add if this is l-lewd...
            jsonString += "    \"lewd\":" + String(manga.lewd) + ",\n";
            
            // Add the current page
            jsonString += "    \"current-page\":" + String(manga.currentPage + 1) + ",\n";
            
            // Add the page count
            jsonString += "    \"page-count\":" + String(manga.pageCount) + ",\n";
            
            // Add the manga's filename
            jsonString += "    \"filename\":\"" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + "\",\n";
            
            // Add the Saturation, Brightness, Contrast and Sharpness
            jsonString += "    \"saturation\":" + String(manga.saturation) + ",\n";
            jsonString += "    \"brightness\":" + String(manga.brightness) + ",\n";
            jsonString += "    \"contrast\":" + String(manga.contrast) + ",\n";
            jsonString += "    \"sharpness\":" + String(manga.sharpness) + "\n";
        }
        else {
            // Add if this is l-lewd...
            jsonString += "    \"lewd\":" + String(manga.lewd) + "\n";
        }
        
        // Add the closing brace
        jsonString += "}";
        
        // Get the folder that the manga is in
        /// The selected Mangas folder it is in
        var folderURLString : String = folderPathForFile(manga.directory);
        
        // Add the "Komikan" folder to the end of the folder path
        folderURLString += "Komikan/"
        
        // Make sure the Komikan folder exists
        do {
            // Try to create the Komikan folder in the manga's folder
            try NSFileManager.defaultManager().createDirectoryAtPath(folderURLString, withIntermediateDirectories: false, attributes: nil);
        }
        catch _ as NSError {
            // Do nothing
        }
        
        // Export the cover image as a PNG to the metadata folder with the same name as the JSON file but with a .png on the end and not .json
        manga.coverImage.TIFFRepresentation?.writeToFile(folderURLString + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".png", atomically: true);
        
        // Write the JSON string to the appropriate file
        do {
            try jsonString.writeToFile(folderURLString + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".json", atomically: true, encoding: NSUTF8StringEncoding);
        }
        catch _ as NSError {
            // Ignore the error
        }
    }
    
    // Returns a srting with the given files extension
    func getFileExtension(fileUrl : NSURL) -> String {
        // Split the file URL into an array, where each element is after the last dot and before the next
        let splitPathAtDots : [String] = fileUrl.absoluteString.componentsSeparatedByString(".");
        
        // Return the last one
        return splitPathAtDots.last!;
    }
    
    // Removes the URL encoding strings (%20, ETC.) from the given string
    func removeURLEncoding(string : String) -> String {
        // Replace %20 with a " "
        let stringWithoutURLEncoding : String = string.stringByRemovingPercentEncoding!;
        
        // Return the new string
        return stringWithoutURLEncoding;
    }
    
    // Returns the name of the file at the given path
    func getFileNameWithoutExtension(path : String) -> String {
        //// The file path without the possible file://
        let pathWithoutFileMarker : String = path.stringByReplacingOccurrencesOfString("file://", withString: "");
        
        /// The name of the passed file, with the extension
        let fileName : String = NSURL(fileURLWithPath: path).lastPathComponent!.stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("file://", withString: "");
        
        /// fileName split at every .
        var fileNameSplitAtDot : [String] = fileName.componentsSeparatedByString(".");
        
        // Remove the last item(The file extension) from fileNameSplitAtDot
        fileNameSplitAtDot.removeLast();
        
        /// The file name, without the extension
        var filenameWithoutExtension : String = "";
        
        // If the passed file isnt a Folder...
        if(!KMFileUtilities().isFolder(pathWithoutFileMarker)) {
            // Iterate through fileNameSplitAtDot
            for (currentIndex, currentItem) in fileNameSplitAtDot.enumerate() {
                // If this isnt the last item...
                if(currentIndex < fileNameSplitAtDot.count - 1) {
                    // Append the current value onto fileName, with a dot
                    filenameWithoutExtension += (currentItem + ".");
                }
                else {
                    // Append the current value onto fileName
                    filenameWithoutExtension += currentItem;
                }
            }
        }
        // If the passed file is a Folder...
        else {
            // Set the file name to the name of the Folder
            filenameWithoutExtension = fileName;
        }
        
        // Return the filename, without the extension
        return filenameWithoutExtension;
    }
    
    // Returns a bool from a string(If the string is "true", it returns true, otherwise false)
    func stringToBool(string : String) -> Bool {
        // The variable we will return
        var bool : Bool = false;
        
        // If the string is "true"...
        if(string == "true") {
            // Set bool to true
            bool = true;
        }
        
        // Return bool
        return bool;
    }
    
    // Extracts the passed archive to the passed directory
    func extractArchive(archiveDirectory : String, toDirectory : String) {
        // If the directory we are trying to extract to doesnt already exist...
        if(!NSFileManager.defaultManager().fileExistsAtPath(toDirectory)) {
            // Print to the log what we are extracting and where to
            print("Extracting \"" + archiveDirectory + "\" to \"" + toDirectory + "\"");
            
            // Get the extension
            let archiveType : String = getFileExtension(NSURL(fileURLWithPath: archiveDirectory));
            
            // If the archive is a CBZ or ZIP...
            if(archiveType == "cbz" || archiveType == "zip") {
                // I like this library. One line to extract
                // Extract the given file to the given directory
                WPZipArchive.unzipFileAtPath(archiveDirectory, toDestination: toDirectory);
            }
                // If the archive is a CBR or RAR...
            else if(archiveType == "cbr" || archiveType == "rar") {
                // This one not so much
                // Create a variable to store our archive
                var archive : URKArchive!;
                
                // Set the archive
                do {
                    // Try to set it to the archive we passed
                    archive = try URKArchive(path: archiveDirectory);
                }
                    // If there is an error...
                catch let error as NSError {
                    // Print the errors description
                    print(error.description);
                }
                
                // Extract the archive
                do {
                    // Try to extract the given archive to the given directory
                    try archive.extractFilesTo(toDirectory, overwrite: true, progress: nil);
                }
                    // If there is an error...
                catch let error as NSError {
                    // Print the errors description
                    print(error.description);
                }
            }
        }
        // If we did already extract it...
        else {
            // Print to the log that it is already extracted
            print("Already extracted \"" + archiveDirectory + "\" to \"" + toDirectory + "\"");
        }
    }
}