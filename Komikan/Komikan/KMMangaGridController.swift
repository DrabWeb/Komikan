//
//  KMMangaGridController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridController: NSObject {
    @IBOutlet weak var arrayController : NSArrayController!;
    
    var coverImages : NSMutableArray = NSMutableArray();
    
    override func awakeFromNib() {
        for _ in 1...100 {
            let newCoverImage : KMMangaGridItem = KMMangaGridItem();
            newCoverImage.coverImage = NSImage(named: "NSUser")!;
            arrayController.addObject(newCoverImage);
        }
    }
}