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
        
        // Select this item
        self.selected = true;
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
    }
    
    func saveMangaFromPopover(notification : NSNotification) {
        // Set this items manga to the notiifcations manga
        (self.representedObject as? KMMangaGridItem)?.changeManga((notification.object as? KMManga)!);
        
        // Print to the log the manga we received
        print("Saving manga \"" + ((self.representedObject as? KMMangaGridItem)?.manga.title)! + "\"");
        
        // Remove the observer so we dont get duplicate calls
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
        // Get the main storyboard
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        
        // Redraw the collection view to match the updated content
        self.collectionView.itemPrototype = storyboard.instantiateControllerWithIdentifier("mangaCollectionViewItem") as? NSCollectionViewItem;
    }
}