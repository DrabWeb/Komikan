//
//  KMMangaGridItemView.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
//

import Cocoa

class KMMangaGridCollectionItem: NSCollectionViewItem {
    
    // The view controller we will load for the edit/open manga popover
    var editMangaViewController: KMEditMangaViewController?
    
    /// The image view for the cover of the manga
    @IBOutlet var coverImageView: KMRasterizedImageView!
    
    /// The text field for the title of this manga
    @IBOutlet var titleTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Bind the alpha value to the percent done
        self.coverImageView.bind("alphaValue", toObject: self, withKeyPath: "representedObject.percentAlpha", options: nil);
        self.titleTextField.bind("alphaValue", toObject: self, withKeyPath: "representedObject.percentAlpha", options: nil);
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        // Open the edit/open popover
        openPopover(false);
        
        // Set the collection view to be frontmost
        NSApplication.sharedApplication().windows.first!.makeFirstResponder(self.collectionView);
        
        // Deselect all the items
        self.collectionView.deselectAll(self);
        
        // Select this item
        self.selected = true;
    }
    
    override func mouseDown(theEvent: NSEvent) {
        // Get the modifier value and store it in a temporary variable
        let modifierValue : Int = Int((NSApplication.sharedApplication().delegate as! AppDelegate).modifierValue);
        
        // If we arent holding CMD or Shift...
        if(!(modifierValue == 1048840 || modifierValue == 131330)) {
            // Deselect all the items
            self.collectionView.deselectAll(self);
            
            // Select this item
            self.selected = true;
        }
        else {
            // Toggle selection on this item
            self.selected = !self.selected;
        }
        
        // Set the collection view to be frontmost
        NSApplication.sharedApplication().windows.first!.makeFirstResponder(self.collectionView);
        
        // If we double clicked...
        if(theEvent.clickCount == 2) {
            openManga();
        }
    }
    
    func openPopover(hidden : Bool) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the edit/open manga view controller
        editMangaViewController = storyboard.instantiateControllerWithIdentifier("editMangaViewController") as? KMEditMangaViewController;
        
        // If we said to show the popover...
        if(!hidden) {
            // Present editMangaViewController as a popover using this views bounds, the MaxX edge, and with a semitransient behaviour
            self.presentViewController(editMangaViewController!, asPopoverRelativeToRect: self.view.bounds, ofView: self.view, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient);
        }
        // If we said to hide the popover...
        else {
            // Only load the view, but not display
            editMangaViewController?.loadView();
        }
        
        // Say that we want to edit or open this manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMMangaGridCollectionItem.Editing", object: (self.representedObject as? KMMangaGridItem)?.manga);
        
        // Subscribe to the popovers saved function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveMangaFromPopover:", name:"KMEditMangaViewController.Saving", object: nil);
        
        // Subscribe to the readers update percent finished function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePercentFinished:", name:"KMMangaGridCollectionItem.UpdatePercentFinished", object: nil);
    }
    
    func openManga() {
        // Open the popover(Hidden)
        openPopover(true);
        
        // Open this collection items manga
        (NSApplication.sharedApplication().delegate as! AppDelegate).openManga((self.representedObject as? KMMangaGridItem)!.manga, page: (self.representedObject as? KMMangaGridItem)!.manga.currentPage);
    }
    
    func saveMangaFromPopover(notification : NSNotification) {
        // If the UUID matches...
        if((self.representedObject as? KMMangaGridItem)?.manga.uuid == (notification.object as? KMManga)!.uuid) {
            // Print to the log the manga we received
            print("KMMangaGridCollectionItem: Saving manga \"\(((self.representedObject as? KMMangaGridItem)?.manga.title)!)\"");
            
            // Set this items manga to the notiifcations manga
            (self.representedObject as? KMMangaGridItem)?.changeManga((notification.object as? KMManga)!);
            
            // Remove the observer so we dont get duplicate calls
            NSNotificationCenter.defaultCenter().removeObserver(self);
            
            // Store the current scroll position and selection
            (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.storeCurrentSelection();
            
            // Reload the view to match its contents
            NSNotificationCenter.defaultCenter().postNotificationName("ViewController.UpdateMangaGrid", object: nil);
            
            // Resort the grid
            (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.resort();
            
            // Redo the search, if there was one
            (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.redoSearch();
            
            // Restore the scroll position and selection
            (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.restoreSelection();
        }
    }
    
    func updatePercentFinished(notification : NSNotification) {
        // If the UUID matches...
        if((self.representedObject as? KMMangaGridItem)?.manga.uuid == (notification.object as? KMManga)!.uuid) {
            // Update the passed mangas percent finished
            (notification.object as? KMManga)!.updatePercent();
            
            // Set this items mangas percent done to the passed mangas percent done
            (self.representedObject as? KMMangaGridItem)?.manga.percentFinished = ((notification.object as? KMManga)!.percentFinished);
        }
    }
}