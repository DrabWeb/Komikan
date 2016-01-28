//
//  KMReaderViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa
import Quartz

// readerImagesCGContainer.contentFilters[0].setValue(#, forKey: "inputSaturation");
// readerImagesCGContainer.contentFilters[0].setValue(#, forKey: "inputBrightness");
// readerImagesCGContainer.contentFilters[0].setValue(#, forKey: "inputContrast");
// readerImagesCGContainer.contentFilters[1].setValue(#, forKey: "inputSharpness");

class KMReaderViewController: NSViewController {

    // The main window for the reader
    var readerWindow : NSWindow = NSWindow();
    
    // This view manages the CG controls of the readers images(Contrast, brightness, ETC.)
    @IBOutlet weak var readerImagesCGContainer: NSView!
    
    // The image view for the reader window
    @IBOutlet weak var readerImageView: NSImageView!
    
    // The stack view for dual page mode
    @IBOutlet weak var dualPageStackView: NSStackView!
    
    // The left page image view for dual page mode
    @IBOutlet weak var leftPageReaderImageView: NSImageView!
    
    // The right page image view for dual page mode
    @IBOutlet weak var rightPageReaderImageView: NSImageView!
    
    // The visual effect view for the reader windows titlebar
    @IBOutlet weak var titlebarVisualEffectView: NSVisualEffectView!
    
    // The view that encloses the reader panel and makes it round
    @IBOutlet weak var readerPanelCornerRounding: KMReaderPanelView!
    
    // The visual effect for the reader panel
    @IBOutlet weak var readerPanelVisualEffectView: NSVisualEffectView!
    
    // The visual effect view for the reader controls panel(Color, sharpness ETC.)
    @IBOutlet weak var readerControlsPanelVisualEffectView: NSVisualEffectView!
    
    // When we press the save button in the reader control panel...
    @IBAction func readerControlPanelSaveButtonPressed(sender: AnyObject) {
        readerControlsOpen = false;
        
        closeControlsPanel();
    }
    
    // When we press the reset button in the reader control panel...
    @IBAction func readerControlPanelResetButtonPressed(sender: AnyObject) {
        // Reset the values to default
        resetCGValues();
    }
    
    // The slider in the control panel that controls the readers saturation
    @IBOutlet weak var readerControlPanelSaturationSlider : NSSlider!
    
