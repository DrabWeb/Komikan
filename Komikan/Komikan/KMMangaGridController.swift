//
//  KMMangaGridController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridController: NSObject {
    // The array controller for the collection view
    @IBOutlet weak var arrayController : NSArrayController!;
    
    // An array to store all of the coverImages we are displaying in the collection view
    var coverImages : NSMutableArray = NSMutableArray();
    
    override func awakeFromNib() {
        // Load 100 pictures of the example manga cover and the title "Ushio Diary" to the collection view
        for _ in 1...100 {
            let newCoverImage : KMMangaGridItem = KMMangaGridItem();
            newCoverImage.coverImage = NSImage(named: "example-cover")!;
            newCoverImage.title = "Ushio Diary"
            arrayController.addObject(newCoverImage);
        }
    }
}