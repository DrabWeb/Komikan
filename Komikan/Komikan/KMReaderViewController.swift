//
//  KMReaderViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderViewController: NSViewController {

    // The main window for the reader
    var readerWindow : NSWindow = NSWindow();
    
    // The image view for the reader window
    @IBOutlet weak var readerImageView: NSImageView!
    
    // The visual effect view for the reader windows titlebar
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    // The visual effect for the reader panel
    @IBOutlet weak var readerPanelVisualEffectView: NSVisualEffectView!
    
    // The label on the reader panel that shows what page you are on and how many pages there are
    @IBOutlet weak var readerPageNumberLabel: NSTextField!
    
    // The button on the reader panel that lets you jump to a page
    @IBOutlet weak var readerPageJumpButton: NSButton!
    
    var inspectorController: NSWindowController?
    // When readerPageJumpButton is pressed...
    @IBAction func readerPageJumpButtonPressed(sender: AnyObject) {
        if(readerPageJumpView.hidden) {
            // Prompt the user to jump to a page
            promptToJumpToPage();
        }
    }
    
    // The button on the reader panel that lets you bookmark the current page
    @IBOutlet weak var readerBookmarkButton: NSButton!
    
    // When readerBookmarkButton is pressed...
    @IBAction func readerBookmarkButtonPressed(sender: AnyObject) {
        // Bookmark the current page
        bookmarkCurrentPage();
    }
    
    // The button on the reader panel that brings you to the settings for the reader with color controls among other things
    @IBOutlet weak var readerSettingsButton: NSButton!
    
    // When readerSettingsButton is pressed...
    @IBAction func readerSettingsButtonPressed(sender: AnyObject) {
        
    }
    
    // The view hat holds the page jump dialog
    @IBOutlet weak var readerPageJumpView: NSView!
    
    // The visual effect view for the background of the page jump dialog
    @IBOutlet weak var readerPageJumpVisualEffectView: NSVisualEffectView!
    
    // The text field for the page to jump to
    @IBOutlet weak var readerPageJumpNumberField: NSTextField!
    
    // WHen the user presses enter in readerPageJumpNumberField...
    @IBAction func readerPageJumpNumberFieldInteracted(sender: AnyObject) {
        // Close the dialog
        closeJumpToPageDialog();
    }
    
    // The manga we have open
    var manga : KMManga = KMManga();
    
    var openPanel : NSOpenPanel = NSOpenPanel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Start the 0.1 second loop for the mouse hovering
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("mouseHoverHandling"), userInfo: nil, repeats:true);
        
        // Testing reader.
        // Dont allow the open panel to allow multiple image selections
        openPanel.allowsMultipleSelection = false;
        
        // Set the open panels allowed file types to only CBZ and CBR(CBR is disabled until I can get it to work, need a RAR library for swift)
        openPanel.allowedFileTypes = ["cbz"/*, "cbr"*/];
        
        // Show the open panel modal
        openPanel.runModal();
        
        openManga(openPanel.URL!, page: 0);
    }
    
    func openManga(mangaPath : NSURL, page : Int) {
        // Create a variable to say if we can open the passed file(Default is false)
        var canOpen : Bool = false;
        
        // Create a variable to store the files URL without %20s, because NSURL adds them and I dont know how to stop that from happening
        let mangaPathWithoutOnlineMarkers : String = KMFileUtilities().removeURLEncoding(mangaPath.absoluteString);
        
        // Check if it is a CBZ or a CBR(The file formats we support)
        let mangaExtension : String = KMFileUtilities().getFileExtension(mangaPath);
        
        // Set manga.directory to mangaPath
        manga.directory = mangaPath.absoluteString;
        
        // If the manga we are trying to open is a CBZ or a CBR...
        if(mangaExtension == "cbz" || mangaExtension == "cbr") {
            // Say we can open it
            canOpen = true;
        }
        
        // If we cant open it...
        if(!canOpen) {
            print("Unsupported extension \"" + mangaExtension + "\". Unable to open \"" + mangaPathWithoutOnlineMarkers + "\"");
        }
        // If we can open it...
        else {
            // Open it!
            // Print to the log what we are opening
            print("Opening \"" + mangaPathWithoutOnlineMarkers + "\"");
            
            // Reset the mangas pages
            manga.pages = [NSImage()];
            
            // Set the mangas title to the manga we are openings title
            manga.title = KMFileUtilities().getFileNameWithoutExtension(mangaPath);
            
            // Set the windows title to match the mangas name
            readerWindow.title = manga.title;
            
            // Set mangaDirectory to /tmp/komikan/komikanmanga-(Archive name)
            manga.tmpDirectory += manga.title + "/";
            
            // Unzip the manga we are opening to /tmp/komikanmanga
            WPZipArchive.unzipFileAtPath(mangaPathWithoutOnlineMarkers.stringByReplacingOccurrencesOfString("file://", withString: ""), toDestination: manga.tmpDirectory);
            
            // Some archives will create a __MACOSX folder in the extracted folder, lets delete that
            do {
                // Remove the possible __MACOSX folder
                try NSFileManager().removeItemAtPath(manga.tmpDirectory + "/__MACOSX");
                
                // Print to the log that we deleted it
                print("Deleted the __MACOSX folder in \"" + manga.title + "\"");
            // If there is an error...
            } catch _ as NSError {
                // Print to the log that there is no __MACOSX folder to delete
                print("No __MACOSX folder to delete in \"" + manga.title + "\"");
            }
            
            // Set openMangaPages to all the pages in /tmp/komikanmanga
            do {
                // For every file in /tmp/komikanmanga...
                for currentPage in try NSFileManager().contentsOfDirectoryAtPath(manga.tmpDirectory).enumerate() {
                    // Print to the log what file we found
                    print("Found page \"" + currentPage.element + "\"");
                    
                    // Append this image to the openMangaPages array
                    manga.pages.append(NSImage(contentsOfFile: manga.tmpDirectory + currentPage.element)!);
                }
            // If there is an error...
            } catch let error as NSError {
                // Print the error description to the log
                print(error.description);
            }
            
            // Remove the first image in openMangaPages(Its always nil for no reason)
            manga.pages.removeAtIndex(0);
            
            // Set mangaPageCount
            manga.pageCount = manga.pages.count;
            
            // Jump to the page we said to start at
            jumpToPage(page, round: false);
            
            // Setup the menubar items actions
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.nextPageMenubarItem.action = Selector("nextPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.previousPageMenubarItem.action = Selector("previousPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.jumpToPageMenuItem.action = Selector("promptToJumpToPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.action = Selector("bookmarkCurrentPage");
        }
    }
    
    func isPageBookmarked(page : Int) -> Bool {
        // Is the page bookmarked?
        var bookmarked : Bool = false;
        
        // Iterate through manga.bookmarks
        for (_, bookmarksElement) in manga.bookmarks.enumerate() {
            // If the current element we are iterating is equal to the page we are wanting to see if it is bookmarked...
            if(bookmarksElement == page) {
                // Set bookmarked to true
                bookmarked = true;
            }
        }
        
        // Return bookmarked
        return bookmarked;
    }
    
    // Calls bookmarkPage with the current page number
    func bookmarkCurrentPage() {
        // Call bookmarkPage with the current page number
        bookmarkPage(manga.currentPage);
    }
    
    // Bookmarks the current page(Starts at 0). If it is already bookmarked, it removes that bookmark
    func bookmarkPage(page : Int) {
        // Is the page alrady bookmarked?
        let alreadyBookmarked = isPageBookmarked(page);
        
        // If the page is already bookmarked...
        if(alreadyBookmarked) {
            // Remove that element
            manga.bookmarks.removeAtIndex(page);
            
            // Print to the log that we removed that bookmark
            print("Removed bookmarked for page " + String(page + 1) + " in \"" + manga.title + "\"");
        }
        else {
            // Append the page we are trying to bookmark
            manga.bookmarks.append(page);
            
            // Print to the log that we are bookmarking this page
            print("Bookmarked page " + String(page + 1) + " in \"" + manga.title + "\"");
        }
        
        // Update the page page to show that the page is bookmarked
        updatePage();
    }
    
    // Brings up the dialog for the user to jump to a page
    func promptToJumpToPage() {
        // Reset the page jump text fields value
        readerPageJumpNumberField.stringValue = "";
        
        // Show the view
        readerPageJumpView.hidden = false;
        
        // Select the text field
        readerWindow.makeFirstResponder(readerPageJumpNumberField);
        
        // Animate in the vibrancy view
        readerPageJumpVisualEffectView.alphaValue = 1;
    }
    
    // Closes the dialog that prompts the user to jump to a page, and jumps to the inputted page
    func closeJumpToPageDialog() {
        // Fade out the view
        readerPageJumpVisualEffectView.animator().alphaValue = 0;
        
        // Do the 0.2 second wait to hide the page jump dialog
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("hideJumpToPageDialog"), userInfo: nil, repeats:false);
        
        // Jump to the inputted page
        jumpToPage(readerPageJumpNumberField.integerValue - 1, round: true);
    }
    
    // Actually hides the jump to page dialog
    func hideJumpToPageDialog() {
        // Hide the view
        readerPageJumpView.hidden = true;
    }
    
    func nextPage() {
        // If we were to add 1 to mangaCurrentPage and it would be less than the openMangaPages count...
        if(manga.currentPage + 1 < manga.pageCount) {
            // Print to the log that we are going to the next page
            print("Loading next page in \"" + manga.title + "\"");
            
            // Add 1 to mangaCurrentPage
            manga.currentPage++;
            
            // Load the new page
            updatePage();
        }
        else {
            // Print to the log that there is no next page
            print("There is no next page in \"" + manga.title + "\"");
        }
    }
    
    func previousPage() {
        // If we were to subtract 1 from mangaCurrentPage and it would be greater than 0...
        if(manga.currentPage - 1 > -1) {
            // Print to the log that we are going to the previous page
            print("Loading previous page in \"" + manga.title + "\"");
            
            // Subtract 1 from mangaCurrentPage
            manga.currentPage--;
            
            // Load the new page
            updatePage();
        }
        else {
            // Print to the log that there is no previous page
            print("There is no previous page in \"" + manga.title + "\"");
        }
    }
    
    // The page number starts at 0, keep that in mind
    func jumpToPage(page : Int, round : Bool) {
        // See if the page we are trying to jump to is existant
        if(page >= 0 && page < manga.pageCount) {
            // Print to the log that we are jumping to a page
            print("Jumping to page " + String(page) + " in \"" + manga.title + "\"");
            
            // Set the current page to the page we want to jump to
            manga.currentPage = page;
            
            // Load the new page
            updatePage();
        }
        else {
            // If we said to round off the number...
            if(round) {
                // Create a variable to store the page number we will round it off to
                var roundedPage : Int = page;
                
                // If roundedPage is bigger than the page count...
                if(roundedPage > manga.pageCount) {
                    // Set roundedPage to the page count minus 1
                    roundedPage = manga.pageCount - 1;
                }
                // If roundedPage is less than 0
                else if(roundedPage < 0) {
                    // Set roundedPage to 0
                    roundedPage = 0;
                }
                
                // Print to the log that we are jumping to roundedPage, and what page that is
                print("Jumping to rounded off page " + String(roundedPage) + " in \"" + manga.title + "\"");
                
                // Set the current page to roundedPage
                manga.currentPage = roundedPage;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that we cant jump to that page
                print("Cant jump to page " + String(page) + " in \"" + manga.title + "\"");
            }
        }
    }
    
    // Updates the manga page image view to the new page (Specified by mangaCurrentPage) and updates the reader panel labels value
    func updatePage() {
        // Load the new page
        readerImageView.image = manga.pages[manga.currentPage];
        
        // Set the reader panels labels value
        readerPageNumberLabel.stringValue = String(manga.currentPage + 1) + "/" + String(manga.pageCount);
        
        let pageBookmarked = isPageBookmarked(manga.currentPage);
        
        // If the page is bookmarked...
        if(pageBookmarked) {
            // Set the manga bookmarks button to have a border
            readerBookmarkButton.alphaValue = 1;
            
            // Also add a check mark next to the bookmark menu item
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.state = 1;
        }
        else {
            // Set the manga bookmarks button alpha value to 0.2, as to indicate to the user this page is not boomarked
            readerBookmarkButton.animator().alphaValue = 0.2;
            
            // Also remove the check mark next to the bookmark menu item
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.state = 0;
        }
    }
    
    func mouseHoverHandling() {
        // A bool to say if we are hovering the window
        var insideWindow : Bool = false;
        
        // Are we fullscreen?
        var fullscreen : Bool = false;
        
        // If the window is in fullscreen(Window height matches the screen height(This is really cheaty and I need to find a better way to do this))
        if(readerWindow.frame.height == NSScreen.mainScreen()?.frame.height) {
            // Say we are in fullscreen
            fullscreen = true;
        }
        
        // Create a new CGEventRef, for the mouse position
        let mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        let mousePosition = CGEventGetLocation(mouseEvent);
        
        // Store the windows frame temporarly, so we dont retype a millino times
        let windowFrame : NSRect! = readerWindow.frame;
        
        // Create a variable to store the cursors location y where 0 0 is the bottom left
        let pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
        
        // if we arent fullscreen...
        if(!fullscreen) {
            // If the mouse position is inside the window on the x...
            if(mousePosition.x > windowFrame.origin.x && mousePosition.x < windowFrame.origin.x + windowFrame.width) {
                // If the mouse position is inside the window on the y...
                if(pointY > windowFrame.origin.y && pointY < windowFrame.origin.y + windowFrame.height) {
                    // The cursor is inside the window, say so
                    insideWindow = true;
                }
            }
            
            // If the cursor is inside the window...
            if(insideWindow) {
                // Fade in the titlebar
                fadeInTitlebar();
            }
                // If the cursor is outside the window...
            else {
                // Fade out the titlebar
                fadeOutTitlebar();
            }
        }
        else {
            // Hide the titlebar visual effect view
            titlebarVisualEffectView.alphaValue = 0;
            
            // Show the window titlebar
            readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 1;
            
            // Hide the reader panel
            readerPanelVisualEffectView.alphaValue = 0;
        }
    }
    
    func fadeOutTitlebar() {
        // Use the animator to fade out the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 0;
        
        // Use the animator to fade out the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 0;
        
        // Use the animator to fade out the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 0;
    }
    
    func fadeInTitlebar() {
        // Use the animator to fade in the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 1;
        
        // Use the animator to fade in the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 1;
        
        // Use the animator to fade in the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 1;
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 0;
        
        // Hide the reader panels visual effect view
        readerPanelVisualEffectView.alphaValue = 0;
        
        // Set it to have a full size content view
        readerWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        readerWindow.titlebarAppearsTransparent = true;
        
        // Set the appearance
        readerWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        
        // Set the window background color
        readerWindow.backgroundColor = NSColor.blackColor();
    }
}
