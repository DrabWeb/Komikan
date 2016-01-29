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
    func getFileNameWithoutExtension(fileURL : NSURL) -> String {
        // Get the files last path component (The files name with a file extension)
        var fileName : String = fileURL.lastPathComponent!;
        
        // Split the filename at every dot
        var fileNameSplitAtDot : [String] = fileName.componentsSeparatedByString(".");
        
        // Remove the last item(The file extension) from fileNameSplitAtDot
        fileNameSplitAtDot.removeLast();
        
        // Reset file name
        fileName = "";
        
        // Iterate through fileNameSplitAtDot
        for (currentIndex, currentItem) in fileNameSplitAtDot.enumerate() {
            // If this isnt the last item...
            if(currentIndex < fileNameSplitAtDot.count - 1) {
                // Append the current value onto fileName, with a dot
                fileName += (currentItem + ".");
            }
            else {
                // Append the current value onto fileName
                fileName += currentItem;
            }
        }
        
        // Return file name
        return fileName;
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