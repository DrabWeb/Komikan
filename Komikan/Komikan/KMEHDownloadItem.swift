//
//  File.swift
//  Komikan
//
//  Created by Seth on 2016-01-28.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMEHDownloadItem {
    // The URL to the manga on E-Hentai or ExHentai
    var url : String = "";
    
    // Should we download this item with the Japanese title?
    var useJapaneseTitle : Bool = true;
    
    // Is this manga on ExHentai?
    var onExHentai : Bool = false;
    
    // This items manga
    var manga : KMManga = KMManga();
    
    // Init for just a URL
    init(url : String) {
        self.url = url;
    }
    
    // Init for a URL and if we want to use the Japanese title
    init(url : String, useJapaneseTitle : Bool) {
        self.url = url;
        self.useJapaneseTitle = useJapaneseTitle;
    }
    
    // Init for a URL, use Japanese title and on ExHentai
    init(url : String, useJapaneseTitle : Bool, onExHentai : Bool) {
        self.url = url;
        self.useJapaneseTitle = useJapaneseTitle;
        self.onExHentai = onExHentai;
    }
}