    // When we interact with readerControlPanelSaturationSlider...
    @IBAction func readerControlPanelSaturationSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Saturation: " + String(readerControlPanelSaturationSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        readerImagesCGContainer.contentFilters[0].setValue(readerControlPanelSaturationSlider.floatValue, forKey: "inputSaturation");
    }
    
    // The slider in the control panel that controls the readers brightness
    @IBOutlet weak var readerControlPanelBrightnessSlider : NSSlider!
    
    // When we interact with readerControlPanelBrightnessSlider...
    @IBAction func readerControlPanelBrightnessSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Brightness: " + String(readerControlPanelBrightnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        readerImagesCGContainer.contentFilters[0].setValue(readerControlPanelBrightnessSlider.floatValue, forKey: "inputBrightness");
    }
    
    // The slider in the control panel that controls the readers contrast
    @IBOutlet weak var readerControlPanelContrastSlider : NSSlider!
    
    // When we interact with readerControlPanelContrastSlider...
    @IBAction func readerControlPanelContrastSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Contrast: " + String(readerControlPanelContrastSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        readerImagesCGContainer.contentFilters[0].setValue(readerControlPanelContrastSlider.floatValue, forKey: "inputContrast");
    }
    
    // The slider in the control panel that controls the readers sharpness
    @IBOutlet weak var readerControlPanelSharpnessSlider : NSSlider!
    
    // When we interact with readerControlPanelSharpnessSlider...
    @IBAction func readerControlPanelSharpnessSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Sharpness: " + String(readerControlPanelSharpnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        readerImagesCGContainer.contentFilters[1].setValue(readerControlPanelSharpnessSlider.floatValue, forKey: "inputSharpness");
    }
    
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
    
    // Do we have the reader controls open?
    var readerControlsOpen : Bool = false;
    
    // The button on the reader panel that brings you to the settings for the reader with color controls among other things
    @IBOutlet weak var readerSettingsButton: NSButton!
    
    // When readerSettingsButton is pressed...
    @IBAction func readerSettingsButtonPressed(sender: AnyObject) {
        // Disabled for now, need to find out how to apply filters directly to an NSImage
//        // Say that the controls panel is open
//        readerControlsOpen = true;
//        
//        // Open the controls panel
//        openControlsPanel();
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
    
    // Are we wanting to read in dual page mode?
    var dualPage : Bool = false;
    
    // The direction we are reading(Default Right to Left)
    var dualPageDirection : KMDualPageDirection = KMDualPageDirection.RightToLeft;
    
    // Are we fullscreen?
    var isFullscreen : Bool = false;
    
    // The NSTimer to handle the mouse hovering when we arent in fullscreen
    var mouseHoverHandlingTimer : NSTimer = NSTimer();
    
    // The NSTimer to handle the mouse hovering when we are in fullscreen
    var mouseHoverHandlingFullscreenTimer : NSTimer = NSTimer();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Start the 0.1 second loop for the mouse hovering
        mouseHoverHandlingTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("mouseHoverHandling"), userInfo: nil, repeats:true);
        
        // Start the 0.1 second loop for the fullscreen mouse hover handling
        mouseHoverHandlingFullscreenTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("fullscreenMouseHoverHandling"), userInfo: nil, repeats:true);
    }
    
    func openManga(openingManga : KMManga, page : Int) {
        manga = openingManga;
        
        // Print to the log what we are opening
        print("Opening \"" + manga.title + "\"");
    
        // Set the windows title to match the mangas name
        readerWindow.title = manga.title;
        
        // Extract the archive and get the info from it
        manga.extractToTmpFolder();
        
        // Jump to the page we said to start at
        jumpToPage(page, round: false);
        
        // Set the reader window frame to the first images frame
        readerWindow.setFrame(NSRect(x: 0, y: 0, width: manga.pages[0].size.width, height: manga.pages[0].size.height), display: false);
        
        // Center the window
        readerWindow.center();
        
        // Setup the menubar items actions
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.nextPageMenubarItem.action = Selector("nextPage");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.previousPageMenubarItem.action = Selector("previousPage");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.jumpToPageMenuItem.action = Selector("promptToJumpToPage");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.action = Selector("bookmarkCurrentPage");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.dualPageMenuItem.action = Selector("toggleDualPage");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.fitWindowToPageMenuItem.action = Selector("fitWindowToManga");
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.switchDualPageDirectionMenuItem.action = Selector("switchDualPageDirection");
    }
    
    func switchDualPageDirection() {
        // If we are reading Right to Left...
        if(dualPageDirection == KMDualPageDirection.RightToLeft) {
            // Switch the direction to Left to Right
            dualPageDirection = KMDualPageDirection.LeftToRight;
        }
        // If we are reading Left to Right...
        else if(dualPageDirection == KMDualPageDirection.LeftToRight) {
            // Switch the direction to Right to Left
            dualPageDirection = KMDualPageDirection.RightToLeft;
        }
        
        // Update the page
        updatePage();
    }
    
    func fitWindowToManga() {
        // If we are in dualPage mode...
        if(dualPage && !isFullscreen) {
            var leftImageSize : NSSize = NSSize();
            var rightImageSize : NSSize = NSSize();
            
            // If we add 1 to manga.currentPage and there would be an image at that index in manga.pages...
            if(manga.currentPage + 1 < manga.pages.count) {
                // Set leftImageSize to be the currentPage + 1's size
                leftImageSize = manga.pages[manga.currentPage + 1].size;
            }
            else {
                // Set leftImageSize to be the other pages size
                leftImageSize = manga.pages[manga.currentPage].size;
            }
            
            // Set rightImageSize to be the ucrrent pages image size
            rightImageSize = manga.pages[manga.currentPage].size;
            
            // Set the reader windows frame to be two times the width of the current open page
            readerWindow.setFrame(NSRect(x: 0, y: 0, width: leftImageSize.width + rightImageSize.width, height: rightImageSize.height), display: false);
            
            readerWindow.center();
        }
        else if(!dualPage && !isFullscreen) {
            // Set the reader windows frame to be the reader image views image size
            readerWindow.setFrame(NSRect(x: 0, y: 0, width: (readerImageView.image?.size.width)!, height: (readerImageView.image?.size.height)!), display: false);
            
            // Center the window
            readerWindow.center();
        }
    }
    
    // Resets things like the Contrast, Saturation, ETC.
    func resetCGValues() {
        // Update the sliders
        readerControlPanelSaturationSlider.floatValue = 1;
        readerControlPanelBrightnessSlider.floatValue = 0;
        readerControlPanelContrastSlider.floatValue = 1;
        readerControlPanelSharpnessSlider.floatValue = 0.4;
        
        // Reset the values
        readerImagesCGContainer.contentFilters[0].setValue(1, forKey: "inputSaturation");
        readerImagesCGContainer.contentFilters[0].setValue(0, forKey: "inputBrightness");
        readerImagesCGContainer.contentFilters[0].setValue(1, forKey: "inputContrast");
        readerImagesCGContainer.contentFilters[1].setValue(0.4, forKey: "inputSharpness");
    }
    
    // Opens the control panel for the user to modify the Saturation, Contrast, ETC.
    func openControlsPanel() {
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerate() {
            // Disable it(Cast it to a NSControl first so we can disable it)
            (currentItem as! NSControl).enabled = false;
        }
        
        // Animate out the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 0;
        
        // Animate in the reader control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 1;
    }
    
    // Closes the control panel for the user to modify the Saturation, Contrast, ETC.
    func closeControlsPanel() {
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerate() {
            // Enable it(Cast it to a NSControl first so we can enable it)
            (currentItem as! NSControl).enabled = true;
        }
        
        // Animate in the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 1;
        
        // Animate out the control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 0;
    }
    
    func toggleDualPage() {
        // Toggle the dualPage bool
        dualPage = !dualPage;
        
        // Fit the window to match the mangas size
        fitWindowToManga();
        
        // If we are in dualpage mode...
        if(dualPage) {
            print(manga.currentPage % 2);
            // If the current page number is even...
            if(manga.currentPage % 2 == 1) {
                // Subtract one from current page to make it odd
                manga.currentPage = manga.currentPage - 1;
            }
        }
        
        // Update the page
        updatePage();
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
        // A bool to say if we already bookmarked this page
        var alreadyBookmarked = false;
        
        // Iterate through mangaBookmarks
        for (bookmarksIndex, bookmarksElement) in manga.bookmarks.enumerate() {
            // If the current element we are iterating is equal to the page we are trying to bookmark...
            if(bookmarksElement == page) {
                // Remove that element
                manga.bookmarks.removeAtIndex(bookmarksIndex);
                
                // Say it was already bookmarked
                alreadyBookmarked = true;
                
                // Print to the log that we removed that bookmark
                print("Removed bookmarked for page " + String(page + 1) + " in \"" + manga.title + "\"");
            }
        }
        
        // If we didnt already bookmark this page...
        if(!alreadyBookmarked) {
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
        if(dualPage) {
            // If we were to add 2 to mangaCurrentPage and it would be less than the openMangaPages count...
            if(manga.currentPage + 2 < manga.pageCount) {
                // Print to the log that we are going to the next page
                print("Loading next page in \"" + manga.title + "\"");
                
                // Add 2 to mangaCurrentPage
                manga.currentPage += 2;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that we have finished the book and are marking it as read
                print("Finished \"" + manga.title + "\", marking it as read and exiting");
                
                // Set the mangas read variable to true
                manga.read = true;
                
                // Close the window
                readerWindow.close();
                
                // Update the grid(For some reason I have to call this function instead of the update grid one)
                NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Saving", object: manga);
            }
        }
        else {
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
                // Print to the log that we have finished the book and are marking it as read
                print("Finished \"" + manga.title + "\", marking it as read and exiting");
                
                // Set the mangas read variable to true
                manga.read = true;
                
                // Close the window
                readerWindow.close();
                
                // Update the grid(For some reason I have to call this function instead of the update grid one)
                NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Saving", object: manga);
            }
        }
    }
    
    func previousPage() {
        if(dualPage) {
            // If we were to subtract 2 from mangaCurrentPage and it would be greater than 0...
            if(manga.currentPage - 2 > -1) {
                // Print to the log that we are going to the previous page
                print("Loading previous page in \"" + manga.title + "\"");
                
                // Subtract 2 from mangaCurrentPage
                manga.currentPage -= 2;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that there is no previous page
                print("There is no previous page in \"" + manga.title + "\"");
            }
        }
        else {
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
        
        // If we are in dual page mode...
        if(dualPage) {
            // If we add 1 to the current page and it wont be above the page count...
            if(!(manga.currentPage + 1 < manga.pages.count)) {
                // Set the label to be "(Current page + 1) / (Page count)"
                readerPageNumberLabel.stringValue = String(manga.currentPage + 1) + "/" + String(manga.pageCount);
            }
            else {
                // Set the label to be "(Current page + 1) - (Current page + 2) / (Page count)"
                readerPageNumberLabel.stringValue = String(manga.currentPage + 1) + " - " + String(manga.currentPage + 2) + "/" + String(manga.pageCount);
            }
        }
        else {
            // Set the reader panels labels value
            readerPageNumberLabel.stringValue = String(manga.currentPage + 1) + "/" + String(manga.pageCount);
        }
        
        // Is the current page bookmarked?
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
        
        // If we are in dual page mode...
        if(dualPage) {
            // Hide the one page image view
            readerImageView.hidden = true;
            
            // Show the dual page stack view for dual page mode
            dualPageStackView.hidden = false;
            
            // If we are reading from Right to Left...
            if(dualPageDirection == KMDualPageDirection.RightToLeft) {
                // If we add 1 to manga.currentPage and there would be an image at that index in manga.pages...
                if(manga.currentPage + 1 < manga.pages.count) {
                    // Set the left sides image to the current page + 1
                    leftPageReaderImageView.image = manga.pages[manga.currentPage + 1];
                }
                else {
                    // Set the left image views to nothing
                    leftPageReaderImageView.image = NSImage();
                }
                
                // Set the right sides image to the current page
                rightPageReaderImageView.image = manga.pages[manga.currentPage];
            }
            // If we are reading from Left to Right...
            else if(dualPageDirection == KMDualPageDirection.LeftToRight) {
                // If we add 1 to manga.currentPage and there would be an image at that index in manga.pages...
                if(manga.currentPage + 1 < manga.pages.count) {
                    // Set the right sides image to the ucrrent page + 1
                    rightPageReaderImageView.image = manga.pages[manga.currentPage + 1];
                }
                else {
                    // Set the right image views to nothing
                    rightPageReaderImageView.image = NSImage();
                }
                
                // Set the left sides image to the current page
                leftPageReaderImageView.image = manga.pages[manga.currentPage];
            }
        }
        else {
            // Show the one page image view
            readerImageView.hidden = false;
            
            // Hide the dual page stack view
            dualPageStackView.hidden = true;
        }
    }
    
    func fadeOutTitlebarFullscreen() {
        // Hide the cursor
        NSCursor.hide();
        
        // Set cursorHidden to true
        cursorHidden = true;
        
        // Fade out the titlebar
        fadeOutTitlebar();
    }
    
    func fadeInTitlebarFullscreen() {
        // Show the cursor
        NSCursor.unhide();
        
        // Set cursorHidden to false
        cursorHidden = false;
        
        // Fade in the titlebar
        fadeInTitlebar();
    }
    
    // A variable to tell us where the mouse previously was
    var oldMousePosition : CGPoint!;
    
    // The NSTimer to handle fading out the panel when we dont move the mouse
    var fadeTimer : NSTimer = NSTimer();
    
    // Is the cursor hidden(Come on Apple, why isnt this part of NSCursor?)
    var cursorHidden : Bool = false;
    
    func fullscreenMouseHoverHandling() {
        // If we are in fullscreen...
        if(isFullscreen) {
            // Create a new CGEventRef, for the mouse position
            let mouseEvent : CGEventRef = CGEventCreate(nil)!;
            
            // Get the mouse point onscreen from ourEvent
            let mousePosition = CGEventGetLocation(mouseEvent);
            
            // If we have moved the mouse...
            if(mousePosition != oldMousePosition) {
                // Stop the fade timer
                fadeTimer.invalidate();
                
                // Fade in the titlebar(Fullscreen mode)
                fadeInTitlebarFullscreen();
                
                // Store the reader panels frame
                let readerPanelFrame : NSRect = readerPanelCornerRounding.frame;
                
                // Create a variable to store the cursors location y where 0 0 is the bottom left
                let pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
                
                // CReate a bool to indicate if we have the mouse in the reader panel(And set it)
                let insideReaderPanel : Bool = readerPanelFrame.contains(CGPoint(x: mousePosition.x, y: pointY));
                
                // If we arent inside the reader panel...
                if(!insideReaderPanel) {
                    // Fade out the titlebar(Fullscreen mode)
                    fadeTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target:self, selector: Selector("fadeOutTitlebarFullscreen"), userInfo: nil, repeats:false);
                }
            }
            
            // Set oldMousePosition to the current mouse position
            oldMousePosition = mousePosition;
        }
        // If we arent in fullscreen...
        else {
            // If the cursor is still hidden...
            if(cursorHidden) {
                // Show the cursor
                NSCursor.unhide();
            }
        }
    }
    
    func mouseHoverHandling() {
        // Are we fullscreen?
        let fullscreen : Bool = readerWindow.isFullscreen();
        
        // A bool to say if we are hovering the window
        var insideWindow : Bool = false;
        
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
            // If the titlebar visual effect view is hidden...
            if(titlebarVisualEffectView.hidden) {
                // Show the titlebar visual effect view
                titlebarVisualEffectView.hidden = false;
            }
            
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
            titlebarVisualEffectView.hidden = true;
            
            // Show the window titlebar
            readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 1;
        }
        
        // Set isFullscreen to fullscreen
        isFullscreen = fullscreen;
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
        
        // If we dont have the reader controls open...
        if(!readerControlsOpen) {
            // Use the animator to fade in the reader panel
            readerPanelVisualEffectView.animator().alphaValue = 1;
        }
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 0;
        
        // Hide the reader panels visual effect view
        readerPanelVisualEffectView.alphaValue = 0;
        
        // Hide the reader controls panel visual effect view
        readerControlsPanelVisualEffectView.alphaValue = 0;
        
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
