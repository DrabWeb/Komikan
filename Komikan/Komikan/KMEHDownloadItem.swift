//
//  File.swift
//  Komikan
//
//  Created by Seth on 2016-01-28.
//

import Foundation

class KMEHDownloadItem {
    /// The URL to the manga on E-Hentai or ExHentai
    var url : String = "";
    
    /// Should we download this item with the Japanese title?
    var useJapaneseTitle : Bool = true;
    
    /// Is this manga on ExHentai?
    var onExHentai : Bool = false;
    
    /// The group to set for the manga when its downloaded(Doesnt touch it if its blank)
    var group : String = "";
    
    /// This items manga
    var manga : KMManga = KMManga();
    
    // Init for just a URL
    init(url : String) {
        self.url = url;
    }
    
    // Init for a URL, if we want to use the Japanese title and a group
    init(url : String, useJapaneseTitle : Bool, group : String) {
        self.url = url;
        self.useJapaneseTitle = useJapaneseTitle;
        self.group = group;
    }
    
    // Init for a URL, use Japanese title, a group and if its on ExHentai
    init(url : String, useJapaneseTitle : Bool, group : String, onExHentai : Bool) {
        self.url = url;
        self.useJapaneseTitle = useJapaneseTitle;
        self.group = group;
        self.onExHentai = onExHentai;
    }
}