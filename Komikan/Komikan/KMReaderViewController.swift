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
        
        // Start the 0.1 second loop for the mouse hovering
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("mouseHoverHandling"), userInfo: nil, repeats:true);
    }
    
    func mouseHoverHandling() {
        // A bool to say if we are hovering the window
        var insideWindow : Bool = false;
        
        // Create a new CGEventRef, for the mouse position
        var mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        var mousePosition = CGEventGetLocation(mouseEvent);
        
        // Store the windows frame temporarly, so we dont retype a millino times
        var windowFrame : NSRect! = readerWindow.frame;
        
        // Create a variable to store the cursors location y where 0 0 is the bottom left
        var pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
        
        // If the mouse position is inside the window on the x...
        if(mousePosition.x > windowFrame.origin.x && mousePosition.x < windowFrame.origin.x + windowFrame.width) {
            // If the mouse position is inside the window on the y...
            if(pointY > windowFrame.origin.y && pointY < windowFrame.origin.y + windowFrame.height) {
                // The cursor is inside the window, say so
                insideWindow = true;
            }
        }
        
        // If the cursor is inside the window...
        if(insideWindow) {
            // Fade in the titlebar
            fadeInTitlebar();
        }
        // If the cursor is outside the window...
        else {
            // Fade out the titlebar
            fadeOutTitlebar();
        }
    }
    
    func fadeOutTitlebar() {
        // Use the animator to fade out the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 0;
        
        // Use the animator to fade out the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 0;
    }
    
    func fadeInTitlebar() {
        // Use the animator to fade in the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 1;
        
        // Use the animator to fade in the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 1;
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 0;
        
        // Set it to have a full size content view
        readerWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        readerWindow.titlebarAppearsTransparent = true;
        
        // Set the appearance
        readerWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
}
