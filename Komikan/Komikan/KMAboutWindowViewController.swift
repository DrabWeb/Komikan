//
//  KMAboutWindowViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-18.
//

import Cocoa

class KMAboutWindowViewController: NSViewController {

    /// The about window
    var aboutWindow : NSWindow = NSWindow();
    
    /// The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The text field that links to the Komikan github repository
    @IBOutlet weak var githubLinkTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the about window
        aboutWindow = NSApplication.sharedApplication().windows.last!;
        
        // Make the window have a full size content view
        aboutWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar
        aboutWindow.titlebarAppearsTransparent = true;
        
        // Hide the title
        aboutWindow.titleVisibility = .Hidden;
        
        // Hide the minimize and zoom buttons
        aboutWindow.standardWindowButton(.MiniaturizeButton)?.hidden = true;
        aboutWindow.standardWindowButton(.ZoomButton)?.hidden = true;
        
        // Set the window background to be more vibrant
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
