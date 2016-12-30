//
//  KMPreferencesObject.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
//

import Cocoa

class KMPreferencesObject: NSObject, NSCoding {
    // Do we have l-lewd... mode enabled?
    var llewdModeEnabled : Bool = false;
    
    // Should we delete a manga when its downloaded from EH and we remove it from the grid?
    var deleteLLewdMangaWhenRemovingFromTheGrid : Bool = false;
    
    // Should we mark a Manga as read when you finish it in the reader?
    var markAsReadWhenCompletedInReader : Bool = true;
    
    // Should we hide the cursor in distraction free mode?
    var hideCursorInDistractionFreeMode : Bool = false;
    
    /// How much should Distraction Free mode dim the background?
    var distractionFreeModeDimAmount : Double = 0.4;
    
    /// Should the user be allowed to drag the reader window by the backround without holding alt?
    var dragReaderWindowByBackgroundWithoutHoldingAlt : Bool = true;
    
    /// The scale of the manga grid
    var mangaGridScale : Int = 300;
    
    /// If a page filename matches this regex, it will be ignored
    var pageIgnoreRegex : String = "";
    
    /// The background color for the reader window
    var readerWindowBackgroundColor : NSColor = NSColor.black;
    
    /// The default screen to show at launch(0 is grid, 1 is list and 2 is groups)
    var defaultScreen : Int = 0;
    
    
    func encode(with coder: NSCoder) {
        // Encode the preferences
        coder.encode(llewdModeEnabled, forKey: "llewdModeEnabled");
        coder.encode(deleteLLewdMangaWhenRemovingFromTheGrid, forKey: "deleteLLewdMangaWhenRemovingFromTheGrid");
        coder.encode(markAsReadWhenCompletedInReader, forKey: "markAsReadWhenCompletedInReader");
        coder.encode(hideCursorInDistractionFreeMode, forKey: "hideCursorInDistractionFreeMode");
        coder.encode(distractionFreeModeDimAmount, forKey: "distractionFreeModeDimAmount");
        coder.encode(dragReaderWindowByBackgroundWithoutHoldingAlt, forKey: "dragReaderWindowByBackgroundWithoutHoldingAlt");
        coder.encode(mangaGridScale, forKey: "mangaGridScale");
        coder.encode(pageIgnoreRegex, forKey: "pageIgnoreRegex");
        coder.encode(readerWindowBackgroundColor, forKey: "readerWindowBackgroundColor");
        coder.encode(defaultScreen, forKey: "defaultScreen");
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init();
        
        // Decode and load the preferences
        self.llewdModeEnabled = decoder.decodeBool(forKey: "llewdModeEnabled");
        self.deleteLLewdMangaWhenRemovingFromTheGrid = decoder.decodeBool(forKey: "deleteLLewdMangaWhenRemovingFromTheGrid");
        self.markAsReadWhenCompletedInReader = decoder.decodeBool(forKey: "markAsReadWhenCompletedInReader");
        self.hideCursorInDistractionFreeMode = decoder.decodeBool(forKey: "hideCursorInDistractionFreeMode");
        self.distractionFreeModeDimAmount = decoder.decodeDouble(forKey: "distractionFreeModeDimAmount");
        self.dragReaderWindowByBackgroundWithoutHoldingAlt = decoder.decodeBool(forKey: "dragReaderWindowByBackgroundWithoutHoldingAlt");
        self.mangaGridScale = decoder.decodeInteger(forKey: "mangaGridScale");
        self.pageIgnoreRegex = (decoder.decodeObject(forKey: "pageIgnoreRegex") as? String) ?? "";
        self.readerWindowBackgroundColor = (decoder.decodeObject(forKey: "readerWindowBackgroundColor") as? NSColor) ?? NSColor.black;
        self.defaultScreen = decoder.decodeInteger(forKey: "defaultScreen");
    }
}
