//
//  KMPreferencesController.swift
//  Komikan
//
//  Created by Seth on 2016-01-11.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMPreferencesController: NSViewController {

    // The main window for this view controller
    var preferencesWindow : NSWindow = NSWindow();
    
    // The tab view for going through preference categories
    @IBOutlet weak var tabView: NSTabView!
    
    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The visual effect view for the titlebar of the window
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    func styleWindow() {
        // Get a reference to the main window
        preferencesWindow = NSApplication.sharedApplication().windows.last!;
        
        // Set the main window to have a full size content view
        preferencesWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        preferencesWindow.titlebarAppearsTransparent = true;
        
        // Hide the titlebar title
        preferencesWindow.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        // Set the backgrouynd effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        
        // Set the titlebar effect to be ultra dark
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
        
        // Get the windows center position on the X
        let windowX = ((NSScreen.mainScreen()?.frame.width)! / 2) - (480 / 2);
        
        // Get the windows center position on the Y
        let windowY = ((NSScreen.mainScreen()?.frame.height)! / 2) - (270 / 2);
        
        // Center the window
        preferencesWindow.setFrame(NSRect(x: windowX, y: windowY, width: 480, height: 270), display: false);
    }
}
