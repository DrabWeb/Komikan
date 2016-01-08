//
//  KMEditMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMEditMangaViewController: NSViewController {
    
    // The visual effect view for the background of the popover
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
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
    
    // When we press the change directory button...
    @IBAction func changeDirectoryButtonPressed(sender: AnyObject) {
        // Show the change directory open panel
        changeDirectoryOpenPanel.runModal();
        
        // If we chose a file...
        if(changeDirectoryOpenPanel.URL != nil) {
            // Set the mangas path to the file we chose
            manga.directory = (changeDirectoryOpenPanel.URL?.absoluteString.stringByRemovingPercentEncoding)!.stringByReplacingOccurrencesOfString("file://", withString: "");
        }
    }
    
    // The button to open this manga in the reader
    @IBOutlet weak var openButton: NSButton!
    
    // When we press openButton...
    @IBAction func openButtonPressed(sender: AnyObject) {
        // Close the popover
        self.dismissController(self);
        
        // Open the manga we have
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.openManga(manga, page: 0);
    }
    
    // The button to save our edits to the manga
    @IBOutlet weak var saveButton: NSButton!
    
    // When we press saveButton...
    @IBAction func saveButtonPressed(sender: AnyObject) {
        // Save our changes
        saveBackToGrid();
    }
    
    @IBAction func removeButtonPressed(sender: AnyObject) {
        // Close the popover
        self.dismissController(self);
        
        // Post the notification back to the collection view item so it can remove itself
        NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Remove", object: manga);
    }
    
    // The manga we were passed
    var manga : KMManga = KMManga();
    
    // The open panel to let the user choose the mangas directory
    var changeDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Setup the change directory open panel
        // Dont allow multiple files
        changeDirectoryOpenPanel.allowsMultipleSelection = false;
        
        // Only allow CBZ and CBR(Still need to find a RAR lib for swift before I can enable CBR)
        changeDirectoryOpenPanel.allowedFileTypes = ["cbz", /*"cbr"*/];
        
        // Set the Open button to say choose
        changeDirectoryOpenPanel.prompt = "Choose";
        
        // Subscribe to the popovers finished notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMangaFromGrid:", name:"KMMangaGridCollectionItem.Editing", object: nil);
    }
    
    // Saves our changed values back to the grid item
    func saveBackToGrid() {
        // Close the popover
        self.dismissController(self);
        
        // Get all the values from the fields
        // Set the cover image
        manga.coverImage = coverImageView.image!;
        
        // Set the title
        manga.title = titleTextField.stringValue;
        
        // Set the series
        manga.series = seriesTextField.stringValue;
        
        // Set the artist
        manga.artist = artistTextField.stringValue;
        
        // Set the writer
        manga.writer = writerTextField.stringValue;
        
        // Post the notification back to the collection view item so it can deal with it
        NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Saving", object: manga);
    }
    
    // Fills in the fields with manga's info
    func fillValuesFromManga() {
        // Set the cover image view
        coverImageView.image = manga.coverImage;
        
        // Set the title text field
        titleTextField.stringValue = manga.title;
        
        // Set the series text field
        seriesTextField.stringValue = manga.series;
        
        // Set the artist text field
        artistTextField.stringValue = manga.artist;
        
        // Set the writer text field
        writerTextField.stringValue = manga.writer;
    }
    
    func getMangaFromGrid(notification : NSNotification) {
        // Print to the log that we are receiving a manga from the grid
        print("Receiving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from manga grid");
        
        // Set manga to the notifications manga
        manga = (notification.object as? KMManga)!;
        
        // Remove the observer so we dont get duplicate calls
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
        // Fill in the fields with our new data
        fillValuesFromManga();
    }
    
    func styleWindow() {
        // Set the background visual effect views material to dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
