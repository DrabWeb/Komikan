//
//  KMPreferencesKeeper.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
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
    
    /// Should the user be allowed to drag the reader window by the backround without holding alt?
    var dragReaderWindowByBackgroundWithoutHoldingAlt : Bool = true;
    
    /// The scale of the manga grid
    var mangaGridScale : Int = 300;
    
    /// If a page filename matches this regex, it will be ignored
    var pageIgnoreRegex : String = "";
    
    /// The background color for the reader window
    var readerWindowBackgroundColor : NSColor = NSColor.blackColor();
    
    /// The default screen to show at launch(0 is grid, 1 is list and 2 is groups)
    var defaultScreen : Int = 0;
}
