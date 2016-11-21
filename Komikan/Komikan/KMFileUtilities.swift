//
//  KMFileUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-01-01.
//

import Foundation
import Cocoa
import UnrarKit
import WPZipArchive

class KMFileUtilities {
    /// Returns the path to the folder the given file is in(Keeps keep the / on the end)
    func folderPathForFile(_ path : String) -> String {
        // Remove the last path component(File name) of the given path from folderPath
        /// The path of the file's folder
        let folderPath : String = path.replacingOccurrences(of: NSString(string: path).lastPathComponent, with: "");
        
        // Return the folder path
        return folderPath;
    }
    
    /// Returns the path of a manga file's Komikan JSON metadata, returns the path even if it doesnt exist
    func mangaFileJSONPath(_ path : String) -> String {
        /// The path of the possible JSON file
        var jsonPath : String = path;
        
        // Set the JSON path to not include the manga filename
        jsonPath = jsonPath.replacingOccurrences(of: NSString(string: jsonPath).lastPathComponent, with: "");
        
        // Add the file's name with .json on the end to jsonPath
        jsonPath = jsonPath + "Komikan/" + NSString(string: path).lastPathComponent + ".json";
        
        // Return the JSON path
        return jsonPath;
    }
    
    /// Does the manga file at the given path have a metadata JSON file?
    func mangaFileHasJSON(_ path : String) -> Bool {
        // Return if the JSON file for the given manga file exists
        return FileManager.default.fileExists(atPath: mangaFileJSONPath(path));
    }
    
    /// Is the given file an image?
    func isImage(_ path : String) -> Bool {
        // Return if teh image file types contains the passed file's extension
        return NSImage.imageFileTypes().contains(KMFileUtilities().getFileExtension(URL(fileURLWithPath: path)));
    }
    
    /// Is the given file a folder?
    func isFolder(_ path : String) -> Bool {
        // If the contents of the file at the given path arent nil(Meaning its a file)...
        if(FileManager.default.contents(atPath: path) != nil) {
            // Return false
            return false;
        }
        // If the contents of the file at the given path are nil(Meaning its a folder)...
        else {
            // Return true
            return true;
        }
    }
    
    /// Exports the passed KMManga's info into a Komikan readable JSON file in the correc directory. Also exports the internal info like current page, bookmarks, brightness, ETC. if exportInternalInfo is true
    func exportMangaJSON(_ manga : KMManga, exportInternalInfo : Bool) {
        /// The JSON string that we will write to a JSON file at the end
        var jsonString : String = "{\n";
        
        // Add the title
        jsonString += "    \"title\":\"" + manga.title + "\",\n";
        
        // Add the cover image data
        jsonString += "    \"cover-image\":\"" + URL(fileURLWithPath: manga.directory).lastPathComponent.removingPercentEncoding! + ".png" + "\", \n";
        
        // Add the series
        jsonString += "    \"series\":\"" + manga.series + "\",\n";
        
        // Add the artist
        jsonString += "    \"artist\":\"" + manga.artist + "\",\n";
        
        // Add the writer
        jsonString += "    \"writer\":\"" + manga.writer + "\",\n";
        
        // Add the tags
        jsonString += "    \"tags\":["
        
        // For every tag in the manga...
        for(_, currentTag) in manga.tags.enumerated() {
            // Add the current tag
            jsonString += "\"" + currentTag + "\", ";
        }
        
        // If the manga had any tags...
        if(manga.tags.count > 0) {
            // Remove the last character from the JSON string(It would be a ", " if we had any tags to add)
            jsonString = jsonString.substring(to: jsonString.index(before: jsonString.characters.index(before: jsonString.endIndex)));
        }
        
        // Add the closing bracket and the "," to the JSON string
        jsonString += "], \n";
        
        // Add the group
        jsonString += "    \"group\":\"" + manga.group + "\",\n";
        
        // Add if this is a favourite
        jsonString += "    \"favourite\":" + String(manga.favourite) + ",\n";
        
        // Add if this is l-lewd...
        jsonString += "    \"lewd\":" + String(manga.lewd) + ",\n";
        
        // If we said to export internal info...
        if(exportInternalInfo) {
            /// The date formatter for the release date string
            let releaseDateFormatter : DateFormatter = DateFormatter();
            
            // Set the format to be full month name day, year
            releaseDateFormatter.dateFormat = "MMMM dd, YYYY";
            
            /// The string of the release date
            var releaseDateString : String = "";
            
            // If the release date is set...
            if(!manga.releaseDate.isBeginningOfEpoch()) {
                // Set the release date string to the release date formatted with releaseDateFormatter
                releaseDateString = releaseDateFormatter.string(from: manga.releaseDate as Date);
            }
                // If the release date isn't set...
            else {
                // Set the release date string to "unknown"
                releaseDateString = "unknown";
            }
            
            // Add the published date
            jsonString += "    \"published\":\"" + releaseDateString + "\",\n";
            
            // Add the current page
            jsonString += "    \"current-page\":" + String(manga.currentPage + 1) + ",\n";
            
            // Add the page count
            jsonString += "    \"page-count\":" + String(manga.pageCount) + ",\n";
            
            // Add the Saturation, Brightness, Contrast and Sharpness
            jsonString += "    \"saturation\":" + String(describing: manga.saturation) + ",\n";
            jsonString += "    \"brightness\":" + String(describing: manga.brightness) + ",\n";
            jsonString += "    \"contrast\":" + String(describing: manga.contrast) + ",\n";
            jsonString += "    \"sharpness\":" + String(describing: manga.sharpness) + "\n";
        }
        else {
            /// The date formatter for the release date string
            let releaseDateFormatter : DateFormatter = DateFormatter();
            
            // Set the format to be full month name day, year
            releaseDateFormatter.dateFormat = "MMMM dd, YYYY";
            
            /// The string of the release date
            var releaseDateString : String = "";
            
            // If the release date is set...
            if(!manga.releaseDate.isBeginningOfEpoch()) {
                // Set the release date string to the release date formatted with releaseDateFormatter
                releaseDateString = releaseDateFormatter.string(from: manga.releaseDate as Date);
            }
            // If the release date isn't set...
            else {
                // Set the release date string to "unknown"
                releaseDateString = "unknown";
            }
            
            // Add the published date
            jsonString += "    \"published\":\"" + releaseDateString + "\"\n";
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
            try FileManager.default.createDirectory(atPath: folderURLString, withIntermediateDirectories: false, attributes: nil);
        }
        catch _ as NSError {
            // Do nothing
        }
        
        // Export the cover image as a PNG to the metadata folder with the same name as the JSON file but with a .png on the end and not .json
        try? manga.coverImage.tiffRepresentation?.write(to: URL(fileURLWithPath: folderURLString + URL(fileURLWithPath: manga.directory).lastPathComponent.removingPercentEncoding! + ".png"), options: [.atomic]);
        
        // Write the JSON string to the appropriate file
        do {
            try jsonString.write(toFile: folderURLString + URL(fileURLWithPath: manga.directory).lastPathComponent.removingPercentEncoding! + ".json", atomically: true, encoding: String.Encoding.utf8);
        }
        catch _ as NSError {
            // Ignore the error
        }
    }
    
