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
    
    // The manga that this grid item represents
    var manga : KMManga = KMManga();
    
    // Updates the grid item with the passed mangas info
    func changeManga(newManga : KMManga) {
        // Print that we are changing manga info
        print("Changing \"" + title + "\" info");
        
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
        
        // Set the title
        self.title = manga.title;
        
        // Set the cover image
        self.coverImage = manga.coverImage;
    }
}