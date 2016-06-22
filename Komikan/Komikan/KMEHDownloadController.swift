//
//  KMEHDownloadController.swift
//  Komikan
//
//  Created by Seth on 2016-01-28.
//

import Foundation
import SWXMLHash

// Manages downloading from E-Hentai and ExHentai
class KMEHDownloadController : NSObject {
    // The queue of downloads(Each element as a link to download)
    var downloadQueue : [KMEHDownloadItem] = [];
    
    // Are we currently downloading the queue items?
    var currentlyDownloading : Bool = false;
    
    // A bool to say if once the queue downloader is done, we should do it again to download the new items
    var queueHasMore : Bool = false;
    
    /// The KMEHDownloadItem to send back to the main View Controller
    var sendBackItem : KMEHDownloadItem = KMEHDownloadItem(url: "");
    
    // Adds the speicified URL to the download queue
    func addItemToQueue(item : KMEHDownloadItem) {
        /// Was the URL for this download item invalid?
        var invalidURL : Bool = false;
        
        // If the URL exists...
        if(NSData(contentsOfURL: NSURL(string: item.url)!) != nil) {
            // If the URL is on ExHentai or E-Hentai...
            if(NSURL(string: item.url)!.host!.containsString("exhentai.org") || NSURL(string: item.url)!.host!.containsString("g.e-hentai.org")) {
                // Print to the log what item was added to the queue
                print("KMEHDownloadController: Added \"" + item.url + "\" to queue");
                
                // Show the notification saying the item is added to the queue
                KMNotificationUtilities().sendNotification("Komikan", message: "Added \"" + item.url + "\" to the download queue");
                
                // Add this item to the end of downloadQueue
                downloadQueue.append(item);
                
                // If we arent currently downloading queue items...
                if(!currentlyDownloading) {
                    // Spawn a new thread for downloading
                    NSThread.detachNewThreadSelector(Selector("downloadThread"), toTarget: self, withObject: nil);
                }
                else {
                    // Say there will be more to download
                    queueHasMore = true;
                }
            }
            else {
                // Say the URL was invalid
                invalidURL = true;
            }
        }
        else {
            // Say the URL was invalid
            invalidURL = true;
        }
        
        // If the URL was invalid...
        if(invalidURL) {
            // Print to the log that the item had an invalid URL
            print("KMEHDownloadController: Invalid URL for \"" + item.url + "\"");
            
            // Show the notification saying the item couldnt be added
            KMNotificationUtilities().sendNotification("Komikan", message: "Invalid URL for \"" + item.url + "\"");
        }
    }
    
    // This function manages downloading the queue items, and is meant to be spawn in a new thread
    func downloadThread() {
        // Say we are currently downloading the queue items
        currentlyDownloading = true;
        
        // For every item in the download queue...
        for(_, currentItem) in downloadQueue.enumerate() {
            // Say we are currently downloading something
            print("KMEHDownloadController: Downloading item: \(currentItem.url)");
            
            // Create the new notification to tell the user the download has started
            let startedNotification = NSUserNotification();
            
            // Set the title
            startedNotification.title = "Komikan";
            
            // Set the informative text
            startedNotification.informativeText = "Started download for \"" + currentItem.url + "\"";
            
            // Set the notifications identifier to be an obscure string, so we can show multiple at once
            startedNotification.identifier = NSUUID().UUIDString;
            
            // Deliver the notification
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(startedNotification);
            
            // If its on ExHentai...
            if(currentItem.onExHentai) {
                // Call the download function for the current item with the current item we want to download
                downloadFromEX(currentItem);
            }
            // If its on E-Hentai...
            else {
                // Call the download function for the current item with the current item we want to download
                downloadFromEH(currentItem);
            }
            
            // Remove this item from the queue(Converts to an NSMutableArray first so it can remove objects and not just indexes)
            let downloadQueueNSArray : NSMutableArray = NSMutableArray(array: downloadQueue);
            downloadQueueNSArray.removeObject(currentItem);
            downloadQueue = Array(downloadQueueNSArray) as! [KMEHDownloadItem];
        }
        
        // Say we are no longer downloading the queue items
        currentlyDownloading = false;
        
        // If download queue is blank...
        if(downloadQueue.isEmpty) {
            // Say the queue is empty
            queueHasMore = false;
        }
        
        // If there are more to download...
        if(queueHasMore) {
            // Call this function again
            downloadThread();
        }
    }
    
