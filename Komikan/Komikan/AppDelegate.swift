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
    
    @IBOutlet weak var mangaGridCollectionView: NSCollectionView!
    @IBOutlet weak var mangaGridArray: NSArrayController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        styleWindow();
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
        
        let itemPrototype : NSCollectionViewItem = NSCollectionViewItem(nibName: "KMMangaGridItem", bundle: NSBundle.mainBundle())!;
        
        mangaGridCollectionView.itemPrototype = itemPrototype;
        
        var newCoverImage : KMMangaGridItem = KMMangaGridItem();
        newCoverImage.coverImage = NSImage(named: "NSUser");
        mangaGridArray.addObject(newCoverImage);
        
        newCoverImage = KMMangaGridItem();
        newCoverImage.coverImage = NSImage(named: "NSCaution");
        mangaGridArray.addObject(newCoverImage);
        
        newCoverImage = KMMangaGridItem();
        newCoverImage.coverImage = NSImage(named: "NSTrashEmpty");
        mangaGridArray.addObject(newCoverImage);
        
        newCoverImage = KMMangaGridItem();
        newCoverImage.coverImage = NSImage(named: "example-cover");
        mangaGridArray.addObject(newCoverImage);
        
        print(mangaGridArray.arrangedObjects);
    }
    
    func styleWindow() {
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
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

