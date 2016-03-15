//
//  KMEHViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMEHViewController: NSViewController {
    
    // The NSTimer to update if we can add the manga with our given values
    var addButtonUpdateLoop : NSTimer = NSTimer();

    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The text field for the URL when adding from E-Hentai
    @IBOutlet weak var addFromEHTextField: NSTextFieldCell!
    
    // When we intreact with addFromEHTextField...
    @IBAction func addFromEHTextFieldInteracted(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        // For every URL in the add from EH text field (Seperated ast each space)...
        for(_, currentURL) in addFromEHTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
            // Add the current URL to the download queue
            (NSApplication.sharedApplication().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEHUseJapaneseTitle.state)));
        }
    }
    
    // The button to add the manga add the inputted URL from E-Hentai
    @IBOutlet weak var addFromEHButton: NSButtonCell!
    
    // When we interact with addFromEHButton...
    @IBAction func addFromEHButtonInteracted(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        // http://g.e-hentai.org/g/892676/e442d2c88e/
        // For every URL in the add from EH text field (Seperated at each ", ")...
        for(_, currentURL) in addFromEHTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
            // Add the current URL to the download queue
            (NSApplication.sharedApplication().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEHUseJapaneseTitle.state)));
        }
    }
    
    // The checkbox to say if we want to use the Japanese title for downloading from E-Hentai
    @IBOutlet weak var addFromEHUseJapaneseTitle: NSButton!
    
    // The text field for the URL when adding from ExHentai
    @IBOutlet weak var addFromEXTextField: NSTextField!
    
    // When we intreact with addFromEXTextField...
    @IBAction func addFromEXTextFieldInteracted(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        // For every URL in the add from EX text field (Seperated ast each space)...
        for(_, currentURL) in addFromEXTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
            // Add the current URL to the download queue
            (NSApplication.sharedApplication().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEXUseJapaneseTitle.state), onExHentai: true));
        }
    }
    
    // The button to add the manga add the inputted URL from ExHentai
    @IBOutlet weak var addFromEXButton: NSButton!
    
    // When we interact with addFromEXButton...
    @IBAction func addFromEXButtonInteracted(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        // For every URL in the add from EX text field (Seperated at each ", ")...
        for(_, currentURL) in addFromEXTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
            // Add the current URL to the download queue
            (NSApplication.sharedApplication().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEXUseJapaneseTitle.state), onExHentai: true));
        }
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
