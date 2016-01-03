//
//  KMManga.swift
//  Komikan
//
//  Created by Seth on 2016-01-03.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

// A class for holding information about a manga
class KMManga {
    // The cover image for this manga
    var coverImage : NSImage = NSImage(named: "NSCaution")!;
    
    // An array of NSImages that hold all the pages of this manga
    var pages : [NSImage] = [NSImage()];
    
    // The title of this manga
    var title : String = "Failed to load title";
    
    // The series this manga belongs to
    var series : String = "Failed to load series";
    
    // The artist(s) of this manga
    var artist : String = "Failed to load artist";
    
    // The person(s) who wrote this manga
    var writer : String = "Failed to load writer";
    
    // The directory of this mangas CBZ/CBR
    var directory : String = ""
    
    // The unique identifier for this mangas /tmp/ folder
    var tmpDirectory : String = "/tmp/komikan/komikanmanga-";
    
    // The current page we have open
    var currentPage : Int = 0;
    
    // The amount of pages for this manga
    var pageCount : Int = 0;
    
    // All the bookmarks for this manga(Each array element is a bookmarked page)
    var bookmarks : [Int]! = [];
}