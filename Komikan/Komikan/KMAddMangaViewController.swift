//
//  KMAddMangaViewController.swift
//  Komikan
//
//  Created by Seth on 2016-01-03.
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
    var addButtonUpdateLoop : Timer = Timer();
    
    // Does the user want to batch add them?
    var addingMultiple : Bool = false;
    
    /// The image view for the cover image
    @IBOutlet weak var coverImageView: NSImageView!
    
    /// The token text field for the mangas title
    @IBOutlet weak var titleTokenTextField: KMSuggestionTokenField!
    
    /// The token text field for the mangas series
    @IBOutlet weak var seriesTokenTextField: KMSuggestionTokenField!
    
    /// The token text field for the mangas artist
    @IBOutlet weak var artistTokenTextField: KMSuggestionTokenField!
    
    /// The token text field for the mangas writer
    @IBOutlet weak var writerTokenTextField: KMSuggestionTokenField!
    
    /// The text field for the mangas tags
    @IBOutlet weak var tagsTextField: KMAlwaysActiveTextField!
    
    /// The token text field for the mangas group
    @IBOutlet weak var groupTokenTextField: KMSuggestionTokenField!
    
    /// The text field for setting the manga's release date(s)
    @IBOutlet var releaseDateTextField: KMAlwaysActiveTextField!
    
    /// The date formatter for releaseDateTextField
    @IBOutlet var releaseDateTextFieldDateFormatter: DateFormatter!
    
    /// The checkbox to say if this manga is l-lewd...
    @IBOutlet weak var llewdCheckBox: NSButton!
    
    /// The button to say if the manga we add should be favourited
    @IBOutlet weak var favouriteButton: KMFavouriteButton!
    
    /// The open panel to let the user choose the mangas directory
    var chooseDirectoryOpenPanel : NSOpenPanel = NSOpenPanel();
    
    /// The "Choose Directory" button
    @IBOutlet weak var chooseDirectoryButton: NSButton!
    
    /// When we click chooseDirectoryButton...
    @IBAction func chooseDirectoryButtonPressed(_ sender: AnyObject) {
        // Run he choose directory open panel
        chooseDirectoryOpenPanel.runModal();
    }
    
    /// The add button
    @IBOutlet weak var addButton: NSButton!
    
    /// When we click the add button...
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        // Dismiss the popver
        self.dismiss(self);
        
        // Add the manga we described in the open panel
        addSelf();
    }
    
    /// The URLs of the files we are adding
    var addingMangaURLs : [URL] = [];
    
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
        
        // Setup all the suggestions for the property text fields
        seriesTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allSeries();
        artistTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allArtists();
        writerTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allWriters();
        groupTokenTextField.suggestions = (NSApplication.shared().delegate as! AppDelegate).mangaGridController.allGroups();
        
        // Start a 0.1 second loop that will set if we can add this manga or not
        addButtonUpdateLoop = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(KMAddMangaViewController.updateAddButton), userInfo: nil, repeats: true);
        
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
            newManga.title = titleTokenTextField.stringValue;
            
            // Set the new mangas series
            newManga.series = seriesTokenTextField.stringValue;
            
            // Set the new mangas artist
            newManga.artist = artistTokenTextField.stringValue;
            
            // If the release date field isnt blank...
            if(releaseDateTextField.stringValue != "") {
                // Set the release date
                newManga.releaseDate = releaseDateTextFieldDateFormatter.date(from: releaseDateTextField.stringValue)!;
            }
            
            // Set if the manga is l-lewd...
            newManga.lewd = Bool(llewdCheckBox.state as NSNumber);
            
            // Set the new mangas directory
            newManga.directory = (addingMangaURLs[0].absoluteString.removingPercentEncoding!).replacingOccurrences(of: "file://", with: "");
            
            // Set the new mangas writer
            newManga.writer = writerTokenTextField.stringValue;
            
            // For every part of the tags text field's string value split at every ", "...
            for (_, currentTag) in tagsTextField.stringValue.components(separatedBy: ", ").enumerated() {
                // Print to the log what tag we are adding and what manga we are adding it to
                print("KMAddMangaViewController: Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                
                // Append the current tags to the mangas tags
                newManga.tags.append(currentTag);
            }
            
            // Set the new manga's group
            newManga.group = groupTokenTextField.stringValue;
            
            // Set if the manga is a favourite
            newManga.favourite = Bool(favouriteButton.state as NSNumber);
            
            // Post the notification saying we are done and sending back the manga
            NotificationCenter.default.post(name: Notification.Name(rawValue: "KMAddMangaViewController.Finished"), object: newManga);
        }
        else {
            for (_, currentMangaURL) in addingMangaURLs.enumerated() {
                // A temporary variable for storing the manga we are currently working on
                var currentManga : KMManga = KMManga();
                
                // Set the new mangas directory
                currentManga.directory = (currentMangaURL.absoluteString).removingPercentEncoding!.replacingOccurrences(of: "file://", with: "");
                
                // Get the information of the manga(Cover image, title, ETC.)(Change this function to be in KMManga)
                currentManga = getMangaInfo(currentManga);
                
                // Set the manga's series
                currentManga.series = seriesTokenTextField.stringValue;
                
                // Set the manga's artist
                currentManga.artist = artistTokenTextField.stringValue;
                
                // Set the manga's writer
                currentManga.writer = writerTokenTextField.stringValue;
                
                // If the release date field isnt blank...
                if(releaseDateTextField.stringValue != "") {
                    // Set the release date
                    currentManga.releaseDate = releaseDateTextFieldDateFormatter.date(from: releaseDateTextField.stringValue)!;
                }
                
                // Set if the manga is l-lewd...
                currentManga.lewd = Bool(llewdCheckBox.state as NSNumber);
                
                // For every part of the tags text field's string value split at every ", "...
                for (_, currentTag) in tagsTextField.stringValue.components(separatedBy: ", ").enumerated() {
                    // Print to the log what tag we are adding and what manga we are adding it to
                    print("KMAddMangaViewController: Adding tag \"" + currentTag + "\" to \"" + newManga.title + "\"");
                    
                    // Append the current tags to the mangas tags
                    currentManga.tags.append(currentTag);
                }
                
                // Set the manga's group
                currentManga.group = groupTokenTextField.stringValue;
                
                // Set if the manga is a favourite
                currentManga.favourite = Bool(favouriteButton.state as NSNumber);
                
                // Add curentManga to the newMangaMultiple array
                newMangaMultiple.append(currentManga);
            }
            
            // Remove the first element in newMangaMultiple, for some reason its always empty
            newMangaMultiple.remove(at: 0);
            
            // Post the notification saying we are done and sending back the manga
            NotificationCenter.default.post(name: Notification.Name(rawValue: "KMAddMangaViewController.Finished"), object: newMangaMultiple);
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
            print("KMAddMangaViewController: Fetching JSON data...");
            
            /// The selected Mangas folder it is in
            var folderURLString : String = (addingMangaURLs.first?.absoluteString)!;
            
            // Remove everything after the last "/" in the string so we can get the folder
            folderURLString = folderURLString.substring(to: folderURLString.range(of: "/", options: NSString.CompareOptions.backwards, range: nil, locale: nil)!.lowerBound);
            
            // Append a slash to the end because it removes it
            folderURLString += "/";
            
            // Remove the file:// from the folder URL string
            folderURLString = folderURLString.replacingOccurrences(of: "file://", with: "");
            
            // Remove the percent encoding from the folder URL string
            folderURLString = folderURLString.removingPercentEncoding!;
            
            // Add the "Komikan" folder to the end of it
            folderURLString += "Komikan/"
            
            // If we chose multiple manga...
            if(addingMangaURLs.count > 1) {
                /// The URL of the multiple Manga's possible JSON file
                let mangaJsonURL : String = folderURLString + "series.json";
                
                // If there is a "series.json" file in the Manga's folder...
                if(FileManager.default.fileExists(atPath: mangaJsonURL)) {
                    // Print to the log that we found the JSON file for the selected manga
                    print("KMAddMangaViewController: Found a series.json file for the selected Manga at \"" + mangaJsonURL + "\"");
                    
                    /// The SwiftyJSON object for the Manga's JSON info
                    let mangaJson = JSON(data: FileManager.default.contents(atPath: mangaJsonURL)!);
                    
                    // Set the series text field's value to the series value
                    seriesTokenTextField.stringValue = mangaJson["series"].stringValue;
                    
                    // Set the series text field's value to the artist value
                    artistTokenTextField.stringValue = mangaJson["artist"].stringValue;
                    
                    // Set the series text field's value to the writer value
                    writerTokenTextField.stringValue = mangaJson["writer"].stringValue;
                    
                    // If there is a released value...
                    if(mangaJson["published"].exists()) {
                        // If there is a release date listed...
                        if(mangaJson["published"].stringValue.lowercased() != "unknown" && mangaJson["published"].stringValue != "") {
                            // If the release date is valid...
                            if(releaseDateTextFieldDateFormatter.date(from: mangaJson["published"].stringValue) != nil) {
                                // Set the release date text field's value to the release date value
                                releaseDateTextField.stringValue = releaseDateTextFieldDateFormatter.string(from: (releaseDateTextFieldDateFormatter.date(from: mangaJson["published"].stringValue)!));
                            }
                        }
                    }
                    
                    // For every item in the tags value of the JSON...
                    for(_, currentTag) in mangaJson["tags"].arrayValue.enumerated() {
                        // Print the current tag
                        print("KMAddMangaViewController: Found tag \"" + currentTag.stringValue + "\"");
                        
                        // Add the current item to the tag text field
                        tagsTextField.stringValue += currentTag.stringValue + ", ";
                    }
                    
                    // If the tags text field is not still blank...
                    if(tagsTextField.stringValue != "") {
                        // Remove the extra ", " from the tags text field
                        tagsTextField.stringValue = tagsTextField.stringValue.substring(to: tagsTextField.stringValue.index(before: tagsTextField.stringValue.characters.index(before: tagsTextField.stringValue.endIndex)));
                    }
                    
                    // Set the group text field's value to the group value
                    groupTokenTextField.stringValue = mangaJson["group"].stringValue;
                    
                    // Set the favourites buttons value to the favourites value of the JSON
                    favouriteButton.state = Int.fromBool(bool: mangaJson["favourite"].boolValue);
                    
                    // Update the favourites button
                    favouriteButton.updateButton();
                    
                    // Set the l-lewd... checkboxes state to the lewd value of the JSON
                    llewdCheckBox.state = Int.fromBool(bool: mangaJson["lewd"].boolValue);
                }
            }
            // If we chose 1 manga...
            else if(addingMangaURLs.count == 1) {
                /// The URL to the single Manga's possible JSON file
                let mangaJsonURL : String = folderURLString + (addingMangaURLs.first?.lastPathComponent.removingPercentEncoding!)! + ".json";
                
                // If there is a file that has the same name but with a .json on the end...
                if(FileManager.default.fileExists(atPath: mangaJsonURL)) {
                    // Print to the log that we found the JSON file for the single manga
                    print("KMAddMangaViewController: Found single Manga's JSON file at \"" + mangaJsonURL + "\"");
                    
                    /// The SwiftyJSON object for the Manga's JSON info
                    let mangaJson = JSON(data: FileManager.default.contents(atPath: mangaJsonURL)!);
                    
                    // If the title value from the JSON is not "auto" or blank...
                    if(mangaJson["title"].stringValue != "auto" && mangaJson["title"].stringValue != "") {
                        // Set the title text fields value to the title value from the JSON
                        titleTokenTextField.stringValue = mangaJson["title"].stringValue;
                        
                        // Say we got a title from the JSON
                        gotTitleFromJSON = true;
                    }
                    
                    // If the cover image value from the JSON is not "auto" or blank...
                    if(mangaJson["cover-image"].stringValue != "auto" && mangaJson["cover-image"].stringValue != "") {
                        // If the first character is not a "/"...
                        if(mangaJson["cover-image"].stringValue.substring(to: mangaJson["cover-image"].stringValue.characters.index(after: mangaJson["cover-image"].stringValue.startIndex)) == "/") {
                            // Set the cover image views image to an NSImage at the path specified in the JSON
                            coverImageView.image = NSImage(contentsOf: URL(fileURLWithPath: mangaJson["cover-image"].stringValue));
                            
                            // Say we got a cover image from the JSON
                            gotCoverImageFromJSON = true;
                        }
                        else {
                            // Get the relative image
                            coverImageView.image = NSImage(contentsOf: URL(fileURLWithPath: folderURLString + mangaJson["cover-image"].stringValue));
                            
                            // Say we got a cover image from the JSON
                            gotCoverImageFromJSON = true;
                        }
                    }
                    
                    // Set the series text field's value to the series value
                    seriesTokenTextField.stringValue = mangaJson["series"].stringValue;
                    
                    // Set the series text field's value to the artist value
                    artistTokenTextField.stringValue = mangaJson["artist"].stringValue;
                    
                    // Set the series text field's value to the writer value
                    writerTokenTextField.stringValue = mangaJson["writer"].stringValue;
                    
                    // If there is a released value...
                    if(mangaJson["published"].exists()) {
                        // If there is a release date listed...
                        if(mangaJson["published"].stringValue.lowercased() != "unknown" && mangaJson["published"].stringValue != "") {
                            // If the release date is valid...
                            if(releaseDateTextFieldDateFormatter.date(from: mangaJson["published"].stringValue) != nil) {
                                // Set the release date text field's value to the release date value
                                releaseDateTextField.stringValue = releaseDateTextFieldDateFormatter.string(from: (releaseDateTextFieldDateFormatter.date(from: mangaJson["published"].stringValue)!));
                            }
                        }
                    }
                    
                    // For every item in the tags value of the JSON...
                    for(_, currentTag) in mangaJson["tags"].arrayValue.enumerated() {
                        // Print the current tag
                        print("KMAddMangaViewController: Found tag \"" + currentTag.stringValue + "\"");
                        
                        // Add the current item to the tag text field
                        tagsTextField.stringValue += currentTag.stringValue + ", ";
                    }
                    
                    // If the tags text field is not still blank...
                    if(tagsTextField.stringValue != "") {
                        // Remove the extra ", " from the tags text field
                        tagsTextField.stringValue = tagsTextField.stringValue.substring(to: tagsTextField.stringValue.index(before: tagsTextField.stringValue.characters.index(before: tagsTextField.stringValue.endIndex)));
                    }
                    
                    // Set the group text field's value to the group value
                    groupTokenTextField.stringValue = mangaJson["group"].stringValue;
                    
                    // Set the favourites buttons value to the favourites value of the JSON
                    favouriteButton.state = Int.fromBool(bool: mangaJson["favourite"].boolValue);
                    
                    // Update the favourites button
                    favouriteButton.updateButton();
                    
                    // Set the l-lewd... checkboxes state to the lewd value of the JSON
                    llewdCheckBox.state = Int.fromBool(bool: mangaJson["lewd"].boolValue);
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
                if(titleTokenTextField.stringValue != "") {
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
            addButton.isEnabled = true;
        }
        else {
            // Disable the add button
            addButton.isEnabled = false;
        }
    }
    
    func getMangaInfo(_ manga : KMManga) -> KMManga {
        // Set the mangas title to the mangas archive name
        manga.title = KMFileUtilities().getFileNameWithoutExtension(manga.directory);
        
        // Delete /tmp/komikan/addmanga, if it exists
        do {
            // Remove /tmp/komikan/addmanga
            try FileManager().removeItem(atPath: "/tmp/komikan/addmanga");
            
            // Print to the log that we deleted it
            print("KMAddMangaViewController: Deleted /tmp/komikan/addmanga folder for \"" + manga.title + "\"");
            // If there is an error...
        } catch _ as NSError {
            // Print to the log that there is no /tmp/komikan/addmanga folder to delete
            print("KMAddMangaViewController: No /tmp/komikan/addmanga to delete for \"" + manga.title + "\"");
        }
        
        // If the manga's file isnt a folder...
        if(!KMFileUtilities().isFolder(manga.directory.replacingOccurrences(of: "file://", with: ""))) {
            // Extract the passed manga to /tmp/komikan/addmanga
            KMFileUtilities().extractArchive(manga.directory.replacingOccurrences(of: "file://", with: ""), toDirectory:  "/tmp/komikan/addmanga");
        }
        // If the manga's file is a folder...
        else {
            // Copy the folder to /tmp/komikan/addmanga
            do {
                try FileManager.default.copyItem(atPath: manga.directory.replacingOccurrences(of: "file://", with: ""), toPath: "/tmp/komikan/addmanga");
            }
            catch _ as NSError {
                
            }
        }
        
        // Clean up the directory
        print("KMAddMangaViewController: \(KMCommandUtilities().runCommand(Bundle.main.bundlePath + "/Contents/Resources/cleanmangadir", arguments: ["/tmp/komikan/addmanga"], waitUntilExit: true))");
        
        /// All the files in /tmp/komikan/addmanga
        var addMangaFolderContents : [String] = [];
        
        // Get the contents of /tmp/komikan/addmanga
        do {
            // Set addMangaFolderContents to all the files in /tmp/komikan/addmanga
            addMangaFolderContents = try FileManager().contentsOfDirectory(atPath: "/tmp/komikan/addmanga");
            
            // Sort the files by their integer values
            addMangaFolderContents = (addMangaFolderContents as NSArray).sortedArray(using: [NSSortDescriptor(key: "integerValue", ascending: true)]) as! [String];
        }
        catch _ as NSError {
            // Do nothing
        }
        
        // Get the first image in the folder, and set the cover image selection views image to it
        // The first item in /tmp/komikan/addmanga
        var firstImage : NSImage = NSImage();
        
        // For every item in the addmanga folder...
        for(_, currentFile) in addMangaFolderContents.enumerated() {
            // If this file is an image and not a dot file...
            if(KMFileUtilities().isImage("/tmp/komikan/addmanga/" + (currentFile )) && ((currentFile).substring(to: (currentFile).characters.index(after: (currentFile).startIndex))) != ".") {
                // If the first image isnt already set...
                if(firstImage.size == NSSize.zero) {
                    // Set the first image to the current image file
                    firstImage = NSImage(contentsOfFile: "/tmp/komikan/addmanga/\(currentFile)")!;
                }
            }
        }
        
        // Set the cover image selecting views image to firstImage
        manga.coverImage = firstImage;
        
        // Resize the cover image to be compressed for faster loading
        manga.coverImage = manga.coverImage.resizeToHeight(400);
        
        // Print the image to the log(It for some reason needs this print or it wont work)
        print("KMAddMangaViewController: \(firstImage)");
        
        // Return the changed manga
        return manga;
    }
    
    // Asks for a manga, and deletes the old ones tmp folder
    func promptForManga() {
        // Delete /tmp/komikan/addmanga
        do {
            // Remove /tmp/komikan/addmanga
            try FileManager().removeItem(atPath: "/tmp/komikan/addmanga");
            // If there is an error...
        } catch _ as NSError {
            // Do nothing
        }
        
        // Ask for the manga's directory, and if we clicked "Choose"...
        if(Bool(chooseDirectoryOpenPanel.runModal() as NSNumber)) {
            // Set the adding manga URLs to the choose directory open panels URLs
            addingMangaURLs = chooseDirectoryOpenPanel.urls;
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
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: keyHandler) as AnyObject?;
        
        // If we selected multiple files...
        if(addingMangaURLs.count > 1) {
            // Say we are adding multiple
            addingMultiple = true;
            
            // Say we cant edit the image view
            coverImageView.isEditable = false;
            
            // Dont allow us to set the title
            titleTokenTextField.isEnabled = false;
            
            // Dont allow us to change the directory
            chooseDirectoryButton.isEnabled = false;
            
            // Set the cover image image views image to NSFlowViewTemplate
            coverImageView.image = NSImage(named: "NSFlowViewTemplate");
        }
        else {
            // If the directory is not nothing...
            if(addingMangaURLs != []) {
                // Set the new mangas directory
                newManga.directory = addingMangaURLs[0].absoluteString.removingPercentEncoding!;
            
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
                    titleTokenTextField.stringValue = newManga.title;
                }
            }
        }
    }
    
    func keyHandler(_ event : NSEvent) -> NSEvent {
        // If we pressed enter...
        if(event.keyCode == 36 || event.keyCode == 76) {
            // If the add button is enabled...
            if(addButton.isEnabled) {
                // Hide the popover
                self.dismiss(self);
                
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
        
        // Stop the add button update loop
        addButtonUpdateLoop.invalidate();
    }
    
    func styleWindow() {
        // Set the background effect view to be dark
        backgroundVisualEffectView.material = NSVisualEffectMaterial.dark;
    }
}
