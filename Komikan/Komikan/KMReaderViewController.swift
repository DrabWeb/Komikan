//
//  KMReaderViewController.swift
//  Komikan
//
//  Created by Seth on 2015-12-31.
//  Copyright © 2015 DrabWeb. All rights reserved.
//

import Cocoa
import Quartz
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class KMReaderViewController: NSViewController, NSWindowDelegate {

    // The main window for the reader
    var readerWindow : NSWindow = NSWindow();
    
    /// The text field for the windows title that lets us have a white title color
    @IBOutlet weak var readerWindowTitleTextField: NSTextField!
    
    /// The view that both encapsulates the reader image views and lets you zoom in/out
    @IBOutlet weak var readerImageScrollView: KMReaderScrollView!
    
    /// The magnification gesture recognizer for zooming in and out using the Trackpad
    @IBOutlet var readerMagnificationGestureRecognizer: NSMagnificationGestureRecognizer!
    
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
    @IBAction func readerControlPanelSaveButtonPressed(_ sender: AnyObject) {
        // Say the controls panel is closed
        readerControlsOpen = false;
        
        // Close the controls panel
        closeControlsPanel();
        
        // Apply the new filter values to all pages(In a new thread so we dont get lots of beachballing for long manga)
        Thread.detachNewThreadSelector(#selector(KMReaderViewController.updateFiltersForAllPages), toTarget: self, with: nil);
    }
    
    /// The reset button in the reader control panel
    @IBOutlet weak var readerControlPanelResetButton: NSButton!
    
    // When we press the reset button in the reader control panel...
    @IBAction func readerControlPanelResetButtonPressed(_ sender: AnyObject) {
        // Reset the values to default(In a new thread so we dont beachball in long manga)
        Thread.detachNewThreadSelector(#selector(KMReaderViewController.resetCGValues), toTarget: self, with: nil);
    }
    
    // The slider in the control panel that controls the readers saturation
    @IBOutlet weak var readerControlPanelSaturationSlider : NSSlider!
    
    // When we interact with readerControlPanelSaturationSlider...
    @IBAction func readerControlPanelSaturationSliderInteracted(_ sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("KMReaderViewController: Changing saturation to " + String(readerControlPanelSaturationSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.saturation = CGFloat(readerControlPanelSaturationSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers brightness
    @IBOutlet weak var readerControlPanelBrightnessSlider : NSSlider!
    
    // When we interact with readerControlPanelBrightnessSlider...
    @IBAction func readerControlPanelBrightnessSliderInteracted(_ sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("KMReaderViewController: Changing brightness to " + String(readerControlPanelBrightnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.brightness = CGFloat(readerControlPanelBrightnessSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers contrast
    @IBOutlet weak var readerControlPanelContrastSlider : NSSlider!
    
    // When we interact with readerControlPanelContrastSlider...
    @IBAction func readerControlPanelContrastSliderInteracted(_ sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("KMReaderViewController: Changing contrast to  " + String(readerControlPanelContrastSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.contrast = CGFloat(readerControlPanelContrastSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The slider in the control panel that controls the readers sharpness
    @IBOutlet weak var readerControlPanelSharpnessSlider : NSSlider!
    
    // When we interact with readerControlPanelSharpnessSlider...
    @IBAction func readerControlPanelSharpnessSliderInteracted(_ sender: AnyObject) {
        // Print to the log what value we are changing it to
        print("KMReaderViewController: Changing sharpness to " + String(readerControlPanelSharpnessSlider.floatValue));
        
        // Set the represented value to the represented sliders value
        manga.sharpness = CGFloat(readerControlPanelSharpnessSlider.floatValue);
        
        // Apply the filters to the current page
        updateFiltersForCurrentPage();
    }
    
    // The button on the reader panel that lets you jump to a page
    @IBOutlet weak var readerPageJumpButton: NSButton!
    
    // When readerPageJumpButton is pressed...
    @IBAction func readerPageJumpButtonPressed(_ sender: AnyObject) {
        // Prompt the user to jump to a page
        promptToJumpToPage();
    }
    
    /// The controller for the reader page jump view
    @IBOutlet var readerPageJumpController: KMReaderPageJumpController!
    
    // The label on the reader panel that shows what page you are on and how many pages there are
    @IBOutlet weak var readerPageNumberLabel: NSTextField!
    
    // The button on the reader panel that lets you bookmark the current page
    @IBOutlet weak var readerBookmarkButton: NSButton!
    
    // When readerBookmarkButton is pressed...
    @IBAction func readerBookmarkButtonPressed(_ sender: AnyObject) {
        // Bookmark the current page
        bookmarkCurrentPage();
    }
    
    // Do we have the reader controls open?
    var readerControlsOpen : Bool = false;
    
    // The button on the reader panel that brings you to the settings for the reader with color controls among other things
    @IBOutlet weak var readerSettingsButton: NSButton!
    
    // When readerSettingsButton is pressed...
    @IBAction func readerSettingsButtonPressed(_ sender: AnyObject) {
        // Disabled for now, need to find out how to apply filters directly to an NSImage
        // Say that the controls panel is open
        readerControlsOpen = true;
        
        // Open the controls panel
        openControlsPanel();
    }
    
    /// The visual effect view for the background of the thumbnail page jump view
    @IBOutlet weak var thumbnailPageJumpVisualEffectView: NSVisualEffectView!
    
    // The manga we have open
    var manga : KMManga = KMManga();
    
    // The original pages for the manga
    var mangaOriginalPages : [NSImage] = [NSImage()];
    
    // Are we wanting to read in dual page mode?
    var dualPage : Bool = false;
    
    // The direction we are reading(Default Right to Left)
    var dualPageDirection : KMDualPageDirection = KMDualPageDirection.rightToLeft;
    
    // Are we fullscreen?
    var isFullscreen : Bool = false;
    
    /// Is the window in the process of closing?
    var closingView : Bool = false;
    
    // The NSTimer to handle the mouse hovering when we arent in fullscreen
    var mouseHoverHandlingTimer : Timer = Timer();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Set the reader scroll views reader view controller
        readerImageScrollView.readerViewController = self;
        
        // Setup the page jump view
        readerPageJumpController.setup();
        
        // Add the magnification gesture recogniser to the reader scroll view
        readerImageScrollView.addGestureRecognizer(readerMagnificationGestureRecognizer);
        
        // Start the 0.1 second loop for the mouse hovering
        mouseHoverHandlingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(KMReaderViewController.mouseHoverHandling), userInfo: nil, repeats: true);
        
        // Subscribe to the preferences saved notification
        NotificationCenter.default.addObserver(self, selector: #selector(KMReaderViewController.reloadPreferences), name:NSNotification.Name(rawValue: "Application.PreferencesSaved"), object: nil);
        
        // Show the reader panel and hide the controls panel
        hideControlsPanelShowReaderPanel();
    }
    
    func openManga(_ openingManga : KMManga, page : Int) {
        // Set the readers manga to the manga we want to open
        manga = openingManga;
        
        // Print to the log what we are opening
        print("KMReaderViewController: Opening \"" + manga.title + "\"");
    
        // Set the windows title to match the mangas name
        readerWindow.title = manga.title;
        
        // Extract the archive and get the info from it
        manga.extractToTmpFolder();
        
        // Set mangaOriginalPages to the manga's current pages
        mangaOriginalPages = manga.pages;
        
        // Load the saturation values
        readerControlPanelSaturationSlider.floatValue = Float(manga.saturation);
        
        // Load the brightness values
        readerControlPanelBrightnessSlider.floatValue = Float(manga.brightness);
        
        // Load the contrast values
        readerControlPanelContrastSlider.floatValue = Float(manga.contrast);
        
        // Load the sharpness values
        readerControlPanelSharpnessSlider.floatValue = Float(manga.sharpness);
        
        // If the color/sharpness filters are non-default...
        if(manga.saturation != 1 || manga.brightness != 0 || manga.contrast != 1 || manga.sharpness != 0) {
            // Apply the new filter values to all pages
            updateFiltersForAllPages();
        }
        
        // Jump to the page we said to start at
        jumpToPage(page, round: false);
        
        // Resize the window to match the mangas size
        fitWindowToManga();
        
        // Center the window
        readerWindow.center();
        
        // Setup the menubar items actions
        (NSApplication.shared().delegate as? AppDelegate)?.nextPageMenubarItem.action = #selector(KMReaderViewController.nextPage);
        (NSApplication.shared().delegate as? AppDelegate)?.previousPageMenubarItem.action = #selector(KMReaderViewController.previousPage);
        (NSApplication.shared().delegate as? AppDelegate)?.jumpToPageMenuItem.action = #selector(KMReaderViewController.promptToJumpToPage);
        (NSApplication.shared().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.action = #selector(KMReaderViewController.bookmarkCurrentPage);
        (NSApplication.shared().delegate as? AppDelegate)?.dualPageMenuItem.action = #selector(KMReaderViewController.toggleDualPage);
        (NSApplication.shared().delegate as? AppDelegate)?.fitWindowToPageMenuItem.action = #selector(KMReaderViewController.fitWindowToManga);
        (NSApplication.shared().delegate as? AppDelegate)?.switchDualPageDirectionMenuItem.action = #selector(KMReaderViewController.switchDualPageDirection);
        (NSApplication.shared().delegate as? AppDelegate)?.readerZoomInMenuItem.action = #selector(KMReaderViewController.magnifyIn);
        (NSApplication.shared().delegate as? AppDelegate)?.readerZoomOutMenuItem.action = #selector(KMReaderViewController.magnifyOut);
        (NSApplication.shared().delegate as? AppDelegate)?.readerResetZoomMenuItem.action = #selector(KMReaderViewController.resetMagnification);
        (NSApplication.shared().delegate as? AppDelegate)?.readerOpenNotesMenuItem.action = #selector(KMReaderViewController.openNotesWindow);
        
        (NSApplication.shared().delegate as? AppDelegate)?.readerRotateNinetyDegressLeftMenuItem.action = #selector(KMReaderViewController.rotateLeftNinetyDegrees);
        (NSApplication.shared().delegate as? AppDelegate)?.readerRotateNinetyDegressRightMenuItem.action = #selector(KMReaderViewController.rotateRightNinetyDegrees);
        (NSApplication.shared().delegate as? AppDelegate)?.readerResetRotationMenuItem.action = #selector(KMReaderViewController.resetRotation);
    }
    
    /// The window controller for the notes window
    var notesWindowController : NSWindowController?;
    
    /// The view controller for the notes window
    var notesViewController : KMReaderNotesViewController = KMReaderNotesViewController();
    
    /// Opens the window that lets the user edit/view the notes for this manga
    func openNotesWindow() {
        // If the window isnt loaded...
        if(notesWindowController == nil) {
            // Load the notes window controller
            notesWindowController = (storyboard?.instantiateController(withIdentifier: "readerNotesWindowController") as! NSWindowController);
            
            // Set the notes view controller to the windows view controller
            notesViewController = (notesWindowController!.contentViewController as! KMReaderNotesViewController);
            
            // Load the window into the notes view controller
            notesViewController.notesWindow = notesWindowController!.window!;
            
            // Set the notes view controller's manga
            notesViewController.manga = self.manga;
        }
        
        // Load the notes window
        notesWindowController!.loadWindow();
        
        // Set the notes window to be full size
        notesWindowController!.window!.styleMask.insert(NSFullSizeContentViewWindowMask);
        
        // Hide the edit bar in the notes window
        notesViewController.hideEditingBar();
        
        // Scroll up
        notesViewController.notesScrollView.pageUp(self);
        
        // Load the notes window title
        notesViewController.setWindowTitle();
        
        // Set the notes window's delegate to the notes view controller
        notesWindowController!.window!.delegate = notesViewController;
        
        // Load the notes
        notesViewController.loadNotes();
        
        // Show the notes window
        notesWindowController!.showWindow(self);
    }
    
    /// Reloads the values needed from the preferences
    func reloadPreferences() {
        // Set the window background color
        readerWindow.backgroundColor = (NSApplication.shared().delegate as! AppDelegate).preferencesKepper.readerWindowBackgroundColor;
    }
    
    /// Resets the zoom amount
    func resetMagnification() {
        // Reset the reader scroll views magnification to 1
        readerImageScrollView.animator().magnification = 1;
    }
    
    /// Zooms in by 10%
    func magnifyIn() {
        // Add 0.25 to the reader scroll views magnification
        readerImageScrollView.magnification += 0.25;
    }
    
    /// Zooms out by 10%
    func magnifyOut() {
        // Substract 0.25 from the reader scroll views magnification
        readerImageScrollView.magnification -= 0.25;
    }
    
    /// Rotates the manga left by 90 degress
    func rotateLeftNinetyDegrees() {
        // Rotate the pages left 90 degress
        readerImageView.frameCenterRotation += 90;
        dualPageStackView.frameCenterRotation += 90;
    }
    
    /// Rotates the manga right by 90 degress
    func rotateRightNinetyDegrees() {
        // Rotate the pages right 90 degress
        readerImageView.frameCenterRotation -= 90;
        dualPageStackView.frameCenterRotation -= 90;
    }
    
    /// Resets the rotation of the manga
    func resetRotation() {
        // Reset the rotation on the pages
        readerImageView.frameCenterRotation = 0;
        dualPageStackView.frameCenterRotation = 0;
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        // Temporary fix for the image view dissapearing when rotated and the window resizes
        readerImageView.frameCenterRotation = 0;
        dualPageStackView.frameCenterRotation = 0;
        
        return frameSize;
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        // If we arent dragging and the jump to page dialog isnt open...
        if(!dragging && !pageJumpOpen) {
            // If we said in the preferences to be able to drag the reader window without holding alt...
            if((NSApplication.shared().delegate as! AppDelegate).preferencesKepper.dragReaderWindowByBackgroundWithoutHoldingAlt) {
                // If the reader controls panel isnt open...
                if(!readerControlsOpen) {
                    // Create a new CGEventRef, for the mouse position
                    let mouseEvent : CGEvent = CGEvent(source: nil)!;
                    
                    // Get the mouse point onscreen from ourEvent
                    let mousePosition = mouseEvent.location;
                    
                    // Store the titlebars frame
                    let titlebarFrame : NSRect = titlebarVisualEffectView.frame;
                    
                    /// The mouses position on the Y
                    let pointY = abs(mousePosition.y - NSScreen.main()!.frame.height);
                    
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
                        // If the mouse position's X(Relative to the window) is less than the window width divided by 2...
                        if(mousePositionFromWindow.x < (readerWindow.frame.width / 2)) {
                            // We clicked on the left, go to the previous page
                            previousPage();
                        }
                        else {
                            // We clicked on the right, go to the next page
                            nextPage();
                        }
                    }
                }
                else {
                    // Say the controls panel is closed
                    readerControlsOpen = false;
                    
                    // Close the controls panel
                    closeControlsPanel();
                    
                    // Apply the new filter values to all pages(In a new thread so we dont get lots of beachballing for long manga)
                    Thread.detachNewThreadSelector(#selector(KMReaderViewController.updateFiltersForAllPages), toTarget: self, with: nil);
                }
            }
            else {
                // If we arent holding alt...
                if(theEvent.modifierFlags.rawValue != 524576 && theEvent.modifierFlags.rawValue != 524320) {
                    // If the reader controls panel isnt open...
                    if(!readerControlsOpen) {
                        // Create a new CGEventRef, for the mouse position
                        let mouseEvent : CGEvent = CGEvent(source: nil)!;
                        
                        // Get the mouse point onscreen from ourEvent
                        let mousePosition = mouseEvent.location;
                        
                        // Store the titlebars frame
                        let titlebarFrame : NSRect = titlebarVisualEffectView.frame;
                        
                        /// The mouses position on the Y
                        let pointY = abs(mousePosition.y - NSScreen.main()!.frame.height);
                        
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
                            // If the mouse position's X(Relative to the window) is less than the window width divided by 2...
                            if(mousePositionFromWindow.x < (readerWindow.frame.width / 2)) {
                                // We clicked on the left, go to the previous page
                                previousPage();
                            }
                            else {
                                // We clicked on the right, go to the next page
                                nextPage();
                            }
                        }
                    }
                    else {
                        // Say the controls panel is closed
                        readerControlsOpen = false;
                        
                        // Close the controls panel
                        closeControlsPanel();
                        
                        // Apply the new filter values to all pages(In a new thread so we dont get lots of beachballing for long manga)
                        Thread.detachNewThreadSelector(#selector(KMReaderViewController.updateFiltersForAllPages), toTarget: self, with: nil);
                    }
                }
            }
        }
        // If we arent dragging and the jump to page dialog is open...
        else if(!dragging && pageJumpOpen) {
            // If we said we could drag the window without holding alt...
            if((NSApplication.shared().delegate as! AppDelegate).preferencesKepper.dragReaderWindowByBackgroundWithoutHoldingAlt) {
                // Close the page jump view
                closeJumpToPageDialog();
            }
            // If we said we have to hold alt while dragging the window and we are holding alt...
            else if(theEvent.modifierFlags.rawValue != 524576 && theEvent.modifierFlags.rawValue != 524320) {
                // Close the page jump view
                closeJumpToPageDialog();
            }
        }
        
        // Say we arent dragging
        dragging = false;
    }
    
    /// Is the user dragging the mouse?
    var dragging : Bool = false;
    
    override func mouseDragged(with theEvent: NSEvent) {
        // If we said in the preferences to be able to drag the reader window without holding alt...
        if((NSApplication.shared().delegate as! AppDelegate).preferencesKepper.dragReaderWindowByBackgroundWithoutHoldingAlt) {
            // Perform a window drag with the drag event
            if #available(OSX 10.11, *) {
                readerWindow.performDrag(with: theEvent);
            } else {
                // Move the window with the mouse's delta
                readerWindow.setFrameOrigin(NSPoint(x: readerWindow.frame.origin.x + theEvent.deltaX, y: readerWindow.frame.origin.y - theEvent.deltaY));
            };
            
            // Say we are dragging
            dragging = true;
        }
        else {
            // If we are holding alt...
            if(theEvent.modifierFlags.rawValue == 524576) {
                // Perform a window drag with the drag event
                if #available(OSX 10.11, *) {
                    readerWindow.performDrag(with: theEvent);
                } else {
                    // Move the window with the mouse's delta
                    readerWindow.setFrameOrigin(NSPoint(x: readerWindow.frame.origin.x + theEvent.deltaX, y: readerWindow.frame.origin.y - theEvent.deltaY));
                };
            }
        }
    }
    
    func switchDualPageDirection() {
        // If we are reading Right to Left...
        if(dualPageDirection == KMDualPageDirection.rightToLeft) {
            // Switch the direction to Left to Right
            dualPageDirection = KMDualPageDirection.leftToRight;
        }
        // If we are reading Left to Right...
        else if(dualPageDirection == KMDualPageDirection.leftToRight) {
            // Switch the direction to Right to Left
            dualPageDirection = KMDualPageDirection.rightToLeft;
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
                leftImageSize = pixelSizeOfImage(manga.pages[manga.currentPage + 1]);
            }
            else {
                // Set leftImageSize to be the other pages size
                leftImageSize = pixelSizeOfImage(manga.pages[manga.currentPage]);
            }
            
            // Set rightImageSize to be the ucrrent pages image size
            rightImageSize = pixelSizeOfImage(manga.pages[manga.currentPage]);
            
            // If the right pages height is smaller than the screen...
            if(rightImageSize.height < NSScreen.main()?.frame.height) {
                // Set the reader windows frame to be two times the width of the current open page
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: leftImageSize.width + rightImageSize.width, height: rightImageSize.height), display: false);
            }
            // If its larger vertically...
            else {
                // The height we want the window to have
                let height = (NSScreen.main()?.frame.height)! - 150;
                
                // Get the aspect ratio of the image
                let aspectRatio = (leftImageSize.width + rightImageSize.width) / (rightImageSize.height);
                
                // Figure out what the width would be if we kept the aspect ratio and set the height to the screens size
                let width = aspectRatio * height;
                
                // Set the windows size to the new size we calculated
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: false);
            }
            
            // Center the window
            readerWindow.center();
        }
        else if(!dualPage && !isFullscreen) {
            // If the current pages image is smaller than the screen vertically...
            if(pixelSizeOfImage(readerImageView.image!).height < ((NSScreen.main()?.frame.height)! - 150)) {
                // Set the reader windows frame to be the reader image views image size
                readerWindow.setFrame(NSRect(x: 0, y: 0, width: pixelSizeOfImage(readerImageView.image!).width, height: pixelSizeOfImage(readerImageView.image!).height), display: false);
            }
            // If its larger vertically...
            else {
                // The height we want the window to have
                let height = (NSScreen.main()?.frame.height)! - 150;
                
                // Get the aspect ratio of the image
                let aspectRatio = pixelSizeOfImage(readerImageView.image!).width / pixelSizeOfImage(readerImageView.image!).height;
                
                // Figure out what the width would be if we kept the aspect ratio and set the height to the screens size
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
    
    /// Returns the pixel size of the passed NSImage
    func pixelSizeOfImage(_ image : NSImage) -> NSSize {
        /// The NSBitmapImageRep to the image
        let imageRep : NSBitmapImageRep = (NSBitmapImageRep(data: image.tiffRepresentation!))!;
        
        /// The size of the iamge
        let imageSize : NSSize = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh);
        
        // Return the image size
        return imageSize;
    }
    
    func windowWillClose(_ notification: Notification) {
        // Save the notes and close the notes window
        notesWindowController?.close();
        
        // Close the view
        closeView();
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        // Re-enable the next and previous menu items in case the notes popover disabled them
        (NSApplication.shared().delegate as? AppDelegate)?.nextPageMenubarItem.action = #selector(KMReaderViewController.nextPage);
        (NSApplication.shared().delegate as? AppDelegate)?.previousPageMenubarItem.action = #selector(KMReaderViewController.previousPage);
    }
    
    /// Call this when the window will close
    func closeView() {
        // Say the view is closing
        closingView = true;
        
        // Restore the manga's original pages
        manga.pages = mangaOriginalPages;
        
        // Stop the mouse hover timer
        mouseHoverHandlingTimer.invalidate();
        
        // Stop monitoring the trackpad
        readerImageScrollView.removeAllMonitors();
        
        // Unsubscribe from all notifications
        NotificationCenter.default.removeObserver(self);
        
        // Post the notification to update the percent finished
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMMangaGridCollectionItem.UpdatePercentFinished"), object: manga);
        
        // Update the grid(For some reason I have to call this function instead of the update grid one)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KMEditMangaViewController.Saving"), object: manga);
        
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
        readerControlsPanelVisualEffectView.isHidden = false;
        
        // Animate out the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 0;
        
        // Animate in the reader control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 1;
        
        // Do the 0.2 second wait to hide the reader panel and show the controls panel
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target:self, selector: #selector(KMReaderViewController.hideReaderPanelShowControlsPanel), userInfo: nil, repeats:false);
    }
    
    /// Closes the control panel for the user to modify the Saturation, Contrast, ETC.
    func closeControlsPanel() {
        // Animate in the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 1;
        
        // Animate out the control panel
        readerControlsPanelVisualEffectView.animator().alphaValue = 0;
        
        // Do the 0.2 second wait to hide the controls panel and show the reader panel
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target:self, selector: #selector(KMReaderViewController.hideControlsPanelShowReaderPanel), userInfo: nil, repeats:false);
    }
    
    /// Hides the controls panel and shows the reader panel
    func hideControlsPanelShowReaderPanel() {
        // Say the controls panel is closed
        readerControlsOpen = false;
        
        // Disable all the reader control panel buttons
        readerControlPanelSaturationSlider.isEnabled = false;
        readerControlPanelContrastSlider.isEnabled = false;
        readerControlPanelBrightnessSlider.isEnabled = false;
        readerControlPanelSharpnessSlider.isEnabled = false;
        readerControlPanelSaveButton.isEnabled = false;
        readerControlPanelResetButton.isEnabled = false;
        
        // Set the controls panel to be hidden
        readerControlsPanelVisualEffectView.isHidden = true;
        
        readerControlsPanelVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerated() {
            // Enable it(Cast it to a NSControl first so we can enable it)
            (currentItem as! NSControl).isEnabled = true;
        }
        
        // Set the reader panel to show
        readerPanelCornerRounding.isHidden = false;
    }
    
    /// Hides the reader panel and shows the control panel
    func hideReaderPanelShowControlsPanel() {
        // Say the controls panel is open
        readerControlsOpen = true;
        
        // Enable all the reader control panel buttons
        readerControlPanelSaturationSlider.isEnabled = true;
        readerControlPanelContrastSlider.isEnabled = true;
        readerControlPanelBrightnessSlider.isEnabled = true;
        readerControlPanelSharpnessSlider.isEnabled = true;
        readerControlPanelSaveButton.isEnabled = true;
        readerControlPanelResetButton.isEnabled = true;
        
        // Set the controls panel to show
        readerControlsPanelVisualEffectView.isHidden = false;
        
        // For every item in the reader panel...
        for (_, currentItem) in readerPanelVisualEffectView.subviews.enumerated() {
            // Disable it(Cast it to a NSControl first so we can enable it)
            (currentItem as! NSControl).isEnabled = false;
        }
        
        // Set the reader panel to be hidden
        readerPanelCornerRounding.isHidden = true;
    }
    
    func toggleDualPage() {
        // Toggle the dualPage bool
        dualPage = !dualPage;
        
        // Fit the window to match the mangas size
        fitWindowToManga();
        
        // If we are in dualpage mode...
        if(dualPage) {
            // If the current page number is even...
            if(manga.currentPage % 2 == 1) {
                // Subtract one from current page to make it odd
                manga.currentPage = manga.currentPage - 1;
            }
        }
        
        // Update the page
        updatePage();
    }
    
    func isPageBookmarked(_ page : Int) -> Bool {
        // Is the page bookmarked?
        var bookmarked : Bool = false;
        
        // Iterate through manga.bookmarks
        for (_, bookmarksElement) in manga.bookmarks.enumerated() {
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
    func bookmarkPage(_ page : Int) {
        // A bool to say if we already bookmarked this page
        var alreadyBookmarked = false;
        
        // Iterate through mangaBookmarks
        for (bookmarksIndex, bookmarksElement) in manga.bookmarks.enumerated() {
            // If the current element we are iterating is equal to the page we are trying to bookmark...
            if(bookmarksElement == page) {
                // Remove that element
                manga.bookmarks.remove(at: bookmarksIndex);
                
                // Say it was already bookmarked
                alreadyBookmarked = true;
                
                // Print to the log that we removed that bookmark
                print("KMReaderViewController: Removed bookmarked for page " + String(page + 1) + " in \"" + manga.title + "\"");
            }
        }
        
        // If we didnt already bookmark this page...
        if(!alreadyBookmarked) {
            // Append the page we are trying to bookmark
            manga.bookmarks.append(page);
            
            // Print to the log that we are bookmarking this page
            print("KMReaderViewController: Bookmarked page " + String(page + 1) + " in \"" + manga.title + "\"");
        }
        
        // Update the page page to show that the page is bookmarked
        updatePage();
    }
    
    /// Is the page jump view open?
    var pageJumpOpen : Bool = false;
    
    /// The NSEvent monitor for the page jump view that listens for the escape key
    var pageJumpKeyListener : AnyObject?;
    
    // Brings up the dialog for the user to jump to a page
    func promptToJumpToPage() {
        // Say the page jump view is open
        pageJumpOpen = true;
        
        // Stop the mouse hover handling timer
        mouseHoverHandlingTimer.invalidate();
        
        // Show the page jump scroll view
        readerPageJumpController.readerPageJumpCollectionViewScrollView.isHidden = false;
        
        // Load the manga's pages
        readerPageJumpController.loadPagesFromManga(manga);
        
        // Scroll to the current page
        readerPageJumpController.readerPageJumpCollectionView.scrollToVisible(readerPageJumpController.readerPageJumpCollectionView.frameForItem(at: manga.currentPage));
        
        // Say we are closing the view(This is a cheap way to make sure the cursor doesnt hide)
        closingView = true;
        
        // Fade out the titlebar and reader panels
        fadeOutTitlebar();
        
        // Show the cursor
        NSCursor.unhide();
        
        // Monitor the keyboard locally
        pageJumpKeyListener = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: pageJumpKeyHandler) as AnyObject?;
        
        // Fade in the thumbnail page jump view
        thumbnailPageJumpVisualEffectView.animator().alphaValue = 1;
    }
    
    /// The handler for listening for the escape key when the page jump view is up
    func pageJumpKeyHandler(_ event : NSEvent) -> NSEvent {
        // If we pressed the escape key and the window is frontmost...
        if(event.keyCode == 53 && readerWindow.isKeyWindow) {
            // Close the page jump view
            closeJumpToPageDialog();
        }
        
        // Return the event
        return event;
    }
    
    /// Closes the dialog that prompts the user to jump to a page, and jumps to the inputted page
    func closeJumpToPageDialog() {
        // Say the page jump view is no longer open
        pageJumpOpen = false;
        
        // Fade out the thumbnail page jump view
        thumbnailPageJumpVisualEffectView.animator().alphaValue = 0;
        
        // Stop listening for the escape key
        NSEvent.removeMonitor(pageJumpKeyListener!);
        
        // Say we arent closing the view(Stop the cheap tricks)
        closingView = false;
        
        // Restart the 0.1 second loop for the mouse hovering
        mouseHoverHandlingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(KMReaderViewController.mouseHoverHandling), userInfo: nil, repeats: true);
        
        // Wait 0.2 seconds to disable the jump to page view, so the animation can finish
        Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target:self, selector: #selector(KMReaderViewController.disableJumpToPageDialog), userInfo: nil, repeats: false);
    }
    
    /// Disables the page jump view
    func disableJumpToPageDialog() {
        // Hide the page jump scroll view
        readerPageJumpController.readerPageJumpCollectionViewScrollView.isHidden = true;
    }
    
    func nextPage() {
        // If we are in dual page mode...
        if(dualPage) {
            // If we were to add 2 to mangaCurrentPage and it would be less than the openMangaPages count...
            if(manga.currentPage + 2 < manga.pageCount) {
                // Print to the log that we are going to the next page
                print("KMReaderViewController: Loading next page in \"" + manga.title + "\"");
                
                // Add 2 to mangaCurrentPage
                manga.currentPage += 2;
                
                // Load the new page
                updatePage();
            }
            else {
                // If we have mark as read when completed in reader enabled...
                if((NSApplication.shared().delegate as! AppDelegate).preferencesKepper.markAsReadWhenCompletedInReader) {
                    // Print to the log that we have finished the book and are marking it as read
                    print("KMReaderViewController: Finished \"" + manga.title + "\", marking it as read and exiting");
                    
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
                print("KMReaderViewController: Loading next page in \"" + manga.title + "\"");
                
                // Add 1 to mangaCurrentPage
                manga.currentPage += 1;
                
                // Load the new page
                updatePage();
            }
            else {
                // If we have mark as read when completed in reader enabled...
                if((NSApplication.shared().delegate as! AppDelegate).preferencesKepper.markAsReadWhenCompletedInReader) {
                    // Print to the log that we have finished the book and are marking it as read
                    print("KMReaderViewController: Finished \"" + manga.title + "\", marking it as read and exiting");
                    
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
                print("KMReaderViewController: Loading previous page in \"" + manga.title + "\"");
                
                // Subtract 2 from mangaCurrentPage
                manga.currentPage -= 2;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that there is no previous page
                print("KMReaderViewController: There is no previous page in \"" + manga.title + "\"");
            }
        }
        else {
            // If we were to subtract 1 from mangaCurrentPage and it would be greater than 0...
            if(manga.currentPage - 1 > -1) {
                // Print to the log that we are going to the previous page
                print("KMReaderViewController: Loading previous page in \"" + manga.title + "\"");
                
                // Subtract 1 from mangaCurrentPage
                manga.currentPage -= 1;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that there is no previous page
                print("KMReaderViewController: There is no previous page in \"" + manga.title + "\"");
            }
        }
    }
    
    // The page number starts at 0, keep that in mind
    func jumpToPage(_ page : Int, round : Bool) {
        // See if the page we are trying to jump to is existant
        if(page >= 0 && page < manga.pageCount) {
            // Print to the log that we are jumping to a page
            print("KMReaderViewController: Jumping to page " + String(page) + " in \"" + manga.title + "\"");
            
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
                print("KMReaderViewController: Jumping to rounded off page " + String(roundedPage) + " in \"" + manga.title + "\"");
                
                // Set the current page to roundedPage
                manga.currentPage = roundedPage;
                
                // Load the new page
                updatePage();
            }
            else {
                // Print to the log that we cant jump to that page
                print("KMReaderViewController: Cant jump to page " + String(page) + " in \"" + manga.title + "\"");
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
            (NSApplication.shared().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.state = 1;
        }
        else {
            // Set the manga bookmarks button alpha value to 0.2, as to indicate to the user this page is not boomarked
            readerBookmarkButton.animator().alphaValue = 0.2;
            
            // Also remove the check mark next to the bookmark menu item
            (NSApplication.shared().delegate as? AppDelegate)?.bookmarkCurrentPageMenuItem.state = 0;
        }
        
        // If we are in dual page mode...
        if(dualPage) {
            // Hide the one page image view
            readerImageView.isHidden = true;
            
            // Show the dual page stack view for dual page mode
            dualPageStackView.isHidden = false;
            
            // If we are reading from Right to Left...
            if(dualPageDirection == KMDualPageDirection.rightToLeft) {
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
            else if(dualPageDirection == KMDualPageDirection.leftToRight) {
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
            readerImageView.isHidden = false;
            
            // Hide the dual page stack view
            dualPageStackView.isHidden = true;
        }
    }
    
    func updateFiltersForAllPages() {
        // For every original page...
        for(currentPageIndex, currentPage) in mangaOriginalPages.enumerated() {
            // Set the current page to be the current page with the chosen filter amounts
            manga.pages[currentPageIndex] = KMImageFilterUtilities().applyColorAndSharpness(currentPage, saturation: manga.saturation, brightness: manga.brightness, contrast: manga.contrast, sharpness: manga.sharpness);
        }
        
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
    var fadeTimer : Timer = Timer();
    
    // Is the cursor hidden(Come on Apple, why isnt this part of NSCursor?)
    var cursorHidden : Bool = false;
    
    func mouseHoverHandling() {
        // Are we fullscreen?
        let fullscreen : Bool = readerWindow.isFullscreen();
        
        // if we arent fullscreen...
        if(!fullscreen) {
            // If the titlebar visual effect view is hidden...
            if(titlebarVisualEffectView.isHidden) {
                // Show the titlebar visual effect view
                titlebarVisualEffectView.isHidden = false;
            }
        }
        else {
            // Hide the titlebar visual effect view
            titlebarVisualEffectView.isHidden = true;
            
            // Show the window titlebar
            readerWindow.standardWindowButton(NSWindowButton.closeButton)?.superview?.superview?.alphaValue = 1;
        }
        
        // Set isFullscreen to fullscreen
        isFullscreen = fullscreen;
        
        // Create a new CGEventRef, for the mouse position
        let mouseEvent : CGEvent = CGEvent(source: nil)!;
        
        // Get the mouse point onscreen from ourEvent
        let mousePosition = mouseEvent.location;
        
        // If we have moved the mouse...
        if(mousePosition != oldMousePosition) {
            // Stop the fade timer
            fadeTimer.invalidate();
            
            // Store the reader panels frame
            let readerPanelFrame : NSRect = readerPanelCornerRounding.frame;
            
            /// The mouses position on the Y
            let pointY = abs(mousePosition.y - NSScreen.main()!.frame.height);
            
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
            
            /// Is the mouse inside the window?
            var insideWindow : Bool = false;
            
            // If the mouse is inside the window on the X...
            if(mousePosition.x > readerWindow.frame.origin.x && mousePosition.x < (readerWindow.frame.origin.x + readerWindow.frame.size.width)) {
                // If the mouse is inside the window on the Y...
                if(pointY > readerWindow.frame.origin.y && pointY < (readerWindow.frame.origin.y + readerWindow.frame.size.height)) {
                    // Say we are inside the window
                    insideWindow = true;
                }
            }
            
            // If the reader window is currently selected...
            if(readerWindow.isKeyWindow) {
                // Fade in the titlebar(Fullscreen mode)
                fadeInTitlebarFullscreen();
            }
            
            // If the cursor isnt inside the reader panel and in fullscreen...
            if(!insideReaderPanel && fullscreen) {
                // Fade out the titlebar(Fullscreen mode) in one second
                fadeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target:self, selector: #selector(KMReaderViewController.fadeOutTitlebarFullscreen), userInfo: nil, repeats:false);
            }
            // If the reader window is the key window and the cursor isnt inside the reader panel and we are inside the window...
            else if(readerWindow.isKeyWindow && !insideReaderPanel && insideWindow) {
                // Fade out the titlebar(Fullscreen mode) in 2 seconds
                fadeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target:self, selector: #selector(KMReaderViewController.fadeOutTitlebarFullscreen), userInfo: nil, repeats:false);
            }
            // If the reader window is the key window and the cursor isnt inside the reader panel and we arent inside the window...
            else if(readerWindow.isKeyWindow && !insideReaderPanel && !insideWindow) {
                // Fade out the titlebar(Fullscreen mode) in 0.5 seconds
                fadeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target:self, selector: #selector(KMReaderViewController.fadeOutTitlebarFullscreen), userInfo: nil, repeats:false);
            }
            
            // If the reader window isnt key...
            if(!readerWindow.isKeyWindow) {
                // Fade out the titlebar
                fadeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0), target:self, selector: #selector(KMReaderViewController.fadeOutTitlebar), userInfo: nil, repeats:false);
                
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
        readerWindow.standardWindowButton(NSWindowButton.closeButton)?.superview?.superview?.animator().alphaValue = 0;
        
        // Use the animator to fade out the reader panel
        readerPanelVisualEffectView.animator().alphaValue = 0;
    }
    
    func fadeInTitlebar() {
        // Use the animator to fade in the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 1;
        
        // Use the animator to fade in the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.closeButton)?.superview?.superview?.animator().alphaValue = 1;
        
        // If we dont have the reader controls open...
        if(!readerControlsOpen) {
            // Use the animator to fade in the reader panel
            readerPanelVisualEffectView.animator().alphaValue = 1;
        }
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.shared().windows.last!;
        
        // Hide the titlebar
        readerWindow.standardWindowButton(NSWindowButton.closeButton)?.superview?.superview?.alphaValue = 0;
        
        // Hide the reader panels visual effect view
        readerPanelVisualEffectView.alphaValue = 0;
        
        // Hide the reader controls panel visual effect view
        readerControlsPanelVisualEffectView.alphaValue = 0;
        
        // Set it to have a full size content view
        readerWindow.styleMask.insert(NSFullSizeContentViewWindowMask);
        
        // Hide the titlebar background
        readerWindow.titlebarAppearsTransparent = true;
        
        // Hide the title
        readerWindow.titleVisibility = NSWindowTitleVisibility.hidden;
        
        // Create some options for the reader window title KVO
        let options = NSKeyValueObservingOptions([.new, .old, .initial, .prior]);
        
        // Subscribe to when the reader window changes its title
        self.readerWindow.addObserver(self, forKeyPath: "title", options: options, context: nil);
        
        // Set the reader windows delegate to this
        readerWindow.delegate = self;
        
        // Set the window background color
        readerWindow.backgroundColor = (NSApplication.shared().delegate as! AppDelegate).preferencesKepper.readerWindowBackgroundColor;
        
        // Set the background of the thumbnail page jump view to be dark
        thumbnailPageJumpVisualEffectView.material = NSVisualEffectMaterial.dark;
        
        // Hide the background of the thumbnail page jump view
        thumbnailPageJumpVisualEffectView.alphaValue = 0;
        
        // Unhide the background of the thumbnail page jump view(Its hidden in IB because it makes it unusable)
        thumbnailPageJumpVisualEffectView.isHidden = false;
        
        // DIsable the page jump scroll view(It stops scrolling/gestures in the reader until it is shown and hidden again)
        disableJumpToPageDialog();
        
        // For some reason it destroys these views appearances, so I have to set them
        readerControlPanelSaturationSlider.superview?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        readerControlPanelContrastSlider.superview?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        readerControlPanelBrightnessSlider.superview?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        readerControlPanelSharpnessSlider.superview?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        readerControlsPanelVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // If the keyPath is the one for the window title...
        if(keyPath == "title") {
            // Update the custom title text field
            readerWindowTitleTextField.stringValue = readerWindow.title;
        }
    }
}
