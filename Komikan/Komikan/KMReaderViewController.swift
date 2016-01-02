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
        // Prompt the user to jump to a page
        promptToJumpToPage();
    }
    
    // The button on the reader panel that lets you bookmark the current page
    @IBOutlet weak var readerBookmarkButton: NSButton!
    
    // When readerBookmarkButton is pressed...
    @IBAction func readerBookmarkButtonPressed(sender: AnyObject) {
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
    
    // The pages of manga we have open
    var openMangaPages : [NSImage] = [NSImage()];
    
    // The title of the currently open manga
    var mangaTitle : String = "Title failed to load";
    
    // The unique identifier for this mangas /tmp/folder
    var mangaDirectory : String = "/komikanmanga-";
    
    // The current manga page
    var mangaCurrentPage : Int = 0;
    
    // The amount of pages in the currently open manga
    var mangaPageCount : Int = 0;
    
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
        
        // Set the open panels allowed file types to only CBZ and CBR
        openPanel.allowedFileTypes = ["cbz", "cbr"];
        
        // Show the open panel modal
        openPanel.runModal();
        
        openManga(openPanel.URL!, page: 0);
    }
    
    func openManga(mangaPath : NSURL, page : Int) {
        // Create a variable to say if we can open the passed file(Default is false)
        var canOpen : Bool = false;
        
        // Create a variable to store the files URL without %20s, because NSURL adds them and I dont know how to stop that from happening
        var mangaPathWithoutOnlineMarkers : String = KMFileUtilities().removeURLEncoding(mangaPath.absoluteString);
        
        // Check if it is a CBZ or a CBR(The file formats we support)
        var mangaExtension : String = KMFileUtilities().getFileExtension(mangaPath);
        
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
            
            // Reset openMangaPages
            openMangaPages = [NSImage()];
            
            // Set mangaTitle to the manga we are openings title
            mangaTitle = KMFileUtilities().getFileNameWithoutExtension(mangaPath);
            
            // Set the windows title to match the mangas name
            readerWindow.title = mangaTitle;
            
            // Set mangaDirectory to /tmp/komikan/komikanmanga-(Archive name)
            mangaDirectory += mangaTitle + "/";
            
            // Unzip the manga we are opening to /tmp/komikanmanga
            WPZipArchive.unzipFileAtPath(mangaPathWithoutOnlineMarkers.stringByReplacingOccurrencesOfString("file://", withString: ""), toDestination: "/tmp/komikan/" + mangaDirectory);
            
            // Some archives will create a __MACOSX folder in the extracted folder, lets delete that
            do {
                // Remove the possible __MACOSX folder
                try NSFileManager().removeItemAtPath("/tmp/komikan/" + mangaDirectory + "/__MACOSX");
                
                // Print to the log that we deleted it
                print("Deleted the __MACOSX folder in \"" + mangaTitle + "\"");
            // If there is an error...
            } catch let _ as NSError {
                // Print to the log that there is no __MACOSX folder to delete
                print("No __MACOSX folder to delete in \"" + mangaTitle + "\"");
            }
            
            // Set openMangaPages to all the pages in /tmp/komikanmanga
            do {
                // For every file in /tmp/komikanmanga...
                for currentPage in try NSFileManager().contentsOfDirectoryAtPath("/tmp/komikan/" + mangaDirectory).enumerate() {
                    // Print to the log what file we found
                    print("Found page \"" + currentPage.element + "\"");
                    
                    // Append this image to the openMangaPages array
                    openMangaPages.append(NSImage(contentsOfFile: "/tmp/komikan/" + mangaDirectory + currentPage.element)!);
                }
            // If there is an error...
            } catch let error as NSError {
                // Print the error description to the log
                print(error.description);
            }
            
            // Remove the first image in openMangaPages(Its always nil for no reason)
            openMangaPages.removeAtIndex(0);
            
            // Set mangaPageCount
            mangaPageCount = openMangaPages.count;
            
            // Set the current manga page to the page we said to open to
            mangaCurrentPage = page;
            
            // Open the first image, so we open on the cover
            updatePage();
            
            // Setup the menubar items actions
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.nextPageMenubarItem.action = Selector("nextPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.previousPageMenubarItem.action = Selector("previousPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.jumpToPageMenuItem.action = Selector("promptToJumpToPage");
        }
    }
    
    func nextPage() {
        // If we were to add 1 to mangaCurrentPage and it would be less than the openMangaPages count...
        if(mangaCurrentPage + 1 < mangaPageCount) {
            // Print to the log that we are going to the next page
            print("Loading next page in \"" + mangaTitle + "\"");
            
            // Add 1 to mangaCurrentPage
            mangaCurrentPage++;
            
            // Load the new page
            updatePage();
        }
        else {
            // Print to the log that there is no next page
            print("There is no next page in \"" + mangaTitle + "\"");
        }
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
        readerPageJumpVisualEffectView.animator().alphaValue = 1;
    }
    
    // Closes the dialog that prompts the user to jump to a page, and jumps to the inputted page
    func closeJumpToPageDialog() {
        // Fade out the view
        readerPageJumpVisualEffectView.animator().alphaValue = 0;
        
        // Do the 0.2 second wait to hide the page jump dialog
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("hideJumpToPageDialog"), userInfo: nil, repeats:false);
        
        // Jump to the inputted page
        jumpToPage(readerPageJumpNumberField.integerValue - 1);
    }
    
    // Actually hides the jump to page dialog
    func hideJumpToPageDialog() {
        // Hide the view
        readerPageJumpView.hidden = true;
    }
    
    func previousPage() {
        // If we were to subtract 1 from mangaCurrentPage and it would be greater than 0...
        if(mangaCurrentPage - 1 > -1) {
            // Print to the log that we are going to the previous page
            print("Loading previous page in \"" + mangaTitle + "\"");
            
            // Subtract 1 from mangaCurrentPage
            mangaCurrentPage--;
            
            // Load the new page
            updatePage();
        }
        else {
            // Print to the log that there is no previous page
            print("There is no previous page in \"" + mangaTitle + "\"");
        }
    }
    
    // The page number starts at 0, keep that in mind
    func jumpToPage(page : Int) {
        // See if the page we are trying to jump to is existant
        if(page > 0 && page < mangaPageCount) {
            // Print to the log that we are jumping to a page
            print("Jumping to page " + String(page) + " in \"" + mangaTitle + "\"");
            
            // Set the current page to the page we want to jump to
            mangaCurrentPage = page;
            
            // Load the new page
            updatePage();
        }
        else {
            // Print to the log that we cant jump to that page
            print("Cant jump to page " + String(page) + " in \"" + mangaTitle + "\"");
        }
    }
    
    // Updates the manga page image view to the new page (Specified by mangaCurrentPage) and updates the reader panel labels value
    func updatePage() {
        // Load the new page
        readerImageView.image = openMangaPages[mangaCurrentPage];
        
        // Set the reader panels labels value
        readerPageNumberLabel.stringValue = String(mangaCurrentPage + 1) + "/" + String(mangaPageCount);
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
        var mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        var mousePosition = CGEventGetLocation(mouseEvent);
        
        // Store the windows frame temporarly, so we dont retype a millino times
        var windowFrame : NSRect! = readerWindow.frame;
        
        // Create a variable to store the cursors location y where 0 0 is the bottom left
        var pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
        
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
