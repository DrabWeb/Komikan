//
//  KMReaderViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa
import Quartz

class KMReaderViewController: NSViewController {

    // The main window for the reader
    var readerWindow : NSWindow = NSWindow();
    
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
    
    /// The save button in the reader control panel
    @IBOutlet weak var readerControlPanelSaveButton: NSButton!
    
    // When we press the save button in the reader control panel...
    @IBAction func readerControlPanelSaveButtonPressed(sender: AnyObject) {
        // Say the controls panel is closed
        readerControlsOpen = false;
        
        // Close the controls panel
        closeControlsPanel();
        
        // Apply the new filter values to all pages(In a new thread so we dont get lots of beachballing for long manga)
        NSThread.detachNewThreadSelector(Selector("updateFiltersForAllPages"), toTarget: self, withObject: nil);
    }
    
    /// The reset button in the reader control panel
    @IBOutlet weak var readerControlPanelResetButton: NSButton!
    
    // When we press the reset button in the reader control panel...
    @IBAction func readerControlPanelResetButtonPressed(sender: AnyObject) {
        // Reset the values to default(In a new thread so we dont beachball in long manga)
        NSThread.detachNewThreadSelector(Selector("resetCGValues"), toTarget: self, withObject: nil);
    }
    
    // The slider in the control panel that controls the readers saturation
    @IBOutlet weak var readerControlPanelSaturationSlider : NSSlider!
    
    // When we interact with readerControlPanelSaturationSlider...
    @IBAction func readerControlPanelSaturationSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Saturation: " + String(readerControlPanelSaturationSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.saturation = CGFloat(readerControlPanelSaturationSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers brightness
    @IBOutlet weak var readerControlPanelBrightnessSlider : NSSlider!
    
    // When we interact with readerControlPanelBrightnessSlider...
    @IBAction func readerControlPanelBrightnessSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Brightness: " + String(readerControlPanelBrightnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.brightness = CGFloat(readerControlPanelBrightnessSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers contrast
    @IBOutlet weak var readerControlPanelContrastSlider : NSSlider!
    
    // When we interact with readerControlPanelContrastSlider...
    @IBAction func readerControlPanelContrastSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Contrast: " + String(readerControlPanelContrastSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.contrast = CGFloat(readerControlPanelContrastSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers sharpness
    @IBOutlet weak var readerControlPanelSharpnessSlider : NSSlider!
    
