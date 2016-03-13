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
    
    @IBOutlet weak var groupTextField: NSTextField!
    
    // The checkbox to say if this manga is l-lewd...
    @IBOutlet weak var llewdCheckBox: NSButton!
    
    /// The button to say if the manga we add should be favourited
    @IBOutlet weak var favouriteButton: KMFavouriteButton!
    
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
    
    /// The URLs of the files we are adding
    var addingMangaURLs : [NSURL] = [];
    
    /// The local key down monitor
    var keyDownMonitor : AnyObject?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Update the favourite button
        favouriteButton.updateButton();
        
        // Setup the choose directory open panel
        // Allow multiple files
        chooseDirectoryOpenPanel.allowsMultipleSelection = true;
        
        // Only allow CBZ, CBR, ZIP, RAR and Folders
        chooseDirectoryOpenPanel.allowedFileTypes = ["cbz", "cbr", "zip", "rar"];
        chooseDirectoryOpenPanel.canChooseDirectories = true;
        
        // Set the Open button to say choose
        chooseDirectoryOpenPanel.prompt = "Choose";
        
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
            
            // Set the new mangas directory
            newManga.directory = (addingMangaURLs[0].absoluteString.stringByRemovingPercentEncoding!).stringByReplacingOccurrencesOfString("file://", withString: "");
            
            // Set the new mangas writer
            newManga.writer = writerTextField.stringValue;
            
            // For every part of the tags text field's string value split at every ", "...
            for (_, currentTag) in tagsTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
                // Print to the log what tag we are adding and what manga we are adding it to
                print("Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                
                // Append the current tags to the mangas tags
                newManga.tags.append(currentTag);
            }
            
            // Set the new manga's group
            newManga.group = groupTextField.stringValue;
            
            // Set if the manga is a favourite
            newManga.favourite = Bool(favouriteButton.state);
            
            // Post the notification saying we are done and sending back the manga
            NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newManga);
        }
        else {
            for (_, currentMangaURL) in addingMangaURLs.enumerate() {
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
                
                // For every part of the tags text field's string value split at every ", "...
                for (_, currentTag) in tagsTextField.stringValue.componentsSeparatedByString(", ").enumerate() {
                    // Print to the log what tag we are adding and what manga we are adding it to
                    print("Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                    
                    // Append the current tags to the mangas tags
                    currentManga.tags.append(currentTag);
                }
                
                // Set the manga's group
                currentManga.group = groupTextField.stringValue;
                
                // Set if the manga is a favourite
                currentManga.favourite = Bool(favouriteButton.state);
                
                // Add curentManga to the newMangaMultiple array
                newMangaMultiple.append(currentManga);
            }
            
            // Remove the first element in newMangaMultiple, for some reason its always empty
            newMangaMultiple.removeAtIndex(0);
            
            // Post the notification saying we are done and sending back the manga
            NSNotificationCenter.defaultCenter().postNotificationName("KMAddMangaViewController.Finished", object: newMangaMultiple);
        }
    }
    
    /// DId the user specify a custom title in the JSON?
    var gotTitleFromJSON : Bool = false;
    
    /// Did the user specify a custom cover image in the JSON?
    var gotCoverImageFromJSON : Bool = false;
    
    /// Gets the data from the optional JSON file that contains metadata info
    func fetchJsonData() {
        // If we actually selected anything...
        if(addingMangaURLs != []) {
            // Print to the log that we are fetching the JSON data
            print("Fetching JSON data...");
            
            /// The selected Mangas folder it is in
            var folderURLString : String = (addingMangaURLs.first?.absoluteString)!;
            
            // Remove everything after the last "/" in the string so we can get the folder
            folderURLString = folderURLString.substringToIndex(folderURLString.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)!.startIndex);
            
            // Append a slash to the end because it removes it
            folderURLString += "/";
            
            // Remove the file:// from the folder URL string
            folderURLString = folderURLString.stringByReplacingOccurrencesOfString("file://", withString: "");
            
            // Remove the percent encoding from the folder URL string
            folderURLString = folderURLString.stringByRemovingPercentEncoding!;
            
            // Add the "Komikan" folder to the end of it
            folderURLString += "Komikan/"
            
            // If we chose multiple manga...
            if(addingMangaURLs.count > 1) {
                /// The URL of the multiple Manga's possible JSON file
                let mangaJsonURL : String = folderURLString + "series.json";
                
                // If there is a "series.json" file in the Manga's folder...
                if(NSFileManager.defaultManager().fileExistsAtPath(mangaJsonURL)) {
                    // Print to the log that we found the JSON file for the selected manga
                    print("Found a series.json file for the selected Manga at \"" + mangaJsonURL + "\"");
                    
                    /// The SwiftyJSON object for the Manga's JSON info
                    let mangaJson = JSON(data: NSFileManager.defaultManager().contentsAtPath(mangaJsonURL)!);
                    
                    // Set the series text field's value to the series value
                    seriesTextField.stringValue = mangaJson["series"].stringValue;
                    
                    // Set the series text field's value to the artist value
                    artistTextField.stringValue = mangaJson["artist"].stringValue;
                    
                    // Set the series text field's value to the writer value
                    writerTextField.stringValue = mangaJson["writer"].stringValue;
                    
                    // For every item in the tags value of the JSON...
                    for(_, currentTag) in mangaJson["tags"].arrayValue.enumerate() {
                        // Print the current tag
                        print("Found tag \"" + currentTag.stringValue + "\"");
                        
                        // Add the current item to the tag text field
                        tagsTextField.stringValue += currentTag.stringValue + ", ";
                    }
                    
                    // If the tags text field is not still blank...
                    if(tagsTextField.stringValue != "") {
                        // Remove the extra ", " from the tags text field
                        tagsTextField.stringValue = tagsTextField.stringValue.substringToIndex(tagsTextField.stringValue.endIndex.predecessor().predecessor());
                    }
                    
                    // Set the group text field's value to the group value
                    groupTextField.stringValue = mangaJson["group"].stringValue;
                    
                    // Set the favourites buttons value to the favourites value of the JSON
                    favouriteButton.state = Int(mangaJson["favourite"].boolValue);
                    
                    // Update the favourites button
                    favouriteButton.updateButton();
                    
                    // Set the l-lewd... checkboxes state to the lewd value of the JSON
                    llewdCheckBox.state = Int(mangaJson["lewd"].boolValue);
                }
            }
            // If we chose 1 manga...
            else if(addingMangaURLs.count == 1) {
                /// The URL to the single Manga's possible JSON file
                let mangaJsonURL : String = folderURLString + (addingMangaURLs.first?.lastPathComponent!.stringByRemovingPercentEncoding!)! + ".json";
                
                // If there is a file that has the same name but with a .json on the end...
                if(NSFileManager.defaultManager().fileExistsAtPath(mangaJsonURL)) {
                    // Print to the log that we found the JSON file for the single manga
                    print("Found single Manga's JSON file at \"" + mangaJsonURL + "\"");
                    
                    /// The SwiftyJSON object for the Manga's JSON info
                    let mangaJson = JSON(data: NSFileManager.defaultManager().contentsAtPath(mangaJsonURL)!);
                    
                    // If the title value from the JSON is not "auto" or blank...
                    if(mangaJson["title"].stringValue != "auto" && mangaJson["title"].stringValue != "") {
                        // Set the title text fields value to the title value from the JSON
                        titleTextField.stringValue = mangaJson["title"].stringValue;
                        
                        // Say we got a title from the JSON
                        gotTitleFromJSON = true;
                    }
                    
                    // If the cover image value from the JSON is not "auto" or blank...
                    if(mangaJson["cover-image"].stringValue != "auto" && mangaJson["cover-image"].stringValue != "") {
                        // If the first character is not a "/"...
                        if(mangaJson["cover-image"].stringValue.substringToIndex(mangaJson["cover-image"].stringValue.startIndex.successor()) == "/") {
                            // Set the cover image views image to an NSImage at the path specified in the JSON
                            coverImageView.image = NSImage(contentsOfURL: NSURL(fileURLWithPath: mangaJson["cover-image"].stringValue));
                            
                            // Say we got a cover image from the JSON
                            gotCoverImageFromJSON = true;
                        }
                        else {
                            // Get the relative image
                            coverImageView.image = NSImage(contentsOfURL: NSURL(fileURLWithPath: folderURLString + mangaJson["cover-image"].stringValue));
                            
                            // Say we got a cover image from the JSON
                            gotCoverImageFromJSON = true;
                        }
                    }
                    
                    // Set the series text field's value to the series value
                    seriesTextField.stringValue = mangaJson["series"].stringValue;
                    
                    // Set the series text field's value to the artist value
                    artistTextField.stringValue = mangaJson["artist"].stringValue;
                    
                    // Set the series text field's value to the writer value
                    writerTextField.stringValue = mangaJson["writer"].stringValue;
                    
                    // For every item in the tags value of the JSON...
                    for(_, currentTag) in mangaJson["tags"].arrayValue.enumerate() {
                        // Print the current tag
                        print("Found tag \"" + currentTag.stringValue + "\"");
                        
                        // Add the current item to the tag text field
                        tagsTextField.stringValue += currentTag.stringValue + ", ";
                    }
                    
                    // If the tags text field is not still blank...
                    if(tagsTextField.stringValue != "") {
                        // Remove the extra ", " from the tags text field
                        tagsTextField.stringValue = tagsTextField.stringValue.substringToIndex(tagsTextField.stringValue.endIndex.predecessor().predecessor());
                    }
                    
                    // Set the group text field's value to the group value
                    groupTextField.stringValue = mangaJson["group"].stringValue;
                    
                    // Set the favourites buttons value to the favourites value of the JSON
                    favouriteButton.state = Int(mangaJson["favourite"].boolValue);
                    
                    // Update the favourites button
                    favouriteButton.updateButton();
                    
                    // Set the l-lewd... checkboxes state to the lewd value of the JSON
                    llewdCheckBox.state = Int(mangaJson["lewd"].boolValue);
                    
//                    {
//                        "title":"Charlotte - Chapter 1",
//                        "cover-image":"Charlotte - Chapter 1.cbz.png",
//                        "series":"Charlotte",
//                        "artist":"Chibimaru and Tsurusaki Yuu",
//                        "writer":"Maeda Jun",
//                        "tags":["Comedy", "School", "Shoujo Ai", "Slice of Life"],
//                        "group":"Finished",
//                        "favourite":false,
//                        "lewd":false,
//                        "current-page":1,
//                        "page-count":21,
//                        "filename":"Charlotte - Chapter 1.cbz",
//                        "saturation":1.0,
//                        "brightness":0.0,
//                        "contrast":1.0,
//                        "sharpness":0.0
//                    }
                    
//                    newManga.currentPage = mangaJson["current-page"].intValue - 1;
//                    newManga.pageCount = mangaJson["page-count"].intValue;
//                    
//                    newManga.saturation = CGFloat(mangaJson["saturation"].floatValue);
//                    newManga.brightness = CGFloat(mangaJson["brightness"].floatValue);
//                    newManga.contrast = CGFloat(mangaJson["contrast"].floatValue);
//                    newManga.sharpness = CGFloat(mangaJson["sharpness"].floatValue);
//                    
//                    newManga.updatePercent();
                }
            }
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
                    if(addingMangaURLs != []) {
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
        manga.title = KMFileUtilities().getFileNameWithoutExtension(manga.directory);
        
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
        
        // If the manga's file isnt a folder...
        if(!KMFileUtilities().isFolder(manga.directory.stringByReplacingOccurrencesOfString("file://", withString: ""))) {
            // Extract the passed manga to /tmp/komikan/addmanga
            KMFileUtilities().extractArchive(manga.directory.stringByReplacingOccurrencesOfString("file://", withString: ""), toDirectory:  "/tmp/komikan/addmanga");
        }
        // If the manga's file is a folder...
        else {
            // Copy the folder to /tmp/komikan/addmanga
            do {
                try NSFileManager.defaultManager().copyItemAtPath(manga.directory.stringByReplacingOccurrencesOfString("file://", withString: ""), toPath: "/tmp/komikan/addmanga");
            }
            catch _ as NSError {
                
            }
        }
        
        // Clean up the directory
        print(KMCommandUtilities().runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/cleanmangadir", arguments: ["/tmp/komikan/addmanga"], waitUntilExit: true));
        
        /// All the files in /tmp/komikan/addmanga
        var addMangaFolderContents : NSArray = [];
        
        // Get the contents of /tmp/komikan/addmanga
        do {
            // Set addMangaFolderContents to all the files in /tmp/komikan/addmanga
            addMangaFolderContents = try NSFileManager().contentsOfDirectoryAtPath("/tmp/komikan/addmanga");
            
            // Sort the files by their integer values
            addMangaFolderContents = addMangaFolderContents.sortedArrayUsingDescriptors([NSSortDescriptor(key: "integerValue", ascending: true)]);
        }
        catch _ as NSError {
            // Do nothing
        }
        
        // Get the first image in the folder, and set the cover image selection views image to it
        // The first item in /tmp/komikan/addmanga
        var firstImage : NSImage = NSImage();
        
        // For every item in the addmanga folder...
        for(_, currentFile) in addMangaFolderContents.enumerate() {
            // If this file is an image and not a dot file...
            if(KMFileUtilities().isImage("/tmp/komikan/addmanga/" + (currentFile as! String)) && ((currentFile as! String).substringToIndex((currentFile as! String).startIndex.successor())) != ".") {
                // If the first image isnt already set...
                if(firstImage.size == NSSize.zero) {
                    // Set the first image to the current image file
                    firstImage = NSImage(contentsOfFile: "/tmp/komikan/addmanga/" + (currentFile as! String))!;
                }
            }
        }
        
        // Set the cover image selecting views image to firstImage
        manga.coverImage = firstImage;
        
        // Resize the cover image to be compressed for faster loading
        manga.coverImage = manga.coverImage.resizeToHeight(400);
        
        // Print the image to the log(It for some reason needs this print or it wont work)
        print(firstImage);
        
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
        
        // Ask for the mangas directory, and if we clicked "Choose"...
        if(Bool(chooseDirectoryOpenPanel.runModal())) {
            // Set the adding manga URLs to the choose directory open panels URLs
            addingMangaURLs = chooseDirectoryOpenPanel.URLs;
        }
    }
    
    // The prompt you get when you open this view with the open panel
    func startPrompt() {
        // If addingMangaURLs is []...
        if(addingMangaURLs == []) {
            // Prompt for a file
            promptForManga();
        }
        
        // Fetch the JSON data
        fetchJsonData();
        
        // Subscribe to the key down event
        keyDownMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: keyHandler);
        
        // If we selected multiple files...
        if(addingMangaURLs.count > 1) {
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
            if(addingMangaURLs != []) {
                // Set the new mangas directory
                newManga.directory = addingMangaURLs[0].absoluteString.stringByRemovingPercentEncoding!;
            
                // Get the information of the manga(Cover image, title, ETC.)(Change this function to be in KMManga)
                newManga = getMangaInfo(newManga);
            
                // If we didnt get a cover image from the JSON...
                if(!gotCoverImageFromJSON) {
                    // Set the cover image views cover image
                    coverImageView.image = newManga.coverImage;
                }
            
                // If we didnt get a title from the JSON...
                if(!gotTitleFromJSON) {
                    // Set the title text fields value to the mangas title
                    titleTextField.stringValue = newManga.title;
                }
            }
        }
    }
    
    func keyHandler(event : NSEvent) -> NSEvent {
        // If we pressed enter...
        if(event.keyCode == 36 || event.keyCode == 76) {
            // If the add button is enabled...
            if(addButton.enabled) {
                // Hide the popover
                self.dismissController(self);
                
                // Add the chosen manga
                addSelf();
            }
        }
        
        // Return the event
        return event;
    }
    
    override func viewWillDisappear() {
        // Unsubscribe from key down
        NSEvent.removeMonitor(keyDownMonitor!);
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.Dark;
    }
}
