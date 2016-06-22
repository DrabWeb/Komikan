//
//  KMNotificationUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-03-19.
//

import Cocoa

class KMNotificationUtilities {
    /// Sends a notification with the given title and message
    func sendNotification(title : String, message : String) {
        // Create the new notification
        let notification = NSUserNotification();
        
        // Set the title
        notification.title = title;
        
        // Set the informative text
        notification.informativeText = message;
        
        // Set the notifications identifier to be an obscure string, so we can show multiple at once
        notification.identifier = NSUUID().UUIDString;
        
        // Deliver the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification);
    }
}