    /// Sends the passed KMEHDownloadItem to the main View Controller
    func sendBackToMainThread() {
        // Post the notification saying we are done and sending back the manga
        NSNotificationCenter.defaultCenter().postNotificationName("KMEHViewController.Finished", object: sendBackItem.manga);
    }
    
    // Adds the specified items manga from E-Hentai
    func downloadFromEH(item : KMEHDownloadItem) {
        // A variable we will use so we can set the tasks finished action
        let commandUtilities : KMCommandUtilities = KMCommandUtilities();
        
        // Call the command
        print("KMEHDownloadController: \(commandUtilities.runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/ehadd", arguments: [item.url, NSBundle.mainBundle().bundlePath + "/Contents/Resources/"], waitUntilExit: false))");
        
        // Create a variable to store the name of the new manga
        var newMangaFileName : String = "";
        
        // Try to get the contents of the newehpath in application support to fiure out what manga we are adding
        newMangaFileName = String(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehpath")!, encoding: NSUTF8StringEncoding)!;
        
        // Create a variable to store the new mangas JSON
        var newMangaJson : JSON!;
        
        // Try to get the contents of the newehdata.json in application support to find the information we need
        newMangaJson = JSON(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehdata.json")!);
        
        // If we want to use the Japanese title...
        if(item.useJapaneseTitle == true) {
            // Set the mangas title to be the mangas Japanese json title
            item.manga.title = newMangaJson["gmetadata"][0]["title_jpn"].stringValue;
        }
        else {
            // Set the mangas title to be the mangas English json title
            item.manga.title = newMangaJson["gmetadata"][0]["title"].stringValue;
        }
        
        // Set the mangas cover image
        item.manga.coverImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Application Support/Komikan/newehcover.jpg"))!;
        
        // Resize the cover image to be compressed for faster loading
        item.manga.coverImage = item.manga.coverImage.resizeToHeight(400);
        
        // Load the tags
        item.manga.tags = (newMangaJson["gmetadata"][0]["tags"].arrayObject as? [String])!;
        
        // Set the release date
        item.manga.releaseDate = NSDate(timeIntervalSince1970: NSTimeInterval(newMangaJson["gmetadata"][0]["posted"].intValue));
        
        // Add a day to the release date(NSDate is odd and is always a day off with these EH downloads)
        item.manga.releaseDate = item.manga.releaseDate.dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24));
        
        // If the item's group isnt blank...
        if(item.group != "") {
            // Set the manga's group to the item's group
            item.manga.group = item.group;
        }
        
        // If the manga's category is not Non-H...
        if(newMangaJson["gmetadata"][0]["category"].stringValue != "Non-H") {
            // Set this manga as l-lewd...
            item.manga.lewd = true;
        }
            // If the manga's category is Non-H...
        else {
            // Set this manga as not l-lewd...
            item.manga.lewd = false;
        }
        
        // Remove all the new lines from newMangaFileName(It adds a new line onto the end for some reason)
        newMangaFileName = newMangaFileName.stringByReplacingOccurrencesOfString("\n", withString: "");
        
        // Set the mangas path
        item.manga.directory = NSHomeDirectory() + "/Library/Application Support/Komikan/EH/" + newMangaFileName + ".cbz";
        
        // Print to the log where the downloaded manga is
        print("KMEHDownloadController: Manga directory: " + item.manga.directory);
        
