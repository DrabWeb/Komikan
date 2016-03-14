//
//  KMEditMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMEditMangaViewController: NSViewController {
    
    /// The visual effect view for the background of the popover
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The image view for the cover image
    @IBOutlet weak var coverImageView: NSImageView!
    
    /// The text field for the manga's title
    @IBOutlet weak var titleTextField: NSTextField!
    
    /// The token text field for the manga's series
    @IBOutlet weak var seriesTokenTextField: KMSuggestionTokenField!
    
    /// The token text field for the manga's artist
    @IBOutlet weak var artistTokenTextField: KMSuggestionTokenField!
    
    /// The token text field for the manga's writer
    @IBOutlet weak var writerTokenTextField: KMSuggestionTokenField!
    
    /// The text field for the manga's tags
    @IBOutlet weak var tagsTextField: NSTextField!
    
    /// The token text field for the manga's group
    @IBOutlet weak var groupTokenTextField: KMSuggestionTokenField!
    
    /// The button to set if this manga is a favourite
    @IBOutlet weak var favouriteButton: NSButton!
    
    /// When we interact with favouriteButton...
    @IBAction func favouriteButtonInteracted(sender: AnyObject) {
        
    }
    
    /// When we press the change directory button...
    @IBAction func changeDirectoryButtonPressed(sender: AnyObject) {
        // Show the change directory open panel
        changeDirectoryOpenPanel.runModal();
        
        // If we chose a file...
        if(changeDirectoryOpenPanel.URL != nil) {
            // Set the manga's path to the file we chose
            manga.directory = (changeDirectoryOpenPanel.URL?.absoluteString.stringByRemovingPercentEncoding)!.stringByReplacingOccurrencesOfString("file://", withString: "");
        }
    }
    
    /// The button to open this manga in the reader
    @IBOutlet weak var openButton: NSButton!
    
    /// When we press openButton...
    @IBAction func openButtonPressed(sender: AnyObject) {
        // Close the popover
        self.dismissController(self);
        
        // Open the manga we have, at the last open page
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.openManga(manga, page: manga.currentPage);
    }
    
    /// The button to save our edits to the manga
    @IBOutlet weak var saveButton: NSButton!
    
    /// When we press saveButton...
    @IBAction func saveButtonPressed(sender: AnyObject) {
        // Save our changes
        saveBackToGrid();
    }
    
    /// When we click the remove button...
    @IBAction func removeButtonPressed(sender: AnyObject) {
        // Close the popover
        self.dismissController(self);
        
        // Post the notification back to the collection view item so it can remove itself
        NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Remove", object: manga);
    }
    
    /// The dropdown that lets us open our bookmarks
    @IBOutlet weak var bookmarksDropDown: NSPopUpButton!
    
    /// When we click an item in bookmarksDropDown
    @IBAction func bookmarksDropDownPressed(sender: AnyObject) {
        // Close the popover
        self.dismissController(self);
        
        // Open the manga we have, at the bookmark we selected(The page is gotten by taking the selected items title, removing "Page " from it and converting it to an int)
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.openManga(manga, page: Int((bookmarksDropDown.selectedItem?.title.stringByReplacingOccurrencesOfString("Page ", withString: ""))!)! - 1);
    }
    
    /// When we click the "Mark Read" button...
    @IBAction func markReadButtonPressed(sender: AnyObject) {
        // Set the read variable of manga to true
        manga.read = true;
        
        // Set the manga's last open page to the first
        manga.currentPage = 0;
        
        // Update the percent finished
        manga.updatePercent();
        
        // Save the manga back to the grid
        saveBackToGrid();
    }
    
    /// When we click the "Mark Unread" button...
    @IBAction func markUnreadButtonPressed(sender: AnyObject) {
        // Set the read variable of manga to false
        manga.read = false;
        
        // Set the manga's last open page to the first
        manga.currentPage = 0;
        
        // Update the percent finished
        manga.updatePercent();
        
        // Save the manga back to the grid
        saveBackToGrid();
    }
    
    /// The manga we were passed
    var manga : KMManga = KMManga();
    
    /// The open panel to let the user choose the manga's directory
    var changeDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Set the favourite buttons alpha value to 0.2
        favouriteButton.alphaValue = 0.2;
        
        // Setup the change directory open panel
        // Dont allow multiple files
        changeDirectoryOpenPanel.allowsMultipleSelection = false;
        
        // Only allow CBZ, CBR, ZIP, RAR and Folders
        changeDirectoryOpenPanel.allowedFileTypes = ["cbz", "cbr", "zip", "rar"];
        changeDirectoryOpenPanel.canChooseDirectories = true;
        
        // Set the Open button to say choose
        changeDirectoryOpenPanel.prompt = "Choose";
        
        // Setup all the suggestions for the property text fields
        seriesTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allSeries();
        artistTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allArtists();
        writerTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allWriters();
        groupTokenTextField.suggestions = (NSApplication.sharedApplication().delegate as! AppDelegate).mangaGridController.allGroups();
        
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
        manga.series = seriesTokenTextField.stringValue;
        
        // Set the artist
        manga.artist = artistTokenTextField.stringValue;
        
        // Set the writer
        manga.writer = writerTokenTextField.stringValue;
        
        // Reset the manga's tags
        manga.tags = [];
        
        // For every part of the tags text field's string value split at every ", "...
        for (_, currentTag) in tagsTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
            // Append the current tags to the manga's tags
            manga.tags.append(currentTag);
        }
        
        // Set the group
        manga.group = groupTokenTextField.stringValue;
        
        // Set if its a favourite
        manga.favourite = Bool(favouriteButton.state);
        
        // If the cover images height isnt the compressed one(400)...
        if(manga.coverImage.size.height != 400) {
            // Resize the cover image to be compressed for faster loading
            manga.coverImage = manga.coverImage.resizeToHeight(400);
        }
        
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
        seriesTokenTextField.stringValue = manga.series;
        
        // Set the artist text field
        artistTokenTextField.stringValue = manga.artist;
        
        print(manga.writer);
        // Set the writer text field
        writerTokenTextField.stringValue = manga.writer;
        
        // Set the favourite button
        favouriteButton.state = Int(manga.favourite);
        
        // Update the favourites button
        (favouriteButton as? KMFavouriteButton)!.updateButton();
        
        // If there are no bookmarks...
        if(manga.bookmarks.count == 0) {
            // Hide the bookmarks dropdown
            bookmarksDropDown.hidden = true;
        }
        
        // Sort the bookmarks
        manga.bookmarks = manga.bookmarks.sort();
        
        // Extract the manga to tmp
        manga.extractToTmpFolder();
        
        // For every bookmark in manga.bookmarks...
        for (_, currentBookmark) in manga.bookmarks.enumerate() {
            // Add a menu item to the bookmarks dropdown with the title being Page and the bookmarked page
            bookmarksDropDown.addItemWithTitle("Page " + String(currentBookmark + 1));
            
            // Get the preview image
            let previewImage : NSImage = manga.pages[currentBookmark];
            
            // Get the aspect ratio of the image
            let aspectRatio = previewImage.size.width / previewImage.size.height;
            
            // Figure out what the width will be
            let width = aspectRatio * 100;
            
            // Set the image size
            previewImage.size = NSSize(width: width, height: 100);
            
            // Set the items image to previewImage
            bookmarksDropDown.itemArray.last?.image = previewImage;
        }
        
        // For every tag in manga.tags...
        for (currentIndex, currentTag) in manga.tags.enumerate() {
            // If this is not the last one...
            if(currentIndex < manga.tags.count - 1) {
                // Append the current tag and ", "
                tagsTextField.stringValue.appendContentsOf(currentTag + ", ");
            }
            // If this is the last one...
            else {
                // Append just the current tag
                tagsTextField.stringValue.appendContentsOf(currentTag);
            }
        }
        
        // Set the group text field's string value to the group of the manga
        groupTokenTextField.stringValue = manga.group;
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
    
    override func viewWillDisappear() {
        // Post the notification that the popover is closing
        NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Closing", object: nil);
    }
    
    func styleWindow() {
        // Set the background visual effect views material to dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
