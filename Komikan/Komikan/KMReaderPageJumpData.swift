//
//  KMReaderPageJumpData.swift
//  Komikan
//
//  Created by Seth on 2016-02-22.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

class KMReaderPageJumpData : NSObject {
    /// The NSImage for the leftmost thumbnails image
    var thumbnailOne : NSImage = NSImage();
    
    /// The NSImage for the center thumbnails image
    var thumbnailTwo : NSImage = NSImage();
    
    /// The NSImage for the rightmost thumbnails image
    var thumbnailThree : NSImage = NSImage();
    
    /// The page that will be jumped to when you click on the leftmost thumbnail
    var thumbnailOnePage : Int = -1;
    
    /// The page that will be jumped to when you click on the center thumbnail
    var thumbnailTwoPage : Int = -1;
    
    /// The page that will be jumped to when you click on the rightmost thumbnail
    var thumbnailThreePage : Int = -1;
    
    /// Is the first thumbnail's page bookmarked?
    var thumbnailOneBookmarked : Bool = false;
    
    /// Is the second thumbnail's page bookmarked?
    var thumbnailTwoBookmarked : Bool = false;
    
    /// Is the third thumbnail's page bookmarked?
    var thumbnailThreeBookmarked : Bool = false;
    
    /// Loads the passed array of NSImages into their respective thumbnail slots
    func loadThumbnailsFromArray(thumbnails : [NSImage]) {
        // For every image in the thumbnails array...
        for(currentIndex, currentImage) in thumbnails.enumerate() {
            // If this is the first image...
            if(currentIndex == 0) {
                thumbnailOne = currentImage;
            }
            // If this is the second image...
            else if(currentIndex == 1) {
                thumbnailTwo = currentImage;
            }
            // If this is the third image
            else if(currentIndex == 2) {
                // Set thumbnail three to the current image
                thumbnailThree = currentImage;
            }
        }
    }
    
    /// Loads the page numbers from the passed array of Bools
    func loadPageNumbersFromArray(pages : [Int]) {
        // For every item in the pages array...
        for(currentIndex, currentPageNumber) in pages.enumerate() {
            // If this is the first page number...
            if(currentIndex == 0) {
                // Set the first thumbnails page to the current page
                thumbnailOnePage = currentPageNumber;
            }
            // If this is the second page number...
            else if(currentIndex == 1) {
                // Set the second thumbnails page to the current page
                thumbnailTwoPage = currentPageNumber;
            }
            // If this is the third page number...
            else if(currentIndex == 2) {
                // Set the third thumbnails page to the current page
                thumbnailThreePage = currentPageNumber;
            }
        }
    }
    
    /// Loads the bookmarks from the passed array of Ints
    func loadBookmarksFromArray(bookmarks : [Bool]) {
        // For every item in the bookmarks array...
        for(currentIndex, currentBookmark) in bookmarks.enumerate() {
            // If this is the first bookmark...
            if(currentIndex == 0) {
                // Set the first thumbnails bookmarked value to the current bookmark value
                thumbnailOneBookmarked = !currentBookmark;
            }
            // If this is the second bookmark...
            else if(currentIndex == 1) {
                // Set the second thumbnails bookmarked value to the current bookmark value
                thumbnailTwoBookmarked = !currentBookmark;
            }
            // If this is the third bookmark...
            else if(currentIndex == 2) {
                // Set the third thumbnails bookmarked value to the current bookmark value
                thumbnailThreeBookmarked = !currentBookmark;
            }
        }
    }
    
    // A blank init
    override init() {
        
    }
    
    // Init with one page
    init(thumbOne : NSImage, thumbOnePage : Int, thumbOneBookmarked : Bool) {
        thumbnailOne = thumbOne;
        thumbnailOnePage = thumbOnePage;
        thumbnailOneBookmarked = thumbOneBookmarked;
    }
    
    // Init with two pages
    init(thumbOne : NSImage, thumbOnePage : Int, thumbOneBookmarked : Bool, thumbTwo : NSImage, thumbTwoPage : Int, thumbTwoBookmarked : Bool) {
        thumbnailOne = thumbOne;
        thumbnailOnePage = thumbOnePage;
        thumbnailOneBookmarked = thumbOneBookmarked;
        
        thumbnailTwo = thumbTwo;
        thumbnailTwoPage = thumbTwoPage;
        thumbnailTwoBookmarked = thumbTwoBookmarked;
    }
    
    // Init with three pages
    init(thumbOne : NSImage, thumbOnePage : Int, thumbOneBookmarked : Bool, thumbTwo : NSImage, thumbTwoPage : Int, thumbTwoBookmarked : Bool, thumbThree : NSImage, thumbThreePage : Int, thumbThreeBookmarked : Bool) {
        thumbnailOne = thumbOne;
        thumbnailOnePage = thumbOnePage;
        thumbnailOneBookmarked = thumbOneBookmarked;
        
        thumbnailTwo = thumbTwo;
        thumbnailTwoPage = thumbTwoPage;
        thumbnailTwoBookmarked = thumbTwoBookmarked;
        
        thumbnailThree = thumbThree;
        thumbnailThreePage = thumbThreePage;
        thumbnailThreeBookmarked = thumbThreeBookmarked;
    }
}