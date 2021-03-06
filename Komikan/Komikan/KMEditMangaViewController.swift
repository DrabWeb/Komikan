//
//  KMEditMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
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
    @IBAction func favouriteButtonInteracted(_ sender: AnyObject) {
        
    }
    
    /// The text field for setting the release date of the manga
    @IBOutlet var releaseDateTextField: NSTextField!
    
    /// The date formatter for releaseDateTextField
    @IBOutlet var releaseDateTextFieldDateFormatter: DateFormatter!
    
    /// The button for changing the manga's directory
    @IBOutlet var changeDirectoryButton: NSButton!
    
    /// When we press the change directory button...
    @IBAction func changeDirectoryButtonPressed(_ sender: AnyObject) {
        // Show the change directory open panel
        changeDirectoryOpenPanel.runModal();
        
        // If we chose a file...
        if(changeDirectoryOpenPanel.url != nil) {
            // Set the manga's path to the file we chose
            manga.directory = (changeDirectoryOpenPanel.url?.absoluteString.removingPercentEncoding)!.replacingOccurrences(of: "file://", with: "");
        }
    }
    
    /// The button to open this manga in the reader
    @IBOutlet weak var openButton: NSButton!
    
    /// When we press openButton...
    @IBAction func openButtonPressed(_ sender: AnyObject) {
        // Close the popover
        self.dismiss(self);
        
        // Open the manga we have, at the last open page
        (NSApplication.shared().delegate as? AppDelegate)?.openManga(manga, page: manga.currentPage);
    }
    
    /// The button to save our edits to the manga
    @IBOutlet weak var saveButton: NSButton!
    
    /// When we press saveButton...
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        // Save our changes
        saveBackToGrid();
    }
    
    /// When we click the remove button...
    @IBAction func removeButtonPressed(_ sender: AnyObject) {
        // Close the popover
        self.dismiss(self);
        
        // Post the notification back to the collection view item so it can remove itself
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMEditMangaViewController.Remove"), object: manga);
    }
    
    /// The dropdown that lets us open our bookmarks
    @IBOutlet weak var bookmarksDropDown: NSPopUpButton!
    
    /// When we click an item in bookmarksDropDown
    @IBAction func bookmarksDropDownPressed(_ sender: AnyObject) {
        // Close the popover
        self.dismiss(self);
        
        // Open the manga we have, at the bookmark we selected(The page is gotten by taking the selected items title, removing "Page " from it and converting it to an int)
        (NSApplication.shared().delegate as? AppDelegate)?.openManga(manga, page: Int((bookmarksDropDown.selectedItem?.title.replacingOccurrences(of: "Page ", with: ""))!)! - 1);
    }
    
    /// The checkbox for saying/changing if this manga is l-lewd...
    @IBOutlet var lewdCheckbox: NSButton!
    
    /// When we click the "Mark Read" button...
    @IBAction func markReadButtonPressed(_ sender: AnyObject) {
        // Set the manga's current page to the last page, so we get it marked as 100% finished
        manga.currentPage = manga.pageCount - 1;
        
        // Update the manga's percent finished
        manga.updatePercent();
        
        // Save the manga back to the grid
        saveBackToGrid();
    }
    
    /// When we click the "Mark Unread" button...
    @IBAction func markUnreadButtonPressed(_ sender: AnyObject) {
        // Set the manga's current page to 0 so its marked as 0% done
        manga.currentPage = 0;
        
        // Update the manga's percent finished
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
        seriesTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allSeries();
        artistTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allArtists();
        writerTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allWriters();
        groupTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allGroups();
        
        // Subscribe to the popovers finished notification
        NotificationCenter.default.addObserver(self, selector: #selector(KMEditMangaViewController.getMangaFromGrid(_:)), name:NSNotification.Name(rawValue: "KMMangaGridCollectionItem.Editing"), object: nil);
    }
    
    // Saves our changed values back to the grid item
    func saveBackToGrid() {
        // Close the popover
        self.dismiss(self);
        
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
        
        // If the release date isnt blank...
        if(releaseDateTextField.stringValue != "") {
            // Set the release date
            manga.releaseDate = releaseDateTextFieldDateFormatter.date(from: releaseDateTextField.stringValue)!;
        }
        
        // Reset the manga's tags
        manga.tags = [];
        
        // For every part of the tags text field's string value split at every ", "...
        for (_, currentTag) in tagsTextField.stringValue.components(separatedBy: ", ").enumerated() {
            // Append the current tags to the manga's tags
            manga.tags.append(currentTag);
        }
        
        // Set the group
        manga.group = groupTokenTextField.stringValue;
        
        // Set if its a favourite
        manga.favourite = Bool(favouriteButton.state as NSNumber);
        
        // Update the if the manga is l-lewd...
        manga.lewd = Bool(lewdCheckbox.state as NSNumber);
        
        // If the cover images height isnt the compressed one(400)...
        if(manga.coverImage.size.height != 400) {
            // Resize the cover image to be compressed for faster loading
            manga.coverImage = manga.coverImage.resizeToHeight(400);
        }
        
        // Post the notification back to the collection view item so it can deal with it
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMEditMangaViewController.Saving"), object: manga);
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
        
        // Set the writer text field
        writerTokenTextField.stringValue = manga.writer;
        
        // If the release date has been set...
        if(!manga.releaseDate.isBeginningOfEpoch()) {
            // Set the release date
            releaseDateTextField.stringValue = releaseDateTextFieldDateFormatter.string(from: manga.releaseDate as Date);
        }
        
        // Set the favourite button
        favouriteButton.state = Int.fromBool(bool: manga.favourite);
        
        // Update the favourites button
        (favouriteButton as? KMFavouriteButton)!.updateButton();
        
        // Update the l-lewd... checkbox
        lewdCheckbox.state = Int.fromBool(bool: manga.lewd);
        
        // If there are no bookmarks...
        if(manga.bookmarks.count == 0) {
            // Hide the bookmarks dropdown
            bookmarksDropDown.isHidden = true;
        }
        
        // Sort the bookmarks
        manga.bookmarks = manga.bookmarks.sorted();
        
        // Extract the manga to tmp
        manga.extractToTmpFolder();
        
        // For every bookmark in manga.bookmarks...
        for (_, currentBookmark) in manga.bookmarks.enumerated() {
            // Add a menu item to the bookmarks dropdown with the title being Page and the bookmarked page
            bookmarksDropDown.addItem(withTitle: "Page " + String(currentBookmark + 1));
            
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
        for (currentIndex, currentTag) in manga.tags.enumerated() {
            // If this is not the last one...
            if(currentIndex < manga.tags.count - 1) {
                // Append the current tag and ", "
                tagsTextField.stringValue.append(currentTag + ", ");
            }
            // If this is the last one...
            else {
                // Append just the current tag
                tagsTextField.stringValue.append(currentTag);
            }
        }
        
        // Set the group text field's string value to the group of the manga
        groupTokenTextField.stringValue = manga.group;
    }
    
    func getMangaFromGrid(_ notification : Notification) {
        // Print to the log that we are receiving a manga from the grid
        print("KMEditMangaViewController: Receiving manga \"" + ((notification.object as? KMManga)?.title)! + "\" from manga grid");
        
        // Set manga to the notifications manga
        manga = (notification.object as? KMManga)!;
        
        // Remove the observer so we dont get duplicate calls
        NotificationCenter.default.removeObserver(self);
        
        // Fill in the fields with our new data
        fillValuesFromManga();
    }
    
    override func viewWillDisappear() {
        // Post the notification that the popover is closing
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMEditMangaViewController.Closing"), object: nil);
    }
    
    func styleWindow() {
        // Set the background visual effect views material to dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.dark;
    }
}
