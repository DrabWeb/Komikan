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
        self.coverImageView.bind("alphaValue", to: self, withKeyPath: "representedObject.percentAlpha", options: nil);
        self.titleTextField.bind("alphaValue", to: self, withKeyPath: "representedObject.percentAlpha", options: nil);
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
        // Open the edit/open popover
        openPopover(false);
        
        // Set the collection view to be frontmost
        NSApplication.shared().windows.first!.makeFirstResponder(self.collectionView);
        
        // Deselect all the items
        self.collectionView.deselectAll(self);
        
        // Select this item
        self.isSelected = true;
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        // Get the modifier value and store it in a temporary variable
        let modifierValue : Int = Int((NSApplication.shared().delegate as! AppDelegate).modifierValue);
        
        // If we arent holding CMD or Shift...
        if(!(modifierValue == 1048840 || modifierValue == 131330)) {
            // Deselect all the items
            self.collectionView.deselectAll(self);
            
            // Select this item
            self.isSelected = true;
        }
        else {
            // Toggle selection on this item
            self.isSelected = !self.isSelected;
        }
        
        // Set the collection view to be frontmost
        NSApplication.shared().windows.first!.makeFirstResponder(self.collectionView);
        
        // If we double clicked...
        if(theEvent.clickCount == 2) {
            openManga();
        }
    }
    
    func openPopover(_ hidden : Bool) {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the edit/open manga view controller
        editMangaViewController = storyboard.instantiateController(withIdentifier: "editMangaViewController") as? KMEditMangaViewController;
        
        // If we said to show the popover...
        if(!hidden) {
            // Present editMangaViewController as a popover using this views bounds, the MaxX edge, and with a semitransient behaviour
            self.presentViewController(editMangaViewController!, asPopoverRelativeTo: self.view.bounds, of: self.view, preferredEdge: NSRectEdge.maxX, behavior: NSPopoverBehavior.semitransient);
        }
        // If we said to hide the popover...
        else {
            // Only load the view, but not display
            editMangaViewController?.loadView();
        }
        
        // Say that we want to edit or open this manga
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMMangaGridCollectionItem.Editing"), object: (self.representedObject as? KMMangaGridItem)?.manga);
        
        // Subscribe to the popovers saved function
        NotificationCenter.default.addObserver(self, selector: #selector(KMMangaGridCollectionItem.saveMangaFromPopover(_:)), name:NSNotification.Name(rawValue: "KMEditMangaViewController.Saving"), object: nil);
        
        // Subscribe to the readers update percent finished function
        NotificationCenter.default.addObserver(self, selector: #selector(KMMangaGridCollectionItem.updatePercentFinished(_:)), name:NSNotification.Name(rawValue: "KMMangaGridCollectionItem.UpdatePercentFinished"), object: nil);
    }
    
    func openManga() {
        // Open the popover(Hidden)
        openPopover(true);
        
        // Open this collection items manga
        (NSApplication.shared().delegate as! AppDelegate).openManga((self.representedObject as? KMMangaGridItem)!.manga, page: (self.representedObject as? KMMangaGridItem)!.manga.currentPage);
    }
    
    func saveMangaFromPopover(_ notification : Notification) {
        // If the UUID matches...
        if((self.representedObject as? KMMangaGridItem)?.manga.uuid == (notification.object as? KMManga)!.uuid) {
            // Print to the log the manga we received
            print("KMMangaGridCollectionItem: Saving manga \"\(((self.representedObject as? KMMangaGridItem)?.manga.title)!)\"");
            
            // Set this items manga to the notiifcations manga
            (self.representedObject as? KMMangaGridItem)?.changeManga((notification.object as? KMManga)!);
            
            // Remove the observer so we dont get duplicate calls
            NotificationCenter.default.removeObserver(self);
            
            // Store the current scroll position and selection
            (NSApplication.shared().delegate as! AppDelegate).mangaGridController.storeCurrentSelection();
            
            // Reload the view to match its contents
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ViewController.UpdateMangaGrid"), object: nil);
            
            // Resort the grid
            (NSApplication.shared().delegate as! AppDelegate).mangaGridController.resort();
            
            // Redo the search, if there was one
            (NSApplication.shared().delegate as! AppDelegate).mangaGridController.redoSearch();
            
            // Restore the scroll position and selection
            (NSApplication.shared().delegate as! AppDelegate).mangaGridController.restoreSelection();
        }
    }
    
    func updatePercentFinished(_ notification : Notification) {
        // If the UUID matches...
        if((self.representedObject as? KMMangaGridItem)?.manga.uuid == (notification.object as? KMManga)!.uuid) {
            // Update the passed mangas percent finished
            (notification.object as? KMManga)!.updatePercent();
            
            // Set this items mangas percent done to the passed mangas percent done
            (self.representedObject as? KMMangaGridItem)?.manga.percentFinished = ((notification.object as? KMManga)!.percentFinished);
        }
    }
}
