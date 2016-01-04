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
    
    @IBOutlet weak var coverImageView: NSImageView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var seriesTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    @IBOutlet weak var writerTextField: NSTextField!
    
    var chooseDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    @IBAction func chooseDirectoryButtonPressed(sender: AnyObject) {
        chooseDirectoryOpenPanel.runModal();
    }
    
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
        
        // Reset the fields
        resetFields();
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
    
    func resetFields() {
        coverImageView.image = NSImage(named: "NSRevealFreestandingTemplate");
        titleTextField.stringValue = " ";
        seriesTextField.stringValue = " ";
        artistTextField.stringValue = " ";
        writerTextField.stringValue = " ";
    }
}
