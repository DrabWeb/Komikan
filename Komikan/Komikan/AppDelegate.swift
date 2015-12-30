//
//  AppDelegate.swift
//  Komikan
//
//  Created by Seth on 2015-12-30.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        styleWindow();
    }
    
    func styleWindow() {
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
        window.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

