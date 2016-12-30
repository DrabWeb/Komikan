//
//  KMEnums.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//

import Cocoa

// Used to describe how to sort the manga grid
enum KMMangaGridSortType : Int {
    // Sorts by series
    case series
    
    // Sorts by artist
    case artist
    
    // Sorts by title
    case title
}

// Used to tell what direction we are reading
enum KMDualPageDirection {
    // Right to Left(The right way)
    case rightToLeft
    
    // Left to Right(Just in case you need it)
    case leftToRight
}

/// Different types of Manga properties
enum KMPropertyType {
    case series
    case artist
    case writer
    case tags
    case group
}

class KMEnumUtilities {
    /// Turns the passed KMPropertyType into a string
    func propertyTypeToString(_ type : KMPropertyType) -> String {
        /// The string we will return at the end that says what the property type's name is
        var typeString : String = "";
        
        // Switch on the type we want to get the name of(This doesnt need to be commented)
        switch(type) {
            case KMPropertyType.series:
                typeString = "Series";
                break;
            case KMPropertyType.artist:
                typeString = "Artist";
                break;
            case KMPropertyType.writer:
                typeString = "Writer";
                break;
            case KMPropertyType.tags:
                typeString = "Tag";
                break;
            case KMPropertyType.group:
                typeString = "Group";
                break;
        }
        
        // Return the type string
        return typeString;
    }
}

/// The types of lists on MyAnimeList
enum KMMALListType {
    case all
    case currentlyReading
    case completed
    case onHold
    case dropped
    case planToRead
}
