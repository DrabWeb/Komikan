//
//  KMEnums.swift
//  Komikan
//
//  Created by Seth on 2016-01-17.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

// Used to describe how to sort the manga grid
enum KMMangaGridSortType {
    // Sorts by series
    case Series
    
    // Sorts by artist
    case Artist
    
    // Sorts by title
    case Title
}

// Used to tell what direction we are reading
enum KMDualPageDirection {
    // Right to Left(The right way)
    case RightToLeft
    
    // Left to Right(Just in case you need it)
    case LeftToRight
}

/// Different types of Manga properties
enum KMPropertyType {
    case Series
    case Artist
    case Writer
    case Tags
    case Group
}

class KMEnumUtilities {
    /// Turns the passed KMPropertyType into a string
    func propertyTypeToString(type : KMPropertyType) -> String {
        /// The string we will return at the end that says what the property type's name is
        var typeString : String = "";
        
        // Switch on the type we want to get the name of(This doesnt need to be commented)
        switch(type) {
            case KMPropertyType.Series:
                typeString = "Series";
                break;
            case KMPropertyType.Artist:
                typeString = "Artist";
                break;
            case KMPropertyType.Writer:
                typeString = "Writer";
                break;
            case KMPropertyType.Tags:
                typeString = "Tag";
                break;
            case KMPropertyType.Group:
                typeString = "Group";
                break;
        }
        
        // Return the type string
        return typeString;
    }
}

/// The types of lists on MyAnimeList
enum KMMALListType {
    case All
    case CurrentlyReading
    case Completed
    case OnHold
    case Dropped
    case PlanToRead
}