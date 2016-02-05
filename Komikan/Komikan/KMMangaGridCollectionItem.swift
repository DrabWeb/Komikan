//
//  KMMangaGridItemView.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridCollectionItem: NSCollectionViewItem {
    
    // The view controller we will load for the edit/open manga popover
    var editMangaViewController: KMEditMangaViewController?
    
    override func mouseDown(theEvent: NSEvent) {
        // If we double clicked...
        if(theEvent.clickCount == 2) {
            // Open the edit/open popover
            openPopover();
        }
        
        // Get the modifier value and store it in a temporary variable
        let modifierValue : Int = Int((NSApplication.sharedApplication().delegate as! AppDelegate).modifierValue);
        
        // If we arent holding CMD or Shift...
        if(!(modifierValue == 1048840 || modifierValue == 131330)) {
            // Deselect all the items
            self.collectionView.deselectAll(self);
        }
        
        // Select this item
        self.selected = true;
        
        // Make the first window set the collection view as the first responder
        NSApplication.sharedApplication().windows[0].makeFirstResponder(self.collectionView);
    }
    
    func openPopover() {
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Instanstiate the view controller for the edit/open manga view controller
        editMangaViewController = storyboard.instantiateControllerWithIdentifier("editMangaViewController") as? KMEditMangaViewController;
        
        // Present editMangaViewController as a popover using this views bounds, the MaxX edge, and with a semitransient behaviour
        self.presentViewController(editMangaViewController!, asPopoverRelativeToRect: self.view.bounds, ofView: self.view, preferredEdge: NSRectEdge.MaxX, behavior: NSPopoverBehavior.Semitransient);
        
        // Say that we want to edit or open this manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMMangaGridCollectionItem.Editing", object: (self.representedObject as? KMMangaGridItem)?.manga);
        
        // Subscribe to the popovers saved function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveMangaFromPopover:", name:"KMEditMangaViewController.Saving", object: nil);
        
        // Subscribe to the readers update percent finished function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePercentFinished:", name:"KMMangaGridCollectionItem.UpdatePercentFinished", object: nil);
    }
    
    func saveMangaFromPopover(notification : NSNotification) {
        // If the UUID matches...
        if((self.representedObject as? KMMangaGridItem)?.manga.uuid == (notification.object as? KMManga)!.uuid) {
            // Print to the log the manga we received
            print("Saving manga \"" + ((self.representedObject as? KMMangaGridItem)?.manga.title)! + "\"");
            
            // Set this items manga to the notiifcations manga
            (self.representedObject as? KMMangaGridItem)?.changeManga((notification.object as? KMManga)!);
            
            // Remove the observer so we dont get duplicate calls
            NSNotificationCenter.defaultCenter().removeObserver(self);
            
            // Reload the view to match its contents
            NSNotificationCenter.defaultCenter().postNotificationName("ViewController.UpdateMangaGrid", object: nil);
            
            // Reload the grid filters
            NSNotificationCenter.defaultCenter().postNotificationName("GridController.ReloadFilters", object: nil);
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