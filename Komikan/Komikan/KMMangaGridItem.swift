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
    
    // The author for the manga, used for sorting
    var writer : String = "";
    
    // The artist for the manga, used for sorting
    var artist : String = "";
    
    // The percentage the user is done this manga, used for sorting
    var percentFinished : Int = 0;
    
    // Is this manga a favourite? Used for sorting
    var favourite : Bool = false;
    
    /// The alpha amount of the collection item to say how finished this manga you are
    var percentAlpha : CGFloat = 1;
    
    // The manga that this grid item represents
    var manga : KMManga = KMManga();
    
    // Updates the grid item with the passed mangas info
    func changeManga(newManga : KMManga) {
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
        
        // Set the percent finished to the mangas percent finished
        percentFinished = manga.percentFinished;
        
        // Set if this manga is a favourite to the mangas favourite value
        favourite = manga.favourite;
        
        // Set the percent alpha (It does 1 minus the percent done / 100(Eg. 75% would be 0.75) and then adds 0.3 to it so it isnt fully transparent)
        percentAlpha = (1.0 - CGFloat(manga.percentFinished) / 100.0) + 0.3;
        
        // If this manga is read...
        if(manga.read) {
            // Set the alpha percent to 0.5
            percentAlpha = 0.5;
        }
        
        // Print that we are changing manga info
        print("Loaded / Changed \"" + title + "\"");
    }
    
    func encodeWithCoder(coder: NSCoder) {
        // Encode the mangas values
        // The image must be saved as NSData
        coder.encodeObject(self.manga.coverImage.TIFFRepresentation, forKey: "manga.coverImage");
        
        coder.encodeObject(self.manga.title, forKey: "manga.title");
        coder.encodeObject(self.manga.series, forKey: "manga.series");
        coder.encodeObject(self.manga.artist, forKey: "manga.artist");
        coder.encodeObject(self.manga.writer, forKey: "manga.writer");
        coder.encodeObject(self.manga.directory, forKey: "manga.directory");
        coder.encodeObject(self.manga.bookmarks, forKey: "manga.bookmarks");
        coder.encodeObject(self.manga.currentPage, forKey: "manga.currentPage");
        coder.encodeObject(self.manga.tags, forKey: "manga.tags");
        coder.encodeObject(self.manga.read, forKey: "manga.read");
        coder.encodeObject(self.manga.uuid, forKey: "manga.uuid");
        coder.encodeObject(self.manga.lewd, forKey: "manga.lewd");
        coder.encodeObject(self.manga.group, forKey: "manga.group");
        coder.encodeObject(self.manga.favourite, forKey: "manga.favourite");
        
        coder.encodeObject(self.manga.saturation, forKey: "manga.saturation");
        coder.encodeObject(self.manga.brightness, forKey: "manga.brightness");
        coder.encodeObject(self.manga.contrast, forKey: "manga.contrast");
        coder.encodeObject(self.manga.sharpness, forKey: "manga.sharpness");
        
        coder.encodeObject(self.manga.pageCount, forKey: "manga.pageCount");
        
        coder.encodeObject(self.manga.percentFinished, forKey: "manga.percentFinished");
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        // Decode and laod the mangas values
        // Convert the data to an image
        self.manga.coverImage = NSImage(data: (decoder.decodeObjectForKey("manga.coverImage") as! NSData?)!)!;
        
        self.manga.title = (decoder.decodeObjectForKey("manga.title") as! String?)!;
        self.manga.series = (decoder.decodeObjectForKey("manga.series") as! String?)!;
        self.manga.artist = (decoder.decodeObjectForKey("manga.artist") as! String?)!;
        self.manga.writer = (decoder.decodeObjectForKey("manga.writer") as! String?)!;
        self.manga.directory = (decoder.decodeObjectForKey("manga.directory") as! String?)!;
        self.manga.bookmarks = (decoder.decodeObjectForKey("manga.bookmarks") as! [Int]?)!;
        self.manga.currentPage = (decoder.decodeObjectForKey("manga.currentPage") as! Int?)!;
        self.manga.tags = (decoder.decodeObjectForKey("manga.tags") as! [String]?)!;
        
        // I need to stop breaking the app... This should help
        if((decoder.decodeObjectForKey("manga.read") as? Bool) != nil) {
            self.manga.read = (decoder.decodeObjectForKey("manga.read") as! Bool?)!;
        }
        
        // Same here, if there is a UUID...
        if((decoder.decodeObjectForKey("manga.uuid") as? String) != nil) {
            // Load it
            self.manga.uuid = (decoder.decodeObjectForKey("manga.uuid") as! String?)!;
        }
        
        // If there is a saturation value...
        if((decoder.decodeObjectForKey("manga.saturation") as? CGFloat) != nil) {
            // Load it
            self.manga.saturation = (decoder.decodeObjectForKey("manga.saturation") as! CGFloat?)!;
        }
        
        // If there is a brightness value...
        if((decoder.decodeObjectForKey("manga.brightness") as? CGFloat) != nil) {
            // Load it
            self.manga.brightness = (decoder.decodeObjectForKey("manga.brightness") as! CGFloat?)!;
        }
        
        // If there is a contrast value...
        if((decoder.decodeObjectForKey("manga.contrast") as? CGFloat) != nil) {
            // Load it
            self.manga.contrast = (decoder.decodeObjectForKey("manga.contrast") as! CGFloat?)!;
        }
        
        // If there is a sharpness value...
        if((decoder.decodeObjectForKey("manga.sharpness") as? CGFloat) != nil) {
            // Load it
            self.manga.sharpness = (decoder.decodeObjectForKey("manga.sharpness") as! CGFloat?)!;
        }
        
        // If there is a pageCount value...
        if((decoder.decodeObjectForKey("manga.pageCount") as? Int) != nil) {
            // Load it
            self.manga.pageCount = (decoder.decodeObjectForKey("manga.pageCount") as! Int?)!;
        }
        
        // If there is a percentFinished value...
        if((decoder.decodeObjectForKey("manga.percentFinished") as? Int) != nil) {
            // Load it
            self.manga.percentFinished = (decoder.decodeObjectForKey("manga.percentFinished") as! Int?)!;
        }
        
        // If there is a l-lewd... value...
        if((decoder.decodeObjectForKey("manga.lewd") as? Bool) != nil) {
            // Load it
            self.manga.lewd = (decoder.decodeObjectForKey("manga.lewd") as! Bool?)!;
        }
        
        // If there is a group value...
        if((decoder.decodeObjectForKey("manga.group") as? String) != nil) {
            // Load it
            self.manga.group = (decoder.decodeObjectForKey("manga.group") as! String?)!;
        }
        
        // If there is a favourite value...
        if((decoder.decodeObjectForKey("manga.favourite") as? Bool) != nil) {
            // Load it
            self.manga.favourite = (decoder.decodeObjectForKey("manga.favourite") as! Bool?)!;
        }
        
        // Load up the manga info
        changeManga(self.manga);
    }
}