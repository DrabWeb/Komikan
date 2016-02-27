//
//  KMMetadataFetcherViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMetadataFetcherViewController: NSViewController {
    
    // KMMetadataFetcherViewController.Finished
    
    /// The visual effect view for the background of the popover
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The KMManga we have selected in the manga grid
    var selectedManga : [KMManga] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        print(selectedManga);
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the background to be more vibrant
        backgroundVisualEffectView.material = .Dark;
    }
}
