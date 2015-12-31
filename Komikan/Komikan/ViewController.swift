//
//  ViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var window : NSWindow! = NSWindow();

    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    @IBOutlet weak var mangaCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        styleWindow();
        
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
    }
    
    func styleWindow() {
        // Get a reference to the main window
        window = NSApplication.sharedApplication().windows.last!;
        
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
        window.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
    }
    
    func deleteTitlebarInFullscreen() {
        if(window.frame == NSScreen.mainScreen()?.frame) {
            window.toolbar?.visible = false;
        }
        else {
            window.toolbar?.visible = true;
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

