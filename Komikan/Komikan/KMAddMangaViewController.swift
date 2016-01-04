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
    
    // The NSTimer to update if we can add the manga with our given values
    var addButtonUpdateLoop : NSTimer = NSTimer();
    
    // The image view for the cover image
    @IBOutlet weak var coverImageView: NSImageView!
    
    // The text field for the mangas title
    @IBOutlet weak var titleTextField: NSTextField!
    
    // The text field for the mangas series
    @IBOutlet weak var seriesTextField: NSTextField!
    
    // The text field for the mangas artist
    @IBOutlet weak var artistTextField: NSTextField!
    
    // The text field for the mangas writer
    @IBOutlet weak var writerTextField: NSTextField!
    
    // The open panel to let the user choose the mangas directory
    var chooseDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    // When we click the "Choose Directory" button...
    @IBAction func chooseDirectoryButtonPressed(sender: AnyObject) {
        // Run he choose directory open panel
        chooseDirectoryOpenPanel.runModal();
    }
    
    // The add button
    @IBOutlet weak var addButton: NSButton!
    
    // When we click the add button...
    @IBAction func addButtonPressed(sender: AnyObject) {
        // Dismiss the popver
        self.dismissController(self);
        
        // Set the new mangas cover image
        newManga.coverImage = coverImageView.image!;
        
        // Set the new mangas title
        newManga.title = titleTextField.stringValue;
        
        // Set the new mangas series
        newManga.series = seriesTextField.stringValue;
        
        // Set the new mangas artist
        newManga.artist = artistTextField.stringValue;
        
        // Set the new mangas directory
        newManga.directory = (chooseDirectoryOpenPanel.URL?.absoluteString.stringByRemovingPercentEncoding!)!;
        
        // Set the new mangas writer
        newManga.writer = writerTextField.stringValue;
        
        // Post the notification saying we are done and sending back the manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newManga);
    }
    
    // Updates the add buttons enabled state
    func updateAddButton() {
        // A variable to say if we can add the manga with the given values
        var canAdd : Bool = false;
        
        // If the cover image selected is not the default one...
        if(coverImageView.image != NSImage(named: "NSRevealFreestandingTemplate")) {
            // If the title is not nothing...
            if(titleTextField.stringValue != "") {
                // If the directory is not nothing...
                if(chooseDirectoryOpenPanel.URL?.absoluteString != nil) {
                    // Say we can add with these variables
                    canAdd = true;
                }
            }
        }
        
        // If we can add with these variables...
        if(canAdd) {
            // Enable the add button
            addButton.enabled = true;
        }
        else {
            // Disable the add button
            addButton.enabled = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Setup the choose directory open panel
        // Dont allow multiple files
        chooseDirectoryOpenPanel.allowsMultipleSelection = false;
        
        // Only allow CBZ and CBR(Still need to find a RAR lib for swift before I can enable CBR)
        chooseDirectoryOpenPanel.allowedFileTypes = ["cbz", /*"cbr"*/];
        
        // Start a 0.1 second loop that will set if we can add this manga or not
        addButtonUpdateLoop = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("updateAddButton"), userInfo: nil, repeats:true);
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
