//
//  KMEHViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa
import SwiftyJSON

class KMEHViewController: NSViewController {
    
    // The NSTimer to update if we can add the manga with our given values
    var addButtonUpdateLoop : NSTimer = NSTimer();

    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The text field for the URL when adding from E-Hentai
    @IBOutlet weak var addFromEHTextField: NSTextFieldCell!
    
    // When we intreact with addFromEHTextField...
    @IBAction func addFromEHTextFieldInteracted(sender: AnyObject) {
        // Add the manga from e-hentai, with the represented text fields string value
        addFromEH(addFromEHTextField.stringValue);
    }
    
    // The button to add the manga add the inputted URL from E-Hentai
    @IBOutlet weak var addFromEHButton: NSButtonCell!
    
    // When we interact with addFromEHButton...
    @IBAction func addFromEHButtonInteracted(sender: AnyObject) {
        // Add the manga from e-hentai, with the represented text fields string value
        addFromEH(addFromEHTextField.stringValue);
    }
    
    // The checkbox to say if we want to use the Japanese title for downloading from E-Hentai
    @IBOutlet weak var addFromEHUseJapaneseTitle: NSButton!
    
    // The text field for the URL when adding from ExHentai
    @IBOutlet weak var addFromEXTextField: NSTextField!
    
    // When we intreact with addFromEXTextField...
    @IBAction func addFromEXTextFieldInteracted(sender: AnyObject) {
        // Add the manga from exhentai, with the represented text fields string value
        addFromEX(addFromEXTextField.stringValue);
    }
    
    // The button to add the manga add the inputted URL from ExHentai
    @IBOutlet weak var addFromEXButton: NSButton!
    
    // When we interact with addFromEXButton...
    @IBAction func addFromEXButtonInteracted(sender: AnyObject) {
        // Add the manga from exhentai, with the represented text fields string value
        addFromEX(addFromEXTextField.stringValue);
    }
    
    // The checkbox to say if we want to use the Japanese title for downloading from ExHentai
    @IBOutlet weak var addFromEXUseJapaneseTitle: NSButton!
    
    // The manga we will pass back
    var manga : KMManga = KMManga();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Start a 0.1 second loop that will set if we can add from the inpputed URL or not
        addButtonUpdateLoop = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("updateAddButton"), userInfo: nil, repeats:true);
    }
    
    // Adds the specified URL's manga from E-Hentai
    func addFromEH(url : String) {
        // Call the command
        KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/ehadd", arguments: [url, NSBundle.mainBundle().bundlePath + "/Contents/Resources/"]);
        
        // Dismiss the popover
        self.dismissController(self);
        
        // Create a variable to store the name of the new manga
        var newMangaFileName : String = "";
        
        // Try to get the contents of the newehpath in application support to fiure out what manga we are adding
        newMangaFileName = String(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehpath")!, encoding: NSUTF8StringEncoding)!;
        
        // Create a variable to store the new mangas JSON
        var newMangaJson : JSON!;
        
        // Try to get the contents of the newehdata.json in application support to find the information we need
        newMangaJson = JSON(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehdata.json")!);
        
        // If we want to use the Japanese title...
        if(Bool(addFromEHUseJapaneseTitle.state) == true) {
            // Set the mangas title to be the mangas Japanese json title
            manga.title = newMangaJson["gmetadata"][0]["title_jpn"].stringValue;
        }
        else {
            // Set the mangas title to be the mangas English json title
            manga.title = newMangaJson["gmetadata"][0]["title"].stringValue;
        }
        
        // Set the mangas cover image
        manga.coverImage = NSImage(contentsOfURL: NSURL(string: newMangaJson["gmetadata"][0]["thumb"].stringValue)!)!;
        
        // Set the mangas tags
        manga.tags = (newMangaJson["gmetadata"][0]["tags"].arrayObject as? [String])!;
        
        // Remove all the new lines from newMangaFileName(It adds a new line onto the end for some reason)
        newMangaFileName = newMangaFileName.stringByReplacingOccurrencesOfString("\n", withString: "");
        
        // Set the mangas path
        manga.directory = NSHomeDirectory() + "/Library/Application Support/Komikan/EH/" + newMangaFileName + ".cbz";
        print("Manga Directory: " + manga.directory);
        
        // Create the new notification to tell the user the download has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finished downloading \"" + manga.title + "\"";
        
        // Show the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
        
        // Post the notification saying we are done and sending back the manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMEHViewController.Finished", object: manga);
    }
    
    // Adds the specified URL's manga from ExHentai
    func addFromEX(url : String) {
        // Dismiss the popover
        self.dismissController(self);
        
        // Print to the log that this isnt supported yet
        print("Sorry, but ExHentai support is currently non-functional.");
    }
    
    func updateAddButton() {
        if(addFromEHTextField.stringValue != "") {
            addFromEHButton.enabled = true;
        }
        else {
            addFromEHButton.enabled = false;
        }
        
        if(addFromEXTextField.stringValue != "") {
            addFromEXButton.enabled = true;
        }
        else {
            addFromEXButton.enabled = false;
        }
    }
    
    func styleWindow() {
        // Set the backgrounds visual effect view material
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