    // Returns a srting with the given files extension
    func getFileExtension(_ fileUrl : URL) -> String {
        // Split the file URL into an array, where each element is after the last dot and before the next
        let splitPathAtDots : [String] = fileUrl.absoluteString.components(separatedBy: ".");
        
        // Return the last one
        return splitPathAtDots.last!;
    }
    
    // Removes the URL encoding strings (%20, ETC.) from the given string
    func removeURLEncoding(_ string : String) -> String {
        // Replace %20 with a " "
        let stringWithoutURLEncoding : String = string.removingPercentEncoding!;
        
        // Return the new string
        return stringWithoutURLEncoding;
    }
    
    // Returns the name of the file at the given path
    func getFileNameWithoutExtension(_ path : String) -> String {
        //// The file path without the possible file://
        let pathWithoutFileMarker : String = path.replacingOccurrences(of: "file://", with: "");
        
        /// The name of the passed file, with the extension
        let fileName : String = URL(fileURLWithPath: path).lastPathComponent.removingPercentEncoding!.replacingOccurrences(of: "file://", with: "");
        
        /// fileName split at every .
        var fileNameSplitAtDot : [String] = fileName.components(separatedBy: ".");
        
        // Remove the last item(The file extension) from fileNameSplitAtDot
        fileNameSplitAtDot.removeLast();
        
        /// The file name, without the extension
        var filenameWithoutExtension : String = "";
        
        // If the passed file isnt a Folder...
        if(!KMFileUtilities().isFolder(pathWithoutFileMarker)) {
            // Iterate through fileNameSplitAtDot
            for (currentIndex, currentItem) in fileNameSplitAtDot.enumerated() {
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
    func stringToBool(_ string : String) -> Bool {
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
    func extractArchive(_ archiveDirectory : String, toDirectory : String) {
        // If the directory we are trying to extract to doesnt already exist...
        if(!FileManager.default.fileExists(atPath: toDirectory)) {
            // Print to the log what we are extracting and where to
            print("KMFileUtilities: Extracting \"" + archiveDirectory + "\" to \"" + toDirectory + "\"");
            
            // Get the extension
            let archiveType : String = getFileExtension(URL(fileURLWithPath: archiveDirectory));
            
            // If the archive is a CBZ or ZIP...
            if(archiveType == "cbz" || archiveType == "zip") {
                // I like this library. One line to extract
                // Extract the given file to the given directory
                WPZipArchive.unzipFile(atPath: archiveDirectory, toDestination: toDirectory);
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
                    print("KMFileUtilities: Error getting RAR archive, \(error.description)");
                }
                
                // Extract the archive
                do {
                    // Try to extract the given archive to the given directory
                    try archive.extractFiles(to: toDirectory, overwrite: true, progress: nil);
                }
                    // If there is an error...
                catch let error as NSError {
                    // Print the errors description
                    print("KMFileUtilities: Error extracting RAR archive, \(error.description)");
                }
            }
        }
        // If we did already extract it...
        else {
            // Print to the log that it is already extracted
            print("KMFileUtilities: Already extracted \"" + archiveDirectory + "\" to \"" + toDirectory + "\"");
        }
    }
}
