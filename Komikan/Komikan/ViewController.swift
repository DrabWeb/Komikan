//
//  ViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // The main window of the application
    var window : NSWindow! = NSWindow();

    // The visual effect view for the main windows titlebar
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    // The visual effect view for the main windows background
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The collection view that manages displayig manga covers in the main window
    @IBOutlet weak var mangaCollectionView: NSCollectionView!
    
    // The array controller for the manga collection view
    @IBOutlet var mangaCollectionViewArray: NSArrayController!
    
    // The grid controller for the manga grid
    @IBOutlet var mangaGridController: KMMangaGridController!
    
    // The tab view for the titlebar that lets you sort
    @IBOutlet weak var titlebarTabView: NSTabView!
    
    // The search field in the titlebar
    @IBOutlet weak var titlebarSearchField: NSTextField!
    
    // When we finish editing the titlebarSearchField...
    @IBAction func titlebarSearchFieldInteracted(sender: AnyObject) {
        
    }
    
    // The view controller we will load for the add manga popover
    var addMangaViewController: KMAddMangaViewController?
    
    // Is this the first time weve clicked on the add button in the titlebar?
    var addMangaViewFirstLoad : Bool = true;
    
    // The button in the titlebar that lets us add manga
    @IBOutlet weak var titlebarAddMangaButton: NSButton!
    
    // When we click titlebarAddMangaButton...
    @IBAction func titlebarAddMangaButtonInteracted(sender: AnyObject) {
        // If addMangaViewController is nil...
        if(addMangaViewController == nil) {
            // Get the main storyboard
            let storyboard = NSStoryboard(name: "Main", bundle: nil);
            
            // Instanstiate the view controller for the add manga view controller
            addMangaViewController = storyboard.instantiateControllerWithIdentifier("addMangaViewController") as? KMAddMangaViewController;
        }
        
        // Present the addMangaViewController as a popover using the add buttons rect, on the max y edge, and with a semitransient behaviour
        addMangaViewController!.presentViewController(addMangaViewController!, asPopoverRelativeToRect: (sender as! NSButton).bounds, ofView: ((sender as? NSButton))!, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Semitransient);
        
        // If this is the first time we have pushed this button...
        if(addMangaViewFirstLoad) {
            // Subscribe to the popovers finished notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "addMangaFromAddMangaPopover:", name:"KMAddMangaViewController.Finished", object: nil);
            
            // Say that all the next loads are not the first
            addMangaViewFirstLoad = false;
        }
    }
    
    // Called when we hit "Add" in the addmanga popover
    func addMangaFromAddMangaPopover(notification: NSNotification) {
        // Print to the log that we have recieved it and its name
        print("Recieving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from Add Manga popover...");
        
        // Add the manga to the grid
        mangaGridController.addManga((notification.object as? KMManga)!);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Style the window to be fancy
        styleWindow();
        
        // Set the collections views item prototype to the collection view item we created in Main.storyboard
        mangaCollectionView.itemPrototype = storyboard?.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
        
        // Start a 0.1 second loop that will fix the windows look in fullscreen
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("deleteTitlebarInFullscreen"), userInfo: nil, repeats:true);
        
        // Example manga for the grid
        let nonNonBiyori : KMManga = KMManga();
        nonNonBiyori.coverImage = NSImage(named: "example-cover-two")!;
        nonNonBiyori.artist = "Media Factory";
        // Path for my machine
        nonNonBiyori.directory = "/Volumes/Storage/Japanese/Manga/Non Non Biyori/Non Non Biyori - Chapter 013.cbz";
        nonNonBiyori.title = "Non Non Biyori - Chapter 13";
        nonNonBiyori.writer = "Atto";
        nonNonBiyori.series = "Non Non Biyori";
        
        mangaGridController.addManga(nonNonBiyori);
    }
    
    func styleWindow() {
        // Get a reference to the main window
        window = NSApplication.sharedApplication().windows.last!;
        
        // Set the main window to have a full size content view
        window.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        window.titlebarAppearsTransparent = true;
        
        // Hide the titlebar title
        window.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        // Set the backgrouynd effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
        
        // Set the titlebar effect to be ultra dark
        titlebarVisualEffectView.material = NSVisualEffectMaterial.UltraDark;
    }
    
    func deleteTitlebarInFullscreen() {
        // If the window is in fullscreen(Window height matches the screen height(This is really cheaty and I need to find a better way to do this))
        if(window.frame.height == NSScreen.mainScreen()?.frame.height) {
            // Hide the toolbar so we dont get a grey bar at the top
            window.toolbar?.visible = false;
        }
        else {
            // Show the toolbar again in non-fullscreen(So we still get the traffic lights in the right place)
            window.toolbar?.visible = true;
        }
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

