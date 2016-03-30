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

    /// The token text field to set the series
    @IBOutlet weak var seriesTokenTextField: KMSuggestionTokenField!
    
    /// The token text field to set the artist
    @IBOutlet weak var artistTokenTextField: KMSuggestionTokenField!
    
    /// The token text field to set the writer
    @IBOutlet weak var writerTokenTextField: KMSuggestionTokenField!
    
    /// The text field to set the tags
    @IBOutlet weak var tagsTextField: NSTextField!
    
    /// The token text field to set the group
    @IBOutlet weak var groupTokenTextField: KMSuggestionTokenField!
    
    /// The text field for setting the published date
    @IBOutlet var releaseDateTextField: NSTextField!
    
    /// The date formatter for releaseDateTextField
    @IBOutlet var releaseDateTextFieldDateFormatter: NSDateFormatter!
    
    /// The button to set favourites
    @IBOutlet weak var favouriteButton: KMFavouriteButton!
    
    /// The checkbox to say if we want to change the manga's favourite value
    @IBOutlet var modifyFavouriteCheckBox: NSButton!
    
    /// The checkbox to say if we want to append instead of replace the tags
    @IBOutlet weak var appendTagsCheckbox: NSButton!
    
    /// The checkbox to say if we want to mark the selected manga as l-lewd...
    @IBOutlet var lewdCheckbox: NSButton!
    
    /// When we interact with lewdCheckbox...
    @IBAction func lewdCheckboxInteracted(sender: AnyObject) {
        // Say we want to set the selected manga's lewd values
        setLewd = true;
    }
    
    /// Shoudl we set if the selected manga are lewd?
    var setLewd : Bool = false;
    
    /// When we click the "Set" button...
    @IBAction func setButtonPressed(sender: AnyObject) {
        // Dismiss the popover
        self.dismissController(self);
        
        /// A properties holder to pass the data between the popover and the master View Controller
        let propertiesHolder : KMSetSelectedPropertiesHolder = KMSetSelectedPropertiesHolder();
        
        // Store all the passed values in a new set selected items properties holder
        propertiesHolder.series = seriesTokenTextField.stringValue;
        propertiesHolder.artist = artistTokenTextField.stringValue;
        propertiesHolder.writer = writerTokenTextField.stringValue;
        propertiesHolder.tags = tagsTextField.stringValue.componentsSeparatedByString(", ");
        propertiesHolder.group = groupTokenTextField.stringValue;
        propertiesHolder.releaseDate = releaseDateTextFieldDateFormatter.dateFromString(releaseDateTextField.stringValue);
        propertiesHolder.appendTags = Bool(appendTagsCheckbox.state);
        propertiesHolder.favourite = Bool(favouriteButton.state);
        propertiesHolder.setFavourite = Bool(modifyFavouriteCheckBox.state);
        propertiesHolder.setLewd = setLewd;
        propertiesHolder.lewd = Bool(lewdCheckbox.state);
        
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
        
        // Setup all the suggestions for the property text fields
        seriesTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allSeries();
        artistTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allArtists();
        writerTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allWriters();
        groupTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allGroups();
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
    
    /// The published date
    var releaseDate : NSDate? = nil;
    
    /// Is this manga a favourite?
    var favourite : Bool = false;
    
    /// Is this manga l-lewd...?
    var lewd : Bool = false;
    
    /// Should we append instead of replace the tags?
    var appendTags : Bool = false;
    
    /// Should we set if the manga is a favourite?
    var setFavourite : Bool = false;
    
    /// Should we set if the manga is l-lewd...?
    var setLewd : Bool = false;
    
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
        
        // If the published date isnt nil...
        if(releaseDate != nil) {
            // Set the mangas piblished date
            manga.releaseDate = releaseDate!;
        }
        
        // If we said to change the manga's favourite value...
        if(setFavourite) {
            // Set the mangas favourite value to favourite
            manga.favourite = favourite;
        }
        
        // If we said to change the manga's lewd values...
        if(setLewd) {
            // Set the manga's lewd values
            manga.lewd = lewd;
        }
    }
}
