//
//  KMMangaGridItem.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridItem: NSObject, NSCoding {
    // The cover image for this grid item
    var coverImage : NSImage = NSImage(named: "NSCaution")!;
    
    // The title for the manga
    var title : String = "Failed to load title";
    
    // The series for the manga, used for sorting
    var series : String = "";
    
    // The artist for the manga, used for sorting
    var artist : String = "";
    
    // The author for the manga, used for sorting
    var writer : String = "";
    
    // The group for the manga, used for sorting
    var group : String = "";
    
    // The percentage the user is done this manga, used for sorting
    var percentFinished : Int = 0;
    
    // Is this manga a favourite? Used for sorting
    var favourite : Bool = false;
    
    // Is this manga l-lewd...? Used for sorting
    var lewd : Bool = false;
    
    /// The alpha amount of the collection item to say how finished this manga you are
    var percentAlpha : CGFloat = 1;
    
    // The manga that this grid item represents
    var manga : KMManga = KMManga();
    
    // Updates the grid item with the passed mangas info
    func changeManga(_ newManga : KMManga) {
        // Set manga to newManga
        manga = newManga;
        
        // Set the over image to the mangas cover image
        coverImage = manga.coverImage;
        
        // Set the title to the mangas title
        title = manga.title;
        
        // Set the series to the mangas series
        series = manga.series;
        
        // Set the artist to the mangas artist
        artist = manga.artist;
        
        // Set the author to the mangas author
        writer = manga.writer;
        
        // Set the group to the mangas group
        group = manga.group;
        
        // Set l-lewd... to if this manga is l-lewd...
        lewd = manga.lewd;
        
        // Set the percent finished to the mangas percent finished
        percentFinished = manga.percentFinished;
        
        // Set if this manga is a favourite to the mangas favourite value
        favourite = manga.favourite;
        
        // Set the percent alpha (It does 1 minus the percent done / 100(Eg. 75% would be 0.75) and then adds 0.3 to it so it isnt fully transparent)
        percentAlpha = (1.0 - CGFloat(manga.percentFinished) / 100.0) + 0.3;
        
        // Print that we are changing manga info
        print("KMMangaGridItem: Loaded / Changed \"" + title + "\"");
    }
    
    public func encode(with aCoder: NSCoder) {
        // Encode the mangas values
        // The image must be saved as NSData
        aCoder.encode(self.manga.coverImage.tiffRepresentation, forKey: "manga.coverImage");
        
        aCoder.encode(self.manga.title, forKey: "manga.title");
        aCoder.encode(self.manga.series, forKey: "manga.series");
        aCoder.encode(self.manga.artist, forKey: "manga.artist");
        aCoder.encode(self.manga.writer, forKey: "manga.writer");
        aCoder.encode(self.manga.directory, forKey: "manga.directory");
        aCoder.encode(self.manga.bookmarks, forKey: "manga.bookmarks");
        aCoder.encode(self.manga.currentPage, forKey: "manga.currentPage");
        aCoder.encode(self.manga.tags, forKey: "manga.tags");
        aCoder.encode(self.manga.read, forKey: "manga.read");
        aCoder.encode(self.manga.uuid, forKey: "manga.uuid");
        aCoder.encode(self.manga.lewd, forKey: "manga.lewd");
        aCoder.encode(self.manga.group, forKey: "manga.group");
        aCoder.encode(self.manga.favourite, forKey: "manga.favourite");
        aCoder.encode(self.manga.releaseDate, forKey: "manga.releaseDate");
        
        aCoder.encode(self.manga.saturation, forKey: "manga.saturation");
        aCoder.encode(self.manga.brightness, forKey: "manga.brightness");
        aCoder.encode(self.manga.contrast, forKey: "manga.contrast");
        aCoder.encode(self.manga.sharpness, forKey: "manga.sharpness");
        
        aCoder.encode(self.manga.pageCount, forKey: "manga.pageCount");
        
        aCoder.encode(self.manga.percentFinished, forKey: "manga.percentFinished");
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init();
        
        // Decode and load the manga's values
        
        // If the user's manga database is still on <=v1.2.2...
        if((aDecoder.decodeObject(forKey: "manga.currentPage") as! Int?) != nil) {
            // Convert the data to an image
            self.manga.coverImage = NSImage(data: (aDecoder.decodeObject(forKey: "manga.coverImage") as! Data?)!)!;
            
            self.manga.title = (aDecoder.decodeObject(forKey: "manga.title") as! String?)!;
            self.manga.series = (aDecoder.decodeObject(forKey: "manga.series") as! String?)!;
            self.manga.artist = (aDecoder.decodeObject(forKey: "manga.artist") as! String?)!;
            self.manga.writer = (aDecoder.decodeObject(forKey: "manga.writer") as! String?)!;
            self.manga.directory = (aDecoder.decodeObject(forKey: "manga.directory") as! String?)!;
            self.manga.bookmarks = (aDecoder.decodeObject(forKey: "manga.bookmarks") as! [Int]?)!;
            self.manga.currentPage = (aDecoder.decodeObject(forKey: "manga.currentPage") as! Int?)!;
            self.manga.tags = (aDecoder.decodeObject(forKey: "manga.tags") as! [String]?)!;
            
            // I need to stop breaking the app... This should help
            if((aDecoder.decodeObject(forKey: "manga.read") as? Bool) != nil) {
                self.manga.read = (aDecoder.decodeObject(forKey: "manga.read") as! Bool?)!;
            }
            
            // Same here, if there is a UUID...
            if((aDecoder.decodeObject(forKey: "manga.uuid") as? String) != nil) {
                // Load it
                self.manga.uuid = (aDecoder.decodeObject(forKey: "manga.uuid") as! String?)!;
            }
            
            // If there is a saturation value...
            if((aDecoder.decodeObject(forKey: "manga.saturation") as? CGFloat) != nil) {
                // Load it
                self.manga.saturation = (aDecoder.decodeObject(forKey: "manga.saturation") as! CGFloat?)!;
            }
            
            // If there is a brightness value...
            if((aDecoder.decodeObject(forKey: "manga.brightness") as? CGFloat) != nil) {
                // Load it
                self.manga.brightness = (aDecoder.decodeObject(forKey: "manga.brightness") as! CGFloat?)!;
            }
            
            // If there is a contrast value...
            if((aDecoder.decodeObject(forKey: "manga.contrast") as? CGFloat) != nil) {
                // Load it
                self.manga.contrast = (aDecoder.decodeObject(forKey: "manga.contrast") as! CGFloat?)!;
            }
            
            // If there is a sharpness value...
            if((aDecoder.decodeObject(forKey: "manga.sharpness") as? CGFloat) != nil) {
                // Load it
                self.manga.sharpness = (aDecoder.decodeObject(forKey: "manga.sharpness") as! CGFloat?)!;
            }
            
            // If there is a pageCount value...
            if((aDecoder.decodeObject(forKey: "manga.pageCount") as? Int) != nil) {
                // Load it
                self.manga.pageCount = (aDecoder.decodeObject(forKey: "manga.pageCount") as! Int?)!;
            }
            
            // If there is a percentFinished value...
            if((aDecoder.decodeObject(forKey: "manga.percentFinished") as? Int) != nil) {
                // Load it
                self.manga.percentFinished = (aDecoder.decodeObject(forKey: "manga.percentFinished") as! Int?)!;
            }
            
            // If there is a l-lewd... value...
            if((aDecoder.decodeObject(forKey: "manga.lewd") as? Bool) != nil) {
                // Load it
                self.manga.lewd = (aDecoder.decodeObject(forKey: "manga.lewd") as! Bool?)!;
            }
            
            // If there is a group value...
            if((aDecoder.decodeObject(forKey: "manga.group") as? String) != nil) {
                // Load it
                self.manga.group = (aDecoder.decodeObject(forKey: "manga.group") as! String?)!;
            }
            
            // If there is a favourite value...
            if((aDecoder.decodeObject(forKey: "manga.favourite") as? Bool) != nil) {
                // Load it
                self.manga.favourite = (aDecoder.decodeObject(forKey: "manga.favourite") as! Bool?)!;
            }
            
            // If there is a release date value...
            if((aDecoder.decodeObject(forKey: "manga.releaseDate") as? NSDate) != nil) {
                // Load it
                self.manga.releaseDate = (aDecoder.decodeObject(forKey: "manga.releaseDate") as! Date?)!;
            }
        }
        // If the user's manga database is on >=v.1.2.3...
        else {
            // Convert the data to an image
            self.manga.coverImage = NSImage(data: (aDecoder.decodeObject(forKey: "manga.coverImage") as! NSData?)! as Data)!;
            
            self.manga.title = (aDecoder.decodeObject(forKey: "manga.title") as! String?)!;
            self.manga.series = (aDecoder.decodeObject(forKey: "manga.series") as! String?)!;
            self.manga.artist = (aDecoder.decodeObject(forKey: "manga.artist") as! String?)!;
            self.manga.writer = (aDecoder.decodeObject(forKey: "manga.writer") as! String?)!;
            self.manga.directory = (aDecoder.decodeObject(forKey: "manga.directory") as! String?)!;
            self.manga.bookmarks = (aDecoder.decodeObject(forKey: "manga.bookmarks") as! [Int]?)!;
            self.manga.currentPage = aDecoder.decodeInteger(forKey: "manga.currentPage");
            self.manga.tags = (aDecoder.decodeObject(forKey: "manga.tags") as! [String]?)!;
            
            self.manga.read = aDecoder.decodeBool(forKey: "manga.read");
            self.manga.pageCount = aDecoder.decodeInteger(forKey: "manga.pageCount");
            self.manga.percentFinished = aDecoder.decodeInteger(forKey: "manga.percentFinished");
            self.manga.lewd = aDecoder.decodeBool(forKey: "manga.lewd");
            self.manga.favourite = aDecoder.decodeBool(forKey: "manga.favourite");
            
            if(aDecoder.containsValue(forKey: "manga.uuid")) {
                self.manga.uuid = (aDecoder.decodeObject(forKey: "manga.uuid") as! String?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.saturation")) {
                self.manga.saturation = (aDecoder.decodeObject(forKey: "manga.saturation") as! CGFloat?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.brightness")) {
                self.manga.brightness = (aDecoder.decodeObject(forKey: "manga.brightness") as! CGFloat?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.contrast")) {
                self.manga.contrast = (aDecoder.decodeObject(forKey: "manga.contrast") as! CGFloat?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.sharpness")) {
                self.manga.sharpness = (aDecoder.decodeObject(forKey: "manga.sharpness") as! CGFloat?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.group")) {
                self.manga.group = (aDecoder.decodeObject(forKey: "manga.group") as! String?)!;
            }
            
            if(aDecoder.containsValue(forKey: "manga.releaseDate")) {
                // Load it
                self.manga.releaseDate = (aDecoder.decodeObject(forKey: "manga.releaseDate") as! Date?)!;
            }
        }
        
        // Load up the manga info
        changeManga(self.manga);
    }
    
    override init() {
        super.init();
        
        self.coverImage = NSImage(named: "NSCaution")!;
        self.title = "Failed to load title";
        self.series = "";
        self.artist = "";
        self.writer = "";
        self.group = "";
        self.percentFinished = 0;
        self.favourite = false;
        self.lewd = false;
        self.percentAlpha = 1;
        self.manga = KMManga();
    }
}
