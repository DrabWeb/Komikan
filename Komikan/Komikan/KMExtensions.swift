//
//  KMExtensions.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//

import Cocoa

extension NSWindow {
    /// Is the window fullscreen?
    func isFullscreen() -> Bool {
        // Return if the window's style mask contains NSFullScreenWindowMask
        return self.styleMask.contains(NSFullScreenWindowMask);
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
    func occurenceCountOf(_ string : String) -> Int {
        /// How many times the passed element occured in the array
        var occurenceCount : Int = 0;
        
        // If the first element in the array is not a string...
        if((self[0] as? String) == nil) {
            // Tell the developer that this is not the right kind of array
            print("KMExtensions(Array): Unsupported array \"" + String(describing: self) + "\"");
            
            // Return 0
            return 0;
        }
        
        // For every element in this array...
        for(_, currentString) in self.enumerated() {
            // If the current string is equal to the string we are trying to search for...
            if((currentString as? String) == string) {
                // Add 1 to the occurence count
                occurenceCount += 1;
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
        for(_, currentItem) in self.enumerated() {
            // Add the current item witha ", " on the end to the created string
            createdString += String(describing: currentItem) + ", ";
        }
        
        // Remove the last ", "
        createdString = createdString.substring(to: createdString.index(before: createdString.characters.index(before: createdString.endIndex)));
        
        // Return the string
        return createdString;
    }
}

extension Sequence where Iterator.Element: Hashable {
    /// Returns the frequency of each element in the array, sorted by count
    func frequencies() -> [(Iterator.Element,Int)] {
        // Credits to http://stackoverflow.com/questions/27611744/most-common-array-elements-swift
        
        var frequency: [Iterator.Element:Int] = [:]
        
        for x in self {
            frequency[x] = (frequency[x] ?? 0) + 1
        }
        
        return frequency.sorted { $0.1 > $1.1 }
    }
}

extension Date {
    /// Is this date equal to the beginning of the UNIX epoch?
    func isBeginningOfEpoch() -> Bool {
        // Return if this date equals the beginning of the UNIX epoch
        return self == Date(timeIntervalSince1970: TimeInterval(0));
    }
}

extension Int {
    static func fromBool(bool : Bool) -> Int {
        return bool ? 1 : 0;
    }
}
