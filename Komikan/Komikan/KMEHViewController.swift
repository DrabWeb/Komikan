//
//  KMEHViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-16.
//

import Cocoa

class KMEHViewController: NSViewController {
    
    // The NSTimer to update if we can add the manga with our given values
    var addButtonUpdateLoop : Timer = Timer();

    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The text field for the URL when adding from E-Hentai
    @IBOutlet weak var addFromEHTextField: NSTextFieldCell!
    
    // When we intreact with addFromEHTextField...
    @IBAction func addFromEHTextFieldInteracted(_ sender: AnyObject) {
        // Dismiss the popover
        self.dismiss(self);
        
        // For every URL in the add from EH text field (Seperated ast each space)...
        for(_, currentURL) in addFromEHTextField.stringValue.components(separatedBy: ", ").enumerated() {
            // Add the current URL to the download queue
            (NSApplication.shared().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEHUseJapaneseTitle.state as NSNumber), group: addFromEHGroupTextField.stringValue));
        }
    }
    
    /// The text field for setting the E-Hentai downloaded manga's group
    @IBOutlet var addFromEHGroupTextField: NSTextField!
    
    // The button to add the manga add the inputted URL from E-Hentai
    @IBOutlet weak var addFromEHButton: NSButtonCell!
    
    // When we interact with addFromEHButton...
    @IBAction func addFromEHButtonInteracted(_ sender: AnyObject) {
        // Dismiss the popover
        self.dismiss(self);
        
        // For every URL in the add from EH text field (Seperated at each ", ")...
        for(_, currentURL) in addFromEHTextField.stringValue.components(separatedBy: ", ").enumerated() {
            // Add the current URL to the download queue
            (NSApplication.shared().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEHUseJapaneseTitle.state as NSNumber), group: addFromEHGroupTextField.stringValue));
        }
    }
    
    // The checkbox to say if we want to use the Japanese title for downloading from E-Hentai
    @IBOutlet weak var addFromEHUseJapaneseTitle: NSButton!
    
    // The text field for the URL when adding from ExHentai
    @IBOutlet weak var addFromEXTextField: NSTextField!
    
    // When we intreact with addFromEXTextField...
    @IBAction func addFromEXTextFieldInteracted(_ sender: AnyObject) {
        // Dismiss the popover
        self.dismiss(self);
        
        // For every URL in the add from EX text field (Seperated ast each space)...
        for(_, currentURL) in addFromEXTextField.stringValue.components(separatedBy: ", ").enumerated() {
            // Add the current URL to the download queue
            (NSApplication.shared().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEXUseJapaneseTitle.state as NSNumber), group: addFromEXGroupTextField.stringValue, onExHentai: true));
        }
    }
    
    /// The text field for setting the ExHentai downloaded manga's group
    @IBOutlet var addFromEXGroupTextField: NSTextField!
    
    // The button to add the manga add the inputted URL from ExHentai
    @IBOutlet weak var addFromEXButton: NSButton!
    
    // When we interact with addFromEXButton...
    @IBAction func addFromEXButtonInteracted(_ sender: AnyObject) {
        // Dismiss the popover
        self.dismiss(self);
        
        // For every URL in the add from EX text field (Seperated at each ", ")...
        for(_, currentURL) in addFromEXTextField.stringValue.components(separatedBy: ", ").enumerated() {
            // Add the current URL to the download queue
            (NSApplication.shared().delegate as! AppDelegate).ehDownloadController.addItemToQueue(KMEHDownloadItem(url: currentURL, useJapaneseTitle: Bool(addFromEXUseJapaneseTitle.state as NSNumber), group: addFromEXGroupTextField.stringValue, onExHentai: true));
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
        addButtonUpdateLoop = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(KMEHViewController.updateAddButton), userInfo: nil, repeats: true);
    }
    
    /// Updates the add button to if we can add the current entered URL to the downloads
    func updateAddButton() {
        // Say we cant download if the URL is blank
        if(addFromEHTextField.stringValue != "") {
            addFromEHButton.isEnabled = true;
        }
        else {
            addFromEHButton.isEnabled = false;
        }
        
        // Say we cant download if the URL is blank
        if(addFromEXTextField.stringValue != "") {
            addFromEXButton.isEnabled = true;
        }
        else {
            addFromEXButton.isEnabled = false;
        }
    }
    
    override func viewWillDisappear() {
        // Stop the add button update loop
        addButtonUpdateLoop.invalidate();
    }
    
    func styleWindow() {
        // Set the backgrounds visual effect view material
        backgroundVisualEffectView.material = NSVisualEffectMaterial.dark;
    }
}