    // When we interact with readerControlPanelSharpnessSlider...
    @IBAction func readerControlPanelSharpnessSliderInteracted(sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("Sharpness: " + String(readerControlPanelSharpnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.sharpness = CGFloat(readerControlPanelSharpnessSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
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
        // Say that the controls panel is open
        readerControlsOpen = true;
        
        // Open the controls panel
        openControlsPanel();
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
    
    // The original pages for the manga
    var mangaOriginalPages : [NSImage] = [NSImage()];
    
    // Are we wanting to read in dual page mode?
    var dualPage : Bool = false;
    
    // The direction we are reading(Default Right to Left)
    var dualPageDirection : KMDualPageDirection = KMDualPageDirection.RightToLeft;
    
    // Are we fullscreen?
    var isFullscreen : Bool = false;
    
    /// Is the window in the process of closing?
    var closingView : Bool = false;
    
    // The NSTimer to handle the mouse hovering when we arent in fullscreen
    var mouseHoverHandlingTimer : NSTimer = NSTimer();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Start the 0.1 second loop for the mouse hovering
        mouseHoverHandlingTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("mouseHoverHandling"), userInfo: nil, repeats:true);
        
        // Show the reader panel and hide the controls panel
        hideControlsPanelShowReaderPanel();
    }
    
    func openManga(openingManga : KMManga, page : Int) {
        manga = openingManga;
        
        // Print to the log what we are opening
        print("Opening \"" + manga.title + "\"");
    
        // Set the windows title to match the mangas name
        readerWindow.title = manga.title;
        
        // Extract the archive and get the info from it
        manga.extractToTmpFolder();
        
        // Set mangaOriginalPages to the mangas current pages
        mangaOriginalPages = manga.pages;
        
        // If the filters are not default...
        if(manga.saturation != 1 || manga.brightness != 0 || manga.contrast != 1 || manga.sharpness != 0) {
            // Load the saturation values
            readerControlPanelSaturationSlider.floatValue = Float(manga.saturation);
            
            // Load the brightness values
            readerControlPanelBrightnessSlider.floatValue = Float(manga.brightness);
            
            // Load the contrast values
            readerControlPanelContrastSlider.floatValue = Float(manga.contrast);
            
            // Load the sharpness values
            readerControlPanelSharpnessSlider.floatValue = Float(manga.sharpness);
            
            // Update the pages to match the filters
            updateFiltersForAllPages();
        }
        
        // Jump to the page we said to start at
        jumpToPage(page, round: false);
        
        // Resize the window to match the mangas size
        fitWindowToManga();
        
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
    
    override func mouseDown(theEvent: NSEvent) {
        // Create a new CGEventRef, for the mouse position
        let mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        let mousePosition = CGEventGetLocation(mouseEvent);
        
        // Store the titlebars frame
        let titlebarFrame : NSRect = titlebarVisualEffectView.frame;
        
        /// The mouses position on the Y
        let pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
        
        /// The mouses position where 0 0 is the bottom left of the reader window
        let mousePositionFromWindow : CGPoint = NSPoint(x: mousePosition.x - readerWindow.frame.origin.x, y: pointY - readerWindow.frame.origin.y);
        
        /// Is the mouse inside the titlebar?
        var insideTitlebar : Bool = false;
        
        // If the mouse is within the titlebar on the X...
        if(mousePositionFromWindow.x > titlebarFrame.origin.x && mousePositionFromWindow.x < (titlebarFrame.origin.x + titlebarFrame.size.width)) {
            // If the mouse is within the titlebar on the Y...
            if(mousePositionFromWindow.y > titlebarFrame.origin.y && mousePositionFromWindow.y < (titlebarFrame.origin.y + titlebarFrame.size.height)) {
                // Say the mouse is inside the titlebar
                insideTitlebar = true;
            }
        }
        
        // Store the reader control panels frame
        let readerControlPanelFrame : NSRect = readerControlsPanelVisualEffectView.frame;
        
        /// Is the mouse inside the reader control panel?
        var insideReaderControlPanel : Bool = false;
        
        // If the mouse is within the reader control panel on the X...
        if(mousePositionFromWindow.x > readerControlPanelFrame.origin.x && mousePositionFromWindow.x < (readerControlPanelFrame.origin.x + readerControlPanelFrame.size.width)) {
            // If the mouse is within the reader control panel on the Y...
            if(mousePositionFromWindow.y > readerControlPanelFrame.origin.y && mousePositionFromWindow.y < (readerControlPanelFrame.origin.y + readerControlPanelFrame.size.height)) {
                // Say the mouse is inside the reader control panel
                insideReaderControlPanel = true;
            }
        }
        
        // If we arent inside the titlebar and not inside the reader control panel...
        if(!insideTitlebar && !insideReaderControlPanel) {
            // Go to the next page
            nextPage();
        }
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        // Go to the previous page
        previousPage();
    }
    
    /// The swipe cooldown so you cant swipe until the delta X is at 0
    var swipeCooldownOver : Bool = true;
    
    /// For some reason the trackpad when swiping would flip pages twice. This number is used so only every two swipes it will flip pages
    var pageSwipeCount : Int = 0;
    
    // This is called not only when you scroll, but when you swipe the trackpad. This should also work with Magic Mouse(Not tested)
    override func scrollWheel(theEvent: NSEvent) {
        // If the delta X is less than 5(Meaning you are swiping left)...
        if(theEvent.deltaX < -5) {
            // If the swipe cooldown is over...
            if(swipeCooldownOver) {
                // Add 1 to the page swipe count
                pageSwipeCount++;
                
                // If the page swipe count is 2...
                if(pageSwipeCount == 2) {
                    // Go to the next page
                    nextPage();
                    
                    // Set the page swipe count to 0
                    pageSwipeCount = 0;
                }
            }
            
            // Say the cooldown isnt over
            swipeCooldownOver = false;
        }
        // If the delta X is greater than 5(Meaning you are swiping right)...
        else if(theEvent.deltaX > 5) {
            // If the swipe cooldown is over...
            if(swipeCooldownOver) {
                // Add 1 to the page swipe count
                pageSwipeCount++;
                
                // If the page swipe count is 2...
                if(pageSwipeCount == 2) {
                    // Go to the previous page
                    previousPage();
                    
                    // Set the page swipe count to 0
                    pageSwipeCount = 0;
                }
            }
            
            // Say the swipe cooldown isnt over
            swipeCooldownOver = false;
        }
        // If the trackpad's scroll force on the X is 0...
        else if(theEvent.deltaX == 0) {
            // Say the cooldown is over
            swipeCooldownOver = true;
        }
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
            // Get the size of the left image
            var leftImageSize : NSSize = NSSize();
            
            // Get the size of the right image
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
            
            // If the right pages height is smaller than the screen...
            if(rightImageSize.height < NSScreen.mainScreen()?.frame.height) {
                // Set the reader windows frame to be two times the width of the current open page
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: leftImageSize.width + rightImageSize.width, height: rightImageSize.height), display: false);
            }
            // If its larger vertically...
            else {
                // The height we want the window to have
                let height = (NSScreen.mainScreen()?.frame.height)! - 50;
                
                // Get the aspect ratio of the image
                let aspectRatio = (leftImageSize.width + rightImageSize.width) / (rightImageSize.height);
                
                // Figure out what the width would be if we kept the aspect ratio and set the height to the screens size with a nit of padding
                let width = aspectRatio * height;
                
                // Set the windows size to the new size we calculated
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: false);
            }
            
            // Center the window
            readerWindow.center();
        }
        else if(!dualPage && !isFullscreen) {
            // If the current pages image is smaller than the screen vertically...
            if((readerImageView.image?.size.height)! < NSScreen.mainScreen()?.frame.height) {
                // Set the reader windows frame to be the reader image views image size
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: (readerImageView.image?.size.width)!, height: (readerImageView.image?.size.height)!), display: false);
            }
            // If its larger vertically...
            else {
                // The height we want the window to have
                let height = (NSScreen.mainScreen()?.frame.height)! - 50;
                
                // Get the aspect ratio of the image
                let aspectRatio = (readerImageView.image?.size.width)! / (readerImageView.image?.size.height)!;
                
                // Figure out what the width would be if we kept the aspect ratio and set the height to the screens size with a nit of padding
                let width = aspectRatio * height;
                
                // Set the windows size to the new size we calculated
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: false);
                
                // Center the window
                readerWindow.center();
            }
            
            // Center the window
            readerWindow.center();
        }
    }
    
    override func viewWillDisappear() {
        // Say the view is closing
        closingView = true;
        
        // Stop the mouse hover timer
        mouseHoverHandlingTimer.invalidate();
        
        // Post the notification to update the percent finished
        NSNotificationCenter.defaultCenter().postNotificationName("KMMangaGridCollectionItem.UpdatePercentFinished", object: manga);
        
        // Update the grid(For some reason I have to call this function instead of the update grid one)
        NSNotificationCenter.defaultCenter().postNotificationName("KMEditMangaViewController.Saving", object: manga);
        
        // Show the cursor
        NSCursor.unhide();
    }
    
    // Resets things like the Contrast, Saturation, ETC.
    func resetCGValues() {
        // Update the sliders
        readerControlPanelSaturationSlider.floatValue = 1;
        readerControlPanelBrightnessSlider.floatValue = 0;
        readerControlPanelContrastSlider.floatValue = 1;
        readerControlPanelSharpnessSlider.floatValue = 0;
        
        // Reset the values
        manga.saturation = 1;
        manga.brightness = 0;
        manga.contrast = 1;
        manga.sharpness = 0;
        
        // Update the filters
        updateFiltersForCurrentPage();
    }
    
    // Opens the control panel for the user to modify the Saturation, Contrast, ETC.
    func openControlsPanel() {
        // Show the reader controls panel
        readerControlsPanelVisualEffectView.hidden = false;
        
        // Animate out the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 0;
        
        // Animate in the reader control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 1;
        
        // Do the 0.2 second wait to hide the reader panel and show the controls panel
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("hideReaderPanelShowControlsPanel"), userInfo: nil, repeats:false);
    }
    
    /// Closes the control panel for the user to modify the Saturation, Contrast, ETC.
    func closeControlsPanel() {
        // Animate in the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 1;
        
        // Animate out the control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 0;
        
        // Do the 0.2 second wait to hide the controls panel and show the reader panel
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("hideControlsPanelShowReaderPanel"), userInfo: nil, repeats:false);
    }
    
    /// Hides the controls panel and shows the reader panel
    func hideControlsPanelShowReaderPanel() {
        // Disable all the reader control panel buttons
        readerControlPanelSaturationSlider.enabled = false;
        readerControlPanelContrastSlider.enabled = false;
        readerControlPanelBrightnessSlider.enabled = false;
        readerControlPanelSharpnessSlider.enabled = false;
        readerControlPanelSaveButton.enabled = false;
        readerControlPanelResetButton.enabled = false;
        
        // Set the controls panel to be hidden
        readerControlsPanelVisualEffectView.hidden = true;
        
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerate() {
            // Enable it(Cast it to a NSControl first so we can enable it)
            (currentItem as! NSControl).enabled = true;
        }
        
        // Set the reader panel to show
        readerPanelCornerRounding.hidden = false;
    }
    
    /// Hides the reader panel and shows the control panel
    func hideReaderPanelShowControlsPanel() {
        // Enable all the reader control panel buttons
        readerControlPanelSaturationSlider.enabled = true;
        readerControlPanelContrastSlider.enabled = true;
        readerControlPanelBrightnessSlider.enabled = true;
        readerControlPanelSharpnessSlider.enabled = true;
        readerControlPanelSaveButton.enabled = true;
        readerControlPanelResetButton.enabled = true;
        
        // Set the controls panel to show
        readerControlsPanelVisualEffectView.hidden = false;
        
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerate() {
            // Disable it(Cast it to a NSControl first so we can enable it)
            (currentItem as! NSControl).enabled = false;
        }
        
        // Set the reader panel to be hidden
        readerPanelCornerRounding.hidden = true;
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
    
    /// Calls bookmarkPage with the current page number
    func bookmarkCurrentPage() {
        // Call bookmarkPage with the current page number
        bookmarkPage(manga.currentPage);
    }
    
    /// Bookmarks the current page(Starts at 0). If it is already bookmarked, it removes that bookmark
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
    
    /// Closes the dialog that prompts the user to jump to a page, and jumps to the inputted page
    func closeJumpToPageDialog() {
        // Fade out the view
        readerPageJumpVisualEffectView.animator().alphaValue = 0;
        
        // Do the 0.2 second wait to hide the page jump dialog
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target:self, selector: Selector("hideJumpToPageDialog"), userInfo: nil, repeats:false);
        
        // Jump to the inputted page
        jumpToPage(readerPageJumpNumberField.integerValue - 1, round: true);
    }
    
    /// Actually hides the jump to page dialog
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
                // If we have mark as read when completed in reader enabled...
                if((NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.markAsReadWhenCompletedInReader) {
                    // Print to the log that we have finished the book and are marking it as read
                    print("Finished \"" + manga.title + "\", marking it as read and exiting");
                    
                    // Set the mangas read variable to true
                    manga.read = true;
                    
                    // Close the window
                    readerWindow.close();
                }
                else {
                    // Close the window
                    readerWindow.close();
                }
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
                // If we have mark as read when completed in reader enabled...
                if((NSApplication.sharedApplication().delegate as! AppDelegate).preferencesKepper.markAsReadWhenCompletedInReader) {
                    // Print to the log that we have finished the book and are marking it as read
                    print("Finished \"" + manga.title + "\", marking it as read and exiting");
                    
                    // Set the mangas read variable to true
                    manga.read = true;
                    
                    // Close the window
                    readerWindow.close();
                }
                else {
                    // Close the window
                    readerWindow.close();
                }
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
    
    func updateFiltersForAllPages() {
        // Set manga.pages to all its current pages, but filtered with our given variables
        manga.pages = KMImageFilterUtilities().applyColorAndSharpnessMultiple(mangaOriginalPages, saturation: manga.saturation, brightness: manga.brightness, contrast: manga.contrast, sharpness: manga.sharpness);
        
        // Update the page
        updatePage();
    }
    
    func updateFiltersForCurrentPage() {
        // If we arent in dual page mode...
        if(!dualPage) {
            // Set the current page to the current page with filters
            manga.pages[manga.currentPage] = KMImageFilterUtilities().applyColorAndSharpness(mangaOriginalPages[manga.currentPage], saturation: manga.saturation, brightness: manga.brightness, contrast: manga.contrast, sharpness: manga.sharpness);
        }
        // If we are in dual page
        else {
            // If we add 1 to manga.currentPage and there would be an image at that index in manga.pages...
            if(manga.currentPage + 1 < manga.pages.count) {
                // Apply the filter to this image
                manga.pages[manga.currentPage + 1] = KMImageFilterUtilities().applyColorAndSharpness(mangaOriginalPages[manga.currentPage + 1], saturation: manga.saturation, brightness: manga.brightness, contrast: manga.contrast, sharpness: manga.sharpness);
            }
                
            // Set the current page to the current page with filters
            manga.pages[manga.currentPage] = KMImageFilterUtilities().applyColorAndSharpness(mangaOriginalPages[manga.currentPage], saturation: manga.saturation, brightness: manga.brightness, contrast: manga.contrast, sharpness: manga.sharpness);
        }
        
        // Update the page
        updatePage();
    }
    
    func fadeOutTitlebarFullscreen() {
        // If the view isnt closing...
        if(!closingView) {
            // Hide the cursor
            NSCursor.hide();
        }
        
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
    
    func mouseHoverHandling() {
        // Are we fullscreen?
        let fullscreen : Bool = readerWindow.isFullscreen();
        
        // if we arent fullscreen...
        if(!fullscreen) {
            // If the titlebar visual effect view is hidden...
            if(titlebarVisualEffectView.hidden) {
                // Show the titlebar visual effect view
                titlebarVisualEffectView.hidden = false;
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
        
        // Create a new CGEventRef, for the mouse position
        let mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        let mousePosition = CGEventGetLocation(mouseEvent);
        
        // If we have moved the mouse...
        if(mousePosition != oldMousePosition) {
            // Stop the fade timer
            fadeTimer.invalidate();
            
            // Store the reader panels frame
            let readerPanelFrame : NSRect = readerPanelCornerRounding.frame;
            
            /// The mouses position on the Y
            let pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
            
            /// The mouses position where 0 0 is the bottom left of the reader window
            let mousePositionFromWindow : CGPoint = NSPoint(x: mousePosition.x - readerWindow.frame.origin.x, y: pointY - readerWindow.frame.origin.y);
            
            /// Is the mouse inside the reader panel?
            var insideReaderPanel : Bool = false;
            
            // If the mouse is within the reader panel on the X...
            if(mousePositionFromWindow.x > readerPanelFrame.origin.x && mousePositionFromWindow.x < (readerPanelFrame.origin.x + readerPanelFrame.size.width)) {
                // If the mouse is within the reader panel on the Y...
                if(mousePositionFromWindow.y > readerPanelFrame.origin.y && mousePositionFromWindow.y < (readerPanelFrame.origin.y + readerPanelFrame.size.height)) {
                    // Say we are in the reader panel
                    insideReaderPanel = true;
                }
            }
            
            // If the reader window is currently selected...
            if(readerWindow.keyWindow) {
                // Fade in the titlebar(Fullscreen mode)
                fadeInTitlebarFullscreen();
            }
            
            // If the cursor isnt inside the reader panel and in fullscreen...
            if(!insideReaderPanel && fullscreen) {
                // Fade out the titlebar(Fullscreen mode)
                fadeTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target:self, selector: Selector("fadeOutTitlebarFullscreen"), userInfo: nil, repeats:false);
            }
            // If the reader window is the key window and the cursor isnt inside the reader panel...
            else if(readerWindow.keyWindow && !insideReaderPanel) {
                // Fade out the titlebar(Fullscreen mode)
                fadeTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target:self, selector: Selector("fadeOutTitlebarFullscreen"), userInfo: nil, repeats:false);
            }
            
            // If the reader window isnt key...
            if(!readerWindow.keyWindow) {
                // Fade out the titlebar
                fadeTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0), target:self, selector: Selector("fadeOutTitlebar"), userInfo: nil, repeats:false);
                
                // Show the cursor
                NSCursor.unhide();
            }
        }
        
        // Set oldMousePosition to the current mouse position
        oldMousePosition = mousePosition;
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
