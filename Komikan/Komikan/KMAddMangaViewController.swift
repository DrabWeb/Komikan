//
//  KMAddMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-03.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMAddMangaViewController: NSViewController {
    
    // The visual effect view for the background of the window
    @IBOutlet weak var backgroundVisualEffectView: NSVisualEffectView!
    
    // The manga we will send back
    var newManga : KMManga = KMManga();
    
    // An array to store all the manga we want to batch open, if thats what we are doing
    var newMangaMultiple : [KMManga] = [KMManga()];
    
    // The NSTimer to update if we can add the manga with our given values
    var addButtonUpdateLoop : NSTimer = NSTimer();
    
    // Does the user want to batch add them?
    var addingMultiple : Bool = false;
    
    // The image view for the cover image
    @IBOutlet weak var coverImageView: NSImageView!
    
    // The text field for the mangas title
    @IBOutlet weak var titleTextField: NSTextField!
    
    // The text field for the mangas series
    @IBOutlet weak var seriesTextField: NSTextField!
    
    // The text field for the mangas artist
    @IBOutlet weak var artistTextField: NSTextField!
    
    // The text field for the mangas writer
    @IBOutlet weak var writerTextField: NSTextField!
    
    // The text field for the mangas tags
    @IBOutlet weak var tagsTextField: NSTextField!
    
    // The checkbox to say if this manga is l-lewd...
    @IBOutlet weak var llewdCheckBox: NSButton!
    
    // The open panel to let the user choose the mangas directory
    var chooseDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    // The "Choose Directory" button
    @IBOutlet weak var chooseDirectoryButton: NSButton!
    
    // When we click chooseDirectoryButton...
    @IBAction func chooseDirectoryButtonPressed(sender: AnyObject) {
        // Run he choose directory open panel
        chooseDirectoryOpenPanel.runModal();
    }
    
    // The add button
    @IBOutlet weak var addButton: NSButton!
    
    // When we click the add button...
    @IBAction func addButtonPressed(sender: AnyObject) {
        // Dismiss the popver
        self.dismissController(self);
        
        // Add the manga we described in the open panel
        addSelf();
    }
    
    /// The combo box that lets you set the manga's group
    @IBOutlet weak var groupSelectionComboBox: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Setup the choose directory open panel
        // Allow multiple files
        chooseDirectoryOpenPanel.allowsMultipleSelection = true;
        
        // Only allow CBZ and CBR
        chooseDirectoryOpenPanel.allowedFileTypes = ["cbz", "cbr"];
        
        // Set the Open button to say choose
        chooseDirectoryOpenPanel.prompt = "Choose";
        
        // Remove all the items from the combo box
        groupSelectionComboBox.removeAllItems();
        
        // Set the combo boxes dropdown to contain all the existing groups
        groupSelectionComboBox.addItemsWithObjectValues((NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.sidebarGroups());
        
        // Start a 0.1 second loop that will set if we can add this manga or not
        addButtonUpdateLoop = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target:self, selector: Selector("updateAddButton"), userInfo: nil, repeats:true);
        
        // Prompt for a manga
        startPrompt();
    }
    
    func addSelf() {
        // If we are only adding one...
        if(!addingMultiple) {
            // Set the new mangas cover image
            newManga.coverImage = coverImageView.image!;
            
            // Resize the cover image to be compressed for faster loading
            newManga.coverImage = newManga.coverImage.resizeToHeight(400);
            
            // Set the new mangas title
            newManga.title = titleTextField.stringValue;
            
            // Set the new mangas series
            newManga.series = seriesTextField.stringValue;
            
            // Set the new mangas artist
            newManga.artist = artistTextField.stringValue;
            
            // Set if the manga is l-lewd...
            newManga.lewd = Bool(llewdCheckBox.state);
            
            // Set the manga's group
            newManga.group = groupSelectionComboBox.stringValue;
            
            // If the group we chose doesnt already exist and the group isnt nothing...
            if(!((NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.sidebarGroups().contains(newManga.group)) && newManga.group != "") {
                // add a new group with the group we chose
                (NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.addItemToSidebar(KMSidebarItemDoc(groupName: newManga.group));
            }
            
            // Set the new mangas directory
            newManga.directory = (chooseDirectoryOpenPanel.URL?.absoluteString.stringByRemovingPercentEncoding!)!.stringByReplacingOccurrencesOfString("file://", withString: "");
            
            // Set the new mangas writer
            newManga.writer = writerTextField.stringValue;
            
            // For every part of the tags text field's string value split at every ", "...
            for (_, currentTag) in tagsTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
                // Print to the log what tag we are adding and what manga we are adding it to
                print("Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                
                // Append the current tags to the mangas tags
                newManga.tags.append(currentTag);
            }
            
            // Post the notification saying we are done and sending back the manga
            NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newManga);
        }
        else {
            for (_, currentMangaURL) in chooseDirectoryOpenPanel.URLs.enumerate() {
                // A temporary variable for storing the manga we are currently working on
                var currentManga : KMManga = KMManga();
                
                // Set the new mangas directory
                currentManga.directory = (currentMangaURL.absoluteString).stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("file://", withString: "");
                
                // Get the information of the manga(Cover image, title, ETC.)(Change this function to be in KMManga)
                currentManga = getMangaInfo(currentManga);
                
                // Set the manga's series
                currentManga.series = seriesTextField.stringValue;
                
                // Set the manga's artist
                currentManga.artist = artistTextField.stringValue;
                
                // Set the manga's writer
                currentManga.writer = writerTextField.stringValue;
                
                // Set if the manga is l-lewd...
                currentManga.lewd = Bool(llewdCheckBox.state);
                
                // Set the manga's group
                currentManga.group = groupSelectionComboBox.stringValue;
                
                // For every part of the tags text field's string value split at every ", "...
                for (_, currentTag) in tagsTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
                    // Print to the log what tag we are adding and what manga we are adding it to
                    print("Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                    
                    // Append the current tags to the mangas tags
                    currentManga.tags.append(currentTag);
                }
                
                // Add curentManga to the newMangaMultiple array
                newMangaMultiple.append(currentManga);
            }
            
            // If the group we chose doesnt already exist and the group isnt nothing...
            if(!((NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.sidebarGroups().contains(groupSelectionComboBox.stringValue)) && groupSelectionComboBox.stringValue != "") {
                // add a new group with the group we chose
                (NSApplication.sharedApplication().delegate as! AppDelegate).sidebarController.addItemToSidebar(KMSidebarItemDoc(groupName: groupSelectionComboBox.stringValue));
            }
            
            // Remove the first element in newMangaMultiple, for some reason its always empty
            newMangaMultiple.removeAtIndex(0);
            
            // Post the notification saying we are done and sending back the manga
            NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newMangaMultiple);
        }
    }
    
    // Updates the add buttons enabled state
    func updateAddButton() {
        // A variable to say if we can add the manga with the given values
        var canAdd : Bool = false;
        
        // If we are only adding one...
        if(!addingMultiple) {
            // If the cover image selected is not the default one...
            if(coverImageView.image != NSImage(named: "NSRevealFreestandingTemplate")) {
                // If the title is not nothing...
                if(titleTextField.stringValue != "") {
                    // If the directory is not nothing...
                    if(chooseDirectoryOpenPanel.URL?.absoluteString != nil) {
                        // Say we can add with these variables
                        canAdd = true;
                    }
                }
            }
        }
        else {
            // Say we can add
            canAdd = true;
        }
        
        // If we can add with these variables...
        if(canAdd) {
            // Enable the add button
            addButton.enabled = true;
        }
        else {
            // Disable the add button
            addButton.enabled = false;
        }
    }
    
    func getMangaInfo(manga : KMManga) -> KMManga {
        // Set the mangas title to the mangas archive name
        manga.title = KMFileUtilities().getFileNameWithoutExtension(NSURL(fileURLWithPath: manga.directory));
        
        // Delete /tmp/komikan/addmanga, if it exists
        do {
            // Remove /tmp/komikan/addmanga
            try NSFileManager().removeItemAtPath("/tmp/komikan/addmanga");
            
            // Print to the log that we deleted it
            print("Deleted /tmp/komikan/addmanga folder for \"" + manga.title + "\"");
            // If there is an error...
        } catch _ as NSError {
            // Print to the log that there is no /tmp/komikan/addmanga folder to delete
            print("No /tmp/komikan/addmanga to delete for \"" + manga.title + "\"");
        }
        
        // Extract the passed manga to /tmp/komikan/addmanga
        KMFileUtilities().extractArchive(manga.directory.stringByReplacingOccurrencesOfString("file://", withString: ""), toDirectory:  "/tmp/komikan/addmanga");
        
        // Clean up the directory
        print(KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/cleanmangadir", arguments: ["/tmp/komikan/addmanga"], waitUntilExit: true));
        
        // Get the first image in the folder, and set the cover image selection views image to it
        do {
            print(String(try NSFileManager().contentsOfDirectoryAtPath("/tmp/komikan/addmanga/")[0]));
            
            // Get the first item in /tmp/komikan/addmanga as an NSImage
            let firstImage : NSImage = NSImage(byReferencingURL: NSURL(fileURLWithPath: "/tmp/komikan/addmanga/" + String(try NSFileManager().contentsOfDirectoryAtPath("/tmp/komikan/addmanga/")[0])));
            
            // Set the cover image selecting views image to firstImage
            manga.coverImage = firstImage;
            
            // Resize the cover image to be compressed for faster loading
            manga.coverImage = manga.coverImage.resizeToHeight(400);
            
            // Print the image to the log(It for some reason needs this print or it wont work)
            print(firstImage);
            
            // If there is an error...
        } catch _ as NSError {
            // Do nothing
        }
        
        // Return the changed manga
        return manga;
    }
    
    // Asks for a manga, and deletes the old ones tmp folder
    func promptForManga() {
        // Delete /tmp/komikan/addmanga
        do {
            // Remove /tmp/komikan/addmanga
            try NSFileManager().removeItemAtPath("/tmp/komikan/addmanga");
            // If there is an error...
        } catch _ as NSError {
            // Do nothing
        }
        
        // Ask for the mangas directory
        chooseDirectoryOpenPanel.runModal();
    }
    
    // The prompt you get when you open this view with the open panel
    func startPrompt() {
        // Prompt for a file
        promptForManga();
        
        // If we selected multiple files...
        if(chooseDirectoryOpenPanel.URLs.count > 1) {
            // Say we are adding multiple
            addingMultiple = true;
            
            // Say we cant edit the image view
            coverImageView.editable = false;
            
            // Dont allow us to set the title
            titleTextField.enabled = false;
            
            // Dont allow us to change the directory
            chooseDirectoryButton.enabled = false;
            
            // Set the cover image image views image to NSFlowViewTemplate
            coverImageView.image = NSImage(named: "NSFlowViewTemplate");
        }
        else {
            // If the directory is not nothing...
            if(chooseDirectoryOpenPanel.URL?.absoluteString != nil) {
                // Set the new mangas directory
                newManga.directory = (chooseDirectoryOpenPanel.URL?.absoluteString)!.stringByRemovingPercentEncoding!;
            
                // Get the information of the manga(Cover image, title, ETC.)(Change this function to be in KMManga)
                newManga = getMangaInfo(newManga);
            
                // Set the cover image views cover image
                coverImageView.image = newManga.coverImage;
            
                // Set the title text fields value to the mangas title
                titleTextField.stringValue = newManga.title;
            }
        }
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
