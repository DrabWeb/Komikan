//
//  KMReaderScrollView.swift
//  Komikan
//
//  Created by Seth on 2016-02-20.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderScrollView: NSScrollView {
    
    // Make it so we can always receive mouse events
    override var acceptsFirstResponder : Bool {
        return true
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        // Subscribe to the magnify event
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.EventMaskMagnify, handler: magnifyEvent);
    }
    
    func magnifyEvent(event: NSEvent) -> NSEvent {
        // Add the magnification amount to the current magnification amount
        self.magnification = event.magnification + self.magnification;
        
        // Return the event
        return event;
    }
    
    /// The reader view controller we want to flip pages for
    var readerViewController : KMReaderViewController!
    
    /// Flips to the next page
    func nextPage() {
        // Go to the next page
        readerViewController.nextPage();
        
        // Tell the reader view controller to reset the zoom
        readerViewController.resetMagnification();
    }
    
    /// Flips to the previous page
    func previousPage() {
        // Go to the previous page
        readerViewController.previousPage();
        
        // Tell the reader view controller to reset the zoom
        readerViewController.resetMagnification();
    }
    
    /// The swipe cooldown so you cant swipe until the delta X is at 0
    var swipeCooldownOver : Bool = true;
    
    /// For some reason the trackpad when swiping would flip pages twice. This number is used so only every two swipes it will flip pages
    var pageSwipeCount : Int = 0;
    
    // This is called not only when you scroll, but when you swipe the trackpad. This should also work with Magic Mouse(Not tested)
    override func scrollWheel(theEvent: NSEvent) {
        /// Did we flip the page?
        var flippedPages : Bool = false;
        
        // If the delta X is less than 5(Meaning you are swiping left)...
        if(theEvent.deltaX < -5) {
            // If the swipe cooldown is over...
            if(swipeCooldownOver) {
                // Add 1 to the page swipe count
                pageSwipeCount++;
                
                // If the page swipe count is 2...
                if(pageSwipeCount == 2) {
                    // If the horizontal scroll amout is 1...
                    if(self.horizontalScroller?.floatValue == 1) {
                        // Go to the next page
                        nextPage();
                        
                        // Say we flipped pages
                        flippedPages = true;
                    }
                    // If the scroll view is just not magnified...
                    else if(self.magnification == 1) {
                        // Go to the next page
                        nextPage();
                        
                        // Say we flipped pages
                        flippedPages = true;
                    }
                    
                    // Set the page swipe count to 0
                    pageSwipeCount = 0;
                }
            }
            
            // Say the cooldown isnt over
            swipeCooldownOver = false;
        }
            // If the delta X is greater than 5(Meaning you are swiping right)...
        else if(theEvent.deltaX > 5) {
            // If the swipe cooldown is over...
            if(swipeCooldownOver) {
                // Add 1 to the page swipe count
                pageSwipeCount++;
                
                // If the page swipe count is 2...
                if(pageSwipeCount == 2) {
                    // If the horizontal scroll amout is 0...
                    if(self.horizontalScroller?.floatValue == 0) {
                        // Go to the previous page
                        previousPage();
                        
                        // Say we flipped pages
                        flippedPages = true;
                    }
                    // If the scroll view is just not magnified...
                    else if(self.magnification == 1) {
                        // Go to the previous page
                        previousPage();
                        
                        // Say we flipped pages
                        flippedPages = true;
                    }
                    
                    // Set the page swipe count to 0
                    pageSwipeCount = 0;
                }
            }
            
            // Say the swipe cooldown isnt over
            swipeCooldownOver = false;
        }
            // If the trackpad's scroll force on the X is 0...
        else if(theEvent.deltaX == 0) {
            // Say the cooldown is over
            swipeCooldownOver = true;
        }
        
        // If we didnt flip pages...
        if(!flippedPages) {
            // Tell the scroll view to scroll
            super.scrollWheel(theEvent);
        }
    }
}
