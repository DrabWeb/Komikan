//
//  KMAddMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-03.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMAddMangaViewController: NSViewController {
    
    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The manga we will send back
    var newManga : KMManga = KMManga();
    
    // When we click the add button...
    @IBAction func addButtonPressed(sender: AnyObject) {
        // Dismiss the popver
        self.dismissController(self);
        
        // Set an example title(Will change to actually let you fill in values later)
        newManga.title = "Hello!";
        
        // Post the notification saying we are done and sending back the manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newManga);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
