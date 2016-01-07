//
//  KMMangaGridItem.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridItem: NSObject {
    // The cover image for this grid item
    var coverImage : NSImage = NSImage(named: "NSCaution")!;
    
    // The title for the manga
    var title : String = "Failed to load title";
    
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
    }
}