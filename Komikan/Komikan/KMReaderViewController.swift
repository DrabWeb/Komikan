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
    
    // The pages of manga we have open
    var openMangaPages : [NSImage] = [NSImage()];
    
    // The title of the currently open manga
    var mangaTitle : String = "Title failed to load";
    
    // The unique identifier for this mangas /tmp/folder
    var mangaDirectory : String = "/komikanmanga-";
    
    // The current manga page
    var mangaCurrentPage : Int = 0;
    
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
            
            // Remove any old manga we opened by deleting /tmp/komikanmanga
//            do {
//                try NSFileManager().removeItemAtPath("/tmp/komikanmanga");
//            } catch let error as NSError {
//                print(error.description)
//            }
            
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
            
            // Set the current manga page to the page we said to open to
            mangaCurrentPage = page;
            
            // Open the first image, so we open on the cover
            readerImageView.image = openMangaPages[mangaCurrentPage];
            
            // Setup the next and previous page menubar items actions
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.nextPageMenubarItem.action = Selector("nextPage");
            (NSApplication.sharedApplication().delegate as? AppDelegate)?.previousPageMenubarItem.action = Selector("previousPage");
        }
    }
    
    func nextPage() {
        // If we were to add 1 to mangaCurrentPage and it would be less than the openMangaPages count...
        if(mangaCurrentPage + 1 < openMangaPages.count) {
            // Print to the log that we are going to the next page
            print("Loading next page in \"" + mangaTitle + "\"");
            
            // Add 1 to mangaCurrentPage
            mangaCurrentPage++;
            
            // Load the new page
            readerImageView.image = openMangaPages[mangaCurrentPage];
        }
        else {
            // Print to the log that there is no next page
            print("There is no next page in \"" + mangaTitle + "\"");
        }
    }
    
    func previousPage() {
        // If we were to subtract 1 from mangaCurrentPage and it would be greater than 0...
        if(mangaCurrentPage - 1 > -1) {
            // Print to the log that we are going to the previous page
            print("Loading previous page in \"" + mangaTitle + "\"");
            
            // Subtract 1 from mangaCurrentPage
            mangaCurrentPage--;
            
            // Load the new page
            readerImageView.image = openMangaPages[mangaCurrentPage];
        }
        else {
            // Print to the log that there is no previous page
            print("There is no previous page in \"" + mangaTitle + "\"");
        }
    }
    
    func mouseHoverHandling() {
        // A bool to say if we are hovering the window
        var insideWindow : Bool = false;
        
        // Create a new CGEventRef, for the mouse position
        var mouseEvent : CGEventRef = CGEventCreate(nil)!;
        
        // Get the mouse point onscreen from ourEvent
        var mousePosition = CGEventGetLocation(mouseEvent);
        
        // Store the windows frame temporarly, so we dont retype a millino times
        var windowFrame : NSRect! = readerWindow.frame;
        
        // Create a variable to store the cursors location y where 0 0 is the bottom left
        var pointY = abs(mousePosition.y - NSScreen.mainScreen()!.frame.height);
        
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
    
    func fadeOutTitlebar() {
        // Use the animator to fade out the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 0;
        
        // Use the animator to fade out the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 0;
    }
    
    func fadeInTitlebar() {
        // Use the animator to fade in the titlebars visual effect view
        titlebarVisualEffectView.animator().alphaValue = 1;
        
        // Use the animator to fade in the windows titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.animator().alphaValue = 1;
    }
    
    func styleWindow() {
        // Get the reader window
        readerWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the titlebar
        readerWindow.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.alphaValue = 0;
        
        // Set it to have a full size content view
        readerWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar background
        readerWindow.titlebarAppearsTransparent = true;
        
        // Set the appearance
        readerWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
}
