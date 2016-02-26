//
//  KMEHDownloadController.swift
//  Komikan
//
//  Created by Seth on 2016-01-28.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Foundation

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
        // Prin to the log what item was added to the queue
        print("Added \"" + item.url + "\" to queue");
        
        // Create the new notification to tell the user the download has been queued
        let queuedNotification = NSUserNotification();
        
        // Set the title
        queuedNotification.title = "Komikan";
        
        // Set the informative text
        queuedNotification.informativeText = "Added \"" + item.url + "\" to the download queue";
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        queuedNotification.identifier = NSUUID().UUIDString;
        
        // Deliver the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(queuedNotification);
        
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
    
    // This function manages downloading the queue items, and is meant to be spawn in a new thread
    func downloadThread() {
        // Say we are currently downloading the queue items
        currentlyDownloading = true;
        
        // For every item in the download queue...
        for(currentIndex, currentItem) in downloadQueue.enumerate() {
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
            
            // Remove this item from the queue
            downloadQueue.removeAtIndex(currentIndex);
        }
        
        // Say we are no longer downloading the queue items
        currentlyDownloading = false;
        
        // If there are more to download...
        if(queueHasMore) {
            // Set it to false
            queueHasMore = false;
            
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
        print(commandUtilities.runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/ehadd", arguments: [item.url, NSBundle.mainBundle().bundlePath + "/Contents/Resources/"], waitUntilExit: false));
        
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
        
        // Set the mangas tags
        item.manga.tags = (newMangaJson["gmetadata"][0]["tags"].arrayObject as? [String])!;
        
        // If the tags dont contains non-h...
        if(!item.manga.tags.contains("non-h")) {
            // Set this manga as l-lewd...
            item.manga.lewd = true;
        }
        // If the tags do contain non-h...
        else {
            // Set this manga as not l-lewd...
            item.manga.lewd = false;
        }
        
        // Remove all the new lines from newMangaFileName(It adds a new line onto the end for some reason)
        newMangaFileName = newMangaFileName.stringByReplacingOccurrencesOfString("\n", withString: "");
        
        // Set the mangas path
        item.manga.directory = NSHomeDirectory() + "/Library/Application Support/Komikan/EH/" + newMangaFileName + ".cbz";
        
        // Print to the log where the downloaded manga is
        print("Manga Directory: " + item.manga.directory);
        
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
        print(commandUtilities.runCommand(NSBundle.mainBundle().bundlePath + "/Contents/Resources/exadd", arguments: [item.url, NSBundle.mainBundle().bundlePath + "/Contents/Resources/"], waitUntilExit: false));
        
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
        item.manga.coverImage = NSImage(contentsOfURL: NSURL(string: newMangaJson["gmetadata"][0]["thumb"].stringValue)!)!;
        
        // Resize the cover image to be compressed for faster loading
        item.manga.coverImage = item.manga.coverImage.resizeToHeight(400);
        
        // Set the mangas tags
        item.manga.tags = (newMangaJson["gmetadata"][0]["tags"].arrayObject as? [String])!;
        
        // If the tags dont contains non-h...
        if(!item.manga.tags.contains("non-h")) {
            // Set this manga as l-lewd...
            item.manga.lewd = true;
        }
            // If the tags do contain non-h...
        else {
            // Set this manga as not l-lewd...
            item.manga.lewd = false;
        }
        
        // Remove all the new lines from newMangaFileName(It adds a new line onto the end for some reason)
        newMangaFileName = newMangaFileName.stringByReplacingOccurrencesOfString("\n", withString: "");
        
        // Set the mangas path
        item.manga.directory = NSHomeDirectory() + "/Library/Application Support/Komikan/EH/" + newMangaFileName + ".cbz";
        
        // Print to the log where the downloaded manga is
        print("Manga Directory: " + item.manga.directory);
        
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
}