//
//  KMReaderViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderViewController: NSViewController {

    // The main window for the reader
    var readerWindow : NSWindow = NSWindow();
    
    // The visual effect view for the reader windows titlebar
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("mouseHoverHandling"), userInfo: nil, repeats:true);
    }
    
    func mouseHoverHandling() {
        if(readerWindow.orderedIndex == 1) {
            var insideWindow : Bool = false;
            
            var ourEvent : CGEventRef = CGEventCreate(nil)!;
            var point = CGEventGetLocation(ourEvent);
            
            var windowFrame : NSRect! = view.window?.frame;
            
            var pointY = abs(point.y - NSScreen.mainScreen()!.frame.height);
            
            if(point.x > windowFrame.origin.x && point.x < windowFrame.origin.x + windowFrame.width) {
                if(pointY > windowFrame.origin.y && pointY < windowFrame.origin.y + windowFrame.height) {
                    // Inside window!
                    insideWindow = true;
                }
            }
            
            if(insideWindow) {
                fadeInTitlebar();
            }
            else {
                fadeOutTitlebar();
            }
        }
    }
    
    func fadeOutTitlebar() {
        titlebarVisualEffectView.animator().alphaValue = 0;
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 0;
    }
    
    func fadeInTitlebar() {
        titlebarVisualEffectView.animator().alphaValue = 1;
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 1;
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.sharedApplication().windows.last!;
        
        // Set it to have a full size content view
        readerWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        readerWindow.titlebarAppearsTransparent = true;
        
        // Set the appearance
        readerWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
}
