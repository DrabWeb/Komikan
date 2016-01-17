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