        // Export the downloaded manga's JSON
        KMFileUtilities().exportMangaJSON(item.manga, exportInternalInfo: false);
        
        // Create the new notification to tell the user the download has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finished downloading \"" + item.manga.title + "\"";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        finishedNotification.identifier = NSUUID().UUIDString;
        
        // Show the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
        
        // Set the send back item to the item we downloaded
        sendBackItem = item;
        
        // Send back the downloaded manga on the main thread
        self.performSelectorOnMainThread(Selector("sendBackToMainThread"), withObject: nil, waitUntilDone: false);
    }
    
    // Adds the specified items manga from ExHentai
    func downloadFromEX(item : KMEHDownloadItem) {
        // A variable we will use so we can set the tasks finished action
        let commandUtilities : KMCommandUtilities = KMCommandUtilities();
        
        // Call the command
        print("KMEHDownloadController: \(commandUtilities.runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/exadd", arguments: [item.url, NSBundle.mainBundle().bundlePath + "/Contents/Resources/"], waitUntilExit: false))");
        
        // Create a variable to store the name of the new manga
        var newMangaFileName : String = "";
        
        // Try to get the contents of the newehpath in application support to fiure out what manga we are adding
        newMangaFileName = String(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehpath")!, encoding: NSUTF8StringEncoding)!;
        
        // Create a variable to store the new mangas JSON
        var newMangaJson : JSON!;
        
        // Try to get the contents of the newehdata.json in application support to find the information we need
        newMangaJson = JSON(data: NSFileManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/newehdata.json")!);
        
        // If we want to use the Japanese title...
        if(item.useJapaneseTitle == true) {
            // Set the mangas title to be the mangas Japanese json title
            item.manga.title = newMangaJson["gmetadata"][0]["title_jpn"].stringValue;
        }
        else {
            // Set the mangas title to be the mangas English json title
            item.manga.title = newMangaJson["gmetadata"][0]["title"].stringValue;
        }
        
        // Set the mangas cover image
        item.manga.coverImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Application Support/Komikan/newehcover.jpg"))!;
        
        // Resize the cover image to be compressed for faster loading
        item.manga.coverImage = item.manga.coverImage.resizeToHeight(400);
        
        // Load the tags and artist/writer
        getTagInfoFromEX(NSHomeDirectory() + "/Library/Application Support/Komikan/newehpage.xml", manga: item.manga);
        
        // Set the release date
        item.manga.releaseDate = NSDate(timeIntervalSince1970: NSTimeInterval(newMangaJson["gmetadata"][0]["posted"].intValue));
        
        // Add a day to the release date(NSDate is odd and is always a day off with these EH downloads)
        item.manga.releaseDate = item.manga.releaseDate.dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24));
        
        // If the item's group isnt blank...
        if(item.group != "") {
            // Set the manga's group to the item's group
            item.manga.group = item.group;
        }
        
        // If the manga's category is not Non-H...
        if(newMangaJson["gmetadata"][0]["category"].stringValue != "Non-H") {
            // Set this manga as l-lewd...
            item.manga.lewd = true;
        }
        // If the manga's category is Non-H...
        else {
            // Set this manga as not l-lewd...
            item.manga.lewd = false;
        }
        
        // Remove all the new lines from newMangaFileName(It adds a new line onto the end for some reason)
        newMangaFileName = newMangaFileName.stringByReplacingOccurrencesOfString("\n", withString: "");
        
        // Set the mangas path
        item.manga.directory = NSHomeDirectory() + "/Library/Application Support/Komikan/EH/" + newMangaFileName + ".cbz";
        
        // Print to the log where the downloaded manga is
        print("KMEHDownloadController: Manga directory: " + item.manga.directory);
        
        // Export the downloaded manga's JSON
        KMFileUtilities().exportMangaJSON(item.manga, exportInternalInfo: false);
        
        // Create the new notification to tell the user the download has finished
        let finishedNotification = NSUserNotification();
        
        // Set the title
        finishedNotification.title = "Komikan";
        
        // Set the informative text
        finishedNotification.informativeText = "Finished downloading \"" + item.manga.title + "\"";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        finishedNotification.identifier = NSUUID().UUIDString;
        
        // Show the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(finishedNotification);
        
        // Set the send back item to the item we downloaded
        sendBackItem = item;
        
        // Send back the downloaded manga on the main thread
        self.performSelectorOnMainThread(Selector("sendBackToMainThread"), withObject: nil, waitUntilDone: false);
    }
    
    /// Gets the tag info from ExHentai and sets the values accordingly on the passed manga(Like respecting artist namespace)
    func getTagInfoFromEX(galleryPagePath : String, manga : KMManga) {
        /// The contents of the file at galleryPagePath, will escaoe ampersands
        var pageData : String = String(data: NSFileManager.defaultManager().contentsAtPath(galleryPagePath)!, encoding: NSUTF8StringEncoding)!;
        
        // Escape the ampersands
        pageData = pageData.stringByReplacingOccurrencesOfString("&", withString: "(&amp;)");
        
        /// The XML for the manga's EH gallery page's source code
        let galleryPageXML = SWXMLHash.parse(pageData.dataUsingEncoding(NSUTF8StringEncoding)!);
        
        // Get the tags and tag namespace
        do {
            // For every element in the tag list on the gallery page...
            for (_, currentElement) in try galleryPageXML["html"]["body"]["div"].withAttr("class", "gm")["div"].withAttr("id", "gmid")["div"].withAttr("id", "gd4")["div"].withAttr("id", "taglist")["table"].children.enumerate() {
                // The current tag namespace
                var tagNamespace : String = try currentElement["td"].withAttr("class", "tc").element!.text!;
                
                // Remove the : on the end that EH puts
                tagNamespace = tagNamespace.substringToIndex(tagNamespace.endIndex.predecessor());
                
                /// All the tags for this gallery under the current namespace
                var tagsInNamespace : [String] = [];
                
                // For every tag in the current namespace...
                for(_, currentTag) in currentElement["td"].children.enumerate() {
                    /// The current tag
                    var currentTagValue : String = currentTag.element!.attributes.first!.1;
                    
                    /// Remove the td_ and : that EH adds
                    currentTagValue = currentTagValue.stringByReplacingOccurrencesOfString("td_" + tagNamespace + ":", withString: "");
                    currentTagValue = currentTagValue.stringByReplacingOccurrencesOfString("td_", withString: "");
                    
                    // Replace underscores with spaces
                    currentTagValue = currentTagValue.stringByReplacingOccurrencesOfString("_", withString: " ");
                    
                    // Add the current tag to the tags namespace
                    tagsInNamespace.append(currentTagValue);
                }
                
                // If this is the artist namespace...
                if(tagNamespace == "artist") {
                    // Set the manga's artist and author to the artist tag(Capitalized and with spaces instead of underscores)
                    manga.artist = tagsInNamespace[0].capitalizedString.stringByReplacingOccurrencesOfString("_", withString: " ");
                    manga.writer = tagsInNamespace[0].capitalizedString.stringByReplacingOccurrencesOfString("_", withString: " ");
                }
                // If this is the parody namespace...
                else if(tagNamespace == "parody") {
                    // Set the manga's series to the parody tag(Capitalized, with spaces instead of underscores, and with "Parody:" on the front)
                    manga.series = "Parody: " + tagsInNamespace[0].capitalizedString.stringByReplacingOccurrencesOfString("_", withString: " ");
                }
                // If its anything else...
                else {
                    // Add the tags to the manga's tags
                    manga.tags.appendContentsOf(tagsInNamespace);
                }
            }
        }
        catch _ as NSError {
            
        }
    }
}