//
//  KMMetadataFetcherSeriesSearchResultsItemData.swift
//  Komikan
//
//  Created by Seth on 2016-02-28.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMetadataFetcherSeriesSearchResultsItemData: NSObject {
    /// The name of the series
    var seriesName : String = "";
    
    /// The MU ID of this series
    var seriesId : Int = -1;
    
    // Blank init
    override init() {
        seriesName = "";
        seriesId = -1;
    }
    
    // Init with a series name
    init(seriesName : String) {
        self.seriesName = seriesName;
    }
    
    // Init with a series ID
    init(seriesId : Int) {
        self.seriesId = seriesId;
    }
    
    // Init with a series name and ID
    init(seriesName : String, seriesId : Int) {
        self.seriesName = seriesName;
        self.seriesId = seriesId;
    }
}
