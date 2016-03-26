//
//  KMExtensions.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

extension NSWindow {
    /// Is the window fullscreen?
    func isFullscreen() -> Bool {
        // Return true/false depending on if the windows style mask contains NSFullScreenWindowMask(Im not actually sure what the & operation does or how it works, but I like it)
        return ((self.styleMask & NSFullScreenWindowMask) > 0);
    }
}

extension String {
    /// Converts the string to a bool
    func toBool() -> Bool {
        /// The boolean we will return at the end of the function
        var boolean : Bool = false;
        
        // If this string is either "y", "t", "yes" or "true"...
        if(self == "y" || self == "t" || self == "yes" || self == "true") {
            // Set the boolean to true
            boolean = true;
        }
        // If this string is either "n", "f", "no" or "false"...
        else if(self == "n" || self == "f" || self == "no" || self == "false") {
            // Set the boolean to false
            boolean = false;
        }
        
        // Return boolean
        return boolean;
    }
}

extension Array {
    /// Returns how many times the given string occurs in the array(Only works with [String])
    func occurenceCountOf(string : String) -> Int {
        /// How many times the passed element occured in the array
        var occurenceCount : Int = 0;
        
        // If the first element in the array is not a string...
        if((self[0] as? String) == nil) {
            // Tell the developer that this is not the right kind of array
            print("Unsupported array \"" + String(self) + "\"");
            
            // Return 0
            return 0;
        }
        
        // For every element in this array...
        for(_, currentString) in self.enumerate() {
            // If the current string is equal to the string we are trying to search for...
            if((currentString as? String) == string) {
                // Add 1 to the occurence count
                occurenceCount++;
            }
        }
        
        // Return the occurence count
        return occurenceCount;
    }
    
    /// Returns this array as a string where each element is listed with a ", " in between
    func listString() -> String {
        /// The string we will return at the end
        var createdString : String = "";
        
        // For every item in this array...
        for(_, currentItem) in self.enumerate() {
            // Add the current item witha ", " on the end to the created string
            createdString += String(currentItem) + ", ";
        }
        
        // Remove the last ", "
        createdString = createdString.substringToIndex(createdString.endIndex.predecessor().predecessor());
        
        // Return the string
        return createdString;
    }
}

extension SequenceType where Generator.Element: Hashable {
    /// Returns the frequency of each element in the array, sorted by count
    func frequencies() -> [(Generator.Element,Int)] {
        // Credits to http://stackoverflow.com/questions/27611744/most-common-array-elements-swift
        
        var frequency: [Generator.Element:Int] = [:]
        
        for x in self {
            frequency[x] = (frequency[x] ?? 0) + 1
        }
        
        return frequency.sort { $0.1 > $1.1 }
    }
}

extension NSDate {
    /// Is this date equal to the beginning of the UNIX epoch?
    func isBeginningOfEpoch() -> Bool {
        // Return if this date equals the beginning of the UNIX epoch
        return self == NSDate(timeIntervalSince1970: NSTimeInterval(0));
    }
}