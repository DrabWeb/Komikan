//
//  KMMetadataFetcherSeriesSearchResultsTableViewCell.swift
//  Komikan
//
//  Created by Seth on 2016-02-28.
//

import Cocoa

class KMMetadataFetcherSeriesSearchResultsTableViewCell: NSTableCellView {

    /// The arrow button that lets the user select this series
    @IBOutlet var selectButton: NSButton!
    
    /// The KMMetadataFetcherSeriesSearchResultsItemData of this search result item
    var data : KMMetadataFetcherSeriesSearchResultsItemData = KMMetadataFetcherSeriesSearchResultsItemData();
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
