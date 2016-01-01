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
        for currentItem in fileNameSplitAtDot.enumerate() {
            // Append the current value onto fileName
            fileName += currentItem.element;
        }
        
        // Return file name
        return fileName;
    }
}