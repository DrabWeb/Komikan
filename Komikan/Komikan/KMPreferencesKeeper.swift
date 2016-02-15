//
//  KMPreferencesKeeper.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMPreferencesKeeper {
    // Do we have l-lewd... mode enabled?
    var llewdModeEnabled : Bool = false;
    
    // Should we delete a manga when its downloaded from EH and we remove it from the grid?
    var deleteLLewdMangaWhenRemovingFromTheGrid : Bool = false;
    
    // Should we mark a Manga as read when you finish it in the reader?
    var markAsReadWhenCompletedInReader : Bool = true;
    
    // Should we hide the cursor in distraction free mode?
    var hideCursorInDistractionFreeMode : Bool = false;
    
    /// How much should Distraction Free mode dim the background?
    var distractionFreeModeDimAmount : CGFloat = 0.4;
}
