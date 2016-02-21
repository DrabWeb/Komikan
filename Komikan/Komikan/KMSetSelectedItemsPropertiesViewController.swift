//
//  KMSetSelectedItemsPropertiesViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-13.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMSetSelectedItemsPropertiesViewController: NSViewController {
    
    /// The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!

    /// The Text Field to set the series
    @IBOutlet weak var seriesTextField: NSTextField!
    
    /// The Text Field to set the artist
    @IBOutlet weak var artistTextField: NSTextField!
    
    /// The Text Field to set the writer
    @IBOutlet weak var writerTextField: NSTextField!
    
    /// The Text Field to set the tags
    @IBOutlet weak var tagsTextField: NSTextField!
    
    /// The Text Field to set the group
    @IBOutlet weak var groupTextField: NSTextField!
    
    /// The button to set favourites
    @IBOutlet weak var favouriteButton: KMFavouriteButton!
    
    /// Have we clicked the favourites button?
    var pressedFavouritesButton : Bool = false;
    
    /// The checkbox to say if we want to append instead of replace the tags
    @IBOutlet weak var appendTagsCheckbox: NSButton!
    
    /// When we click the "Set" button...
    @IBAction func setButtonPressed(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        /// A properties holder to pass the data between the popover and the master View Controller
        let propertiesHolder : KMSetSelectedPropertiesHolder = KMSetSelectedPropertiesHolder();
        
        // Store all the passed values in a new set selected items properties holder
        propertiesHolder.series = seriesTextField.stringValue;
        propertiesHolder.artist = artistTextField.stringValue;
        propertiesHolder.writer = writerTextField.stringValue;
        propertiesHolder.tags = tagsTextField.stringValue.componentsSeparatedByString(", ");
        propertiesHolder.group = groupTextField.stringValue;
        propertiesHolder.appendTags = Bool(appendTagsCheckbox.state);
        propertiesHolder.favourite = Bool(favouriteButton.state);
        propertiesHolder.setFavourite = Bool(favouriteButton.state);
        
        // Post the notification to say we are done, with the properties holder
        NSNotificationCenter.defaultCenter().postNotificationName("KMSetSelectedItemsPropertiesViewController.Finished", object: propertiesHolder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Update the favourites button
        favouriteButton.updateButton();
    }
    
    /// Styles the view
    func styleWindow() {
        // Set the background visual effect views material to be the more vibrant dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}

/// A small class whos only purpose is to transfer data between the set selected properties view controller and the master view controller
class KMSetSelectedPropertiesHolder {
    /// The series
    var series : String = "";
    
    /// The artist
    var artist : String = "";
    
    /// The writer
    var writer : String = "";
    
    /// The tags
    var tags : [String] = [];
    
    /// The group
    var group : String = "";
    
    // Is this manga a favourite?
    var favourite : Bool = false;
    
    /// Should we append instead of replace the tags?
    var appendTags : Bool = false;
    
    /// Should we set if the manga is a favourite?
    var setFavourite : Bool = false;
    
    /// Sets the passed manga's values to the ones stored inside this instance. Also appends instead of replacing based on appendTags
    func applyValuesToManga(manga : KMManga) {
        // If there is a series value set...
        if(series != "") {
            // Set the mangas series to the series value
            manga.series = series;
        }
        
        // If there is an artist value set...
        if(artist != "") {
            // Set the mangas artist to the series value
            manga.artist = artist;
        }
        
        // If there is a writer value set...
        if(writer != "") {
            // Set the mangas writer to the series value
            manga.writer = writer;
        }
        
        // If there is a tags value set...
        if(tags.count != 0 && !(tags[0] == "")) {
            // If we said to append the tags...
            if(appendTags) {
                // Append the tags to the mangas tags
                manga.tags.appendContentsOf(tags);
            }
            else {
                // Set the mangas tags to the tags value
                manga.tags = tags;
            }
        }
        
        // If there is a group value set...
        if(group != "") {
            // Set the mangas group to the group value
            manga.group = group;
        }
        
        // If we said to change the manga's favourite value...
        if(setFavourite) {
            // Set the mangas favourite value to favourite
            manga.favourite = favourite;
        }
    }
}
