//
//  KMMALUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-03-09.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa
import Alamofire
import CryptoSwift
import SWXMLHash

/// A collection of MyAnimeList utilities meant to make life easier
class KMMALUtilities {
    /// The encryption key for the login info file, UUID. Yes, I know this is the same key for everyone. Compile it with your own key if you want tight security. Im NOT responsible if your login info gets stolen.
    /// Though who would want a MAL login anyway? The most they could do is clear your list, but whats the point in that?
    let loginEncryptionKey : String = "e44b328f-e567-421c-b06e-5cabda06";
    
    /// The IV for the encryption of the login info file.
    var loginEncryptionIv : String = "d4d25683-2efa-4c";
    
    /// The user's MAL username
    var loginUsername : String = "";
    
    /// The user's MAL password
    var loginPassword : String = "";
    
    /// The URL for verifying credentials
    let MAL_CREDENTIALS_PAGE : String = "http://myanimelist.net/api/account/verify_credentials.xml";
    
    let MAL_LIST_PAGE_BASE : String = "http://myanimelist.net/mangalist/";
    
    /// Returns all the items in the given list
    func getList(list : KMMALListType) {
        print("Getting the " + String(list) + " list");
        
        /// The URL of the list we want
        var listURL : NSURL = NSURL(string: MAL_LIST_PAGE_BASE + loginUsername + "?status=")!;
        
        // If the list we want is the Currently Reading list...
        if(list == .CurrentlyReading) {
            // Set the list status number to 1
            listURL = NSURL(string: listURL.absoluteString + "1")!;
        }
        
        /// The NSData of the list URL
        let listData : NSData? = NSData(contentsOfURL: listURL);
        
        // If the list data isnt nil...
        if(listData != nil) {
            /// The XML of the list's web page
            let listXML = SWXMLHash.parse(listData!);
        }
    }
    
    /// Verifys credentials. Returns false if they are wrong and true if they are right. Also saves the credentials in the login file(Encrypted) if correct
    func verifyCredentials(username : String, password : String, completionHandler: (Bool?, NSError?) -> ()) -> Bool {
        /// Were the credentials correct?
        let credentialsCorrect : Bool = false;
        
        // Print to the log that we are verifying credentials
        print("Verifying credentials for \"" + username + "\"");
        
        /// The credentials we will use for authentication to MAL and store in the Key Chain
        let credential = NSURLCredential(user: username, password: password, persistence: .ForSession);
        
        // Make the verify request
        Alamofire.request(.GET, MAL_CREDENTIALS_PAGE)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                // If the credentials were correct...
                if(response.response?.statusCode == 200) {
                    /// The NSData for the login info(Line one is your username and line two is your password)
                    let loginData : NSData = (credential.user! + "\n" + credential.password!).dataUsingEncoding(NSUTF8StringEncoding)!;
                    
                    /// loginData encrypted with the encryption keys
                    let encryptedLoginData = try! loginData.encrypt(AES(key: self.loginEncryptionKey, iv: self.loginEncryptionIv));
                    
                    // Write the encrypted data to ~/Library/Application Support/Komikan/mal-login
                    encryptedLoginData.writeToFile(NSHomeDirectory() + "/Library/Application Support/Komikan/mal-login", atomically: true);
                }
                
                // Return if the credentials were correct
                completionHandler(response.response?.statusCode == 200, nil);
        }
        
        // Return if the credentials were correct
        return credentialsCorrect;
    }
    
    /// Updates the Komikan/Login to MyAnimeList menu item
    func updateMenuItem() {
        // If the username isnt blank...
        if(loginUsername != "") {
            // Set the login menu item to say we are logged in, and as who
            (NSApplication.sharedApplication().delegate as! AppDelegate).loginToMalMenuItem.title = "Login to MyAnimeList (Logged in as " + loginUsername + ")";
        }
            // If the username is blank...
        else if(loginUsername == "") {
            // Set the login menu item to say we arent logged in
            (NSApplication.sharedApplication().delegate as! AppDelegate).loginToMalMenuItem.title = "Login to MyAnimeList (Not logged in)";
        }
    }
    
    // Init
    init() {
        // If the credentials have been stored...
        if(NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/mal-login")) {
            /// The login information for MAL, encrypted
            let encryptedLoginData : NSData = NSFileManager.defaultManager().contentsAtPath(NSHomeDirectory() + "/Library/Application Support/Komikan/mal-login")!;
            
            // Decrypt the login info
            let loginData : NSData = try! encryptedLoginData.decrypt(AES(key: self.loginEncryptionKey, iv: self.loginEncryptionIv));
            
            /// The login data, decrypted, and put into a string
            let decryptedLoginString : String = String(data: loginData, encoding: NSUTF8StringEncoding)!;
            
            // For every line in the decrypted login string...
            for(currentLineIndex, currentLine) in decryptedLoginString.componentsSeparatedByString("\n").enumerate() {
                // If this is the first line...
                if(currentLineIndex == 0) {
                    // Set the username to this line
                    loginUsername = currentLine;
                }
                // If this is the second line...
                else if(currentLineIndex == 1) {
                    // Set the password to this line
                    loginPassword = currentLine;
                }
            }
        }
    }
}
