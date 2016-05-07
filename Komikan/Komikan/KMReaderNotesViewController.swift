//
//  KMReaderNotesViewController.swift
//  Komikan
//
//  Created by Seth on 2016-03-03.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMReaderNotesViewController: NSViewController, NSWindowDelegate, NSTextViewDelegate {
    
    /// The window for this view controller
    var notesWindow : NSWindow = NSWindow();

    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The visual effect view for the background of the editing bar
    @IBOutlet var editingBarVisualEffectView: NSVisualEffectView!
    
    /// The scroll view for notesTextField
    @IBOutlet var notesScrollView: NSScrollView!
    
    /// The text view to let the user edit/read there notes
    @IBOutlet var notesTextField: NSTextView!
    
    /// The text field in the titlebar to set the selected text's size
    @IBOutlet var fontSizeTextField: KMAlwaysActiveTextField!
    
    /// When we interact with fontSizeTextField...
    @IBAction func fontSizeTextFieldinteracted(sender: AnyObject) {
        setFontSizeForSelectedText(fontSizeTextField.integerValue);
    }
    
    /// When we click on the "Open Externally" button...
    @IBAction func openInExternalEditorButtonInteracted(sender: AnyObject) {
        // Open the notes in the external editor
        openExternally();
    }
    
    /// The manga we will be writing/editing notes for
    var manga : KMManga = KMManga();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Is the editing bar open?
    var editingBarOpen : Bool = true;
    
    /// Opens the notes for this manga in the external application
    func openExternally() {
        // Close the window(This also saves the notes)
        notesWindow.close();
        
        // Open the .notes.rtfd in the users chosen application(Default TextEdit)
        NSWorkspace.sharedWorkspace().openFile(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.rtfd");
    }
    
    func toggleEditingBar() {
        // Toggle if the editing bar is open
        editingBarOpen = !editingBarOpen;
        
        // If the editing bar is now open...
        if(editingBarOpen) {
            // Show the editing bar
            showEditingBar();
        }
        // If the editing bar is now closed...
        else {
            // hide the editing bar
            hideEditingBar();
        }
    }
    
    func showEditingBar() {
        // Say the editing bar is open
        editingBarOpen = true;
        
        // Show the editing bar
        editingBarVisualEffectView.alphaValue = 1;
        
        // Hide the titlebar background in the notes window
        notesWindow.titlebarAppearsTransparent = true;
        
        // Set the scroll view content insets
        notesScrollView.contentInsets = NSEdgeInsets(top: 59, left: 0, bottom: 0, right: 0);
    }
    
    func hideEditingBar() {
        // Say the editing bar is not open
        editingBarOpen = false;
        
        // hide the editing bar
        editingBarVisualEffectView.alphaValue = 0;
        
        // Show the titlebar background in the notes window
        notesWindow.titlebarAppearsTransparent = false;
        
       // Set the scroll view content insets
        notesScrollView.contentInsets = NSEdgeInsets(top: 22, left: 0, bottom: 0, right: 0);
    }
    
    func textViewDidChangeSelection(notification: NSNotification) {
        // If the selected range's length isnt 0(If it is we only moved the cursor)...
        if(notesTextField.selectedRange().length > 0) {
            /// The font of the selected text
            let selectedFont : NSFont = notesTextField.textStorage?.attributedSubstringFromRange(notesTextField.selectedRange()).attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! NSFont;
            
            // Set the sized font's size to the passed size
            fontSizeTextField.stringValue = (selectedFont.fontDescriptor.objectForKey(NSFontSizeAttribute)?.stringValue)!;
        }
    }
    
    /// Sets the font size for the selected text in the notes text view to the passed int
    func setFontSizeForSelectedText(size : Int) {
        // Remove the font attribute of the selected text
        notesTextField.textStorage?.removeAttribute(NSFontAttributeName, range: notesTextField.selectedRange());
        
        /// The font of the selected text that we will change the size of
        var sizedFont : NSFont = notesTextField.textStorage?.attributedSubstringFromRange(notesTextField.selectedRange()).attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! NSFont;
        
        // Set the sized font's size to the passed size
        sizedFont = NSFontManager.sharedFontManager().convertFont(sizedFont, toSize: CGFloat(size));
        
        // Set the font of the selected text to the nwe sized font
        notesTextField.textStorage?.addAttribute(NSFontAttributeName, value: sizedFont, range: notesTextField.selectedRange());
        
        // Redraw the notes text view(If we dont the text will look wierd until selection changes)
        notesTextField.needsDisplay = true;
    }
    
    /// Saves the current notes in the text field
    func saveNotes() {
        // Print to the log that we are loading notes
        print("KMReaderNotesViewController: Saving notes for \"" + manga.title + "\" to " + KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.rtfd");
        
        // Set the text color to black so we can see it in text edit
        notesTextField.textColor = NSColor.blackColor();
        
        // Save the notes to a file with the same name as the archive with ".notes.rtfd" on the end to the Komikan folder
        notesTextField.writeRTFDToFile(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.rtfd", atomically: true);
        
        // Set the text color back to white
        notesTextField.textColor = NSColor.whiteColor();
    }
    
    /// Loads the notes for this manga(Also if there is a (archive name).notes.txt it takes the text from that and then converts it to RTFD)
    func loadNotes() {
        // Print to the log that we are loading notes
        print("KMReaderNotesViewController: Loading notes for \"" + manga.title + "\", looking in " + KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/");
        
        // If there is a .notes.txt file...
        if(NSFileManager.defaultManager().fileExistsAtPath(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.txt")) {
            // Load the files text into the notes text field
            notesTextField.string = String(data: NSFileManager.defaultManager().contentsAtPath(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.txt")!, encoding: NSUTF8StringEncoding);
            
            // Delete the .notes.txt file, were done here
            do {
                // Try to remove the .notes.txt file
                try NSFileManager.defaultManager().removeItemAtPath(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.txt");
            }
            // If there is an error...
            catch let error as NSError {
                // Print the error description
                print("KMReaderNotesViewController: Error loading notes file, \(error.description)");
            }
        }
        
        // If the .notes.rtfd file exists...
        if(NSFileManager.defaultManager().fileExistsAtPath(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.rtfd")) {
            // Load it into the text view
            notesTextField.readRTFDFromFile(KMFileUtilities().folderPathForFile(manga.directory) + "Komikan/" + NSURL(fileURLWithPath: manga.directory).lastPathComponent!.stringByRemovingPercentEncoding! + ".notes.rtfd");
        }
        
        // Set the notes text fields text color to white
        notesTextField.textColor = NSColor.whiteColor();
    }
    
    func windowWillClose(notification: NSNotification) {
        // Save the notes
        saveNotes();
    }
    
    func windowDidBecomeKey(notification: NSNotification) {
        // Disable the next and previous menu items so we can use the arrow keys in text editing
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.nextPageMenubarItem.action = nil;
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.previousPageMenubarItem.action = nil;
    }
    
    /// Sets the notes window's title to the manga that we are editing notes for with "Notes" on the end
    func setWindowTitle() {
        // Set the window's title
        notesWindow.title = manga.title + " Notes";
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the background to be more vibrant
        backgroundVisualEffectView.material = .Dark;
        
        // Set the editing bar to be more vibrant
        editingBarVisualEffectView.material = .Dark;
        
        // Set the notes text field's text color to white
        notesTextField.textColor = NSColor.whiteColor();
        
        // Set the notes text field's delegate to this
        notesTextField.delegate = self;
        
        // Set the toggle edit bar menu item's action
        (NSApplication.sharedApplication().delegate as! AppDelegate).readerToggleNotesEditBarMenuItem.action = Selector("toggleEditingBar");
        
        // Set the open in external editor menu item's action
        (NSApplication.sharedApplication().delegate as! AppDelegate).openInExternalEditorMenuItem.action = Selector("openExternally");
    }
}
