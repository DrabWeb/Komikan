//
//  KMEHLoginViewController.swift
//  Komikan
//
//  Created by Seth on 2016-02-13.
//

import Cocoa
import WebKit

class KMEHLoginViewController: NSViewController, WebFrameLoadDelegate {
    
    /// The main window of the login view controller
    var loginWindow : NSWindow!;

    /// The web view that is used to login to E-Hentai
    @IBOutlet weak var webView: WebView!
    
    /// The label in the titlebar to show the URL
    @IBOutlet weak var urlLabel: NSTextField!
    
    /// Have we already opened ExHentai?
    var openedExhentai : Bool =  false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Load the web view
        loadWebView();
        
        // Set the WebView's frame load delegate
        webView.frameLoadDelegate = self;
        
        /// The webviews cookie storage
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
        
        // For every cookie in the cookie storage...
        for(_, currentCookie) in (storage.cookies?.enumerate())! {
            // Delete the cookie
            storage.deleteCookie(currentCookie);
        }
        
        // Reload the user defaults
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
        // Update the webview
        updateWebView();
    }
    
    /// Updates the window title to match the webviews URL, if we are on exhentai it stores the cookies and closes the webview, and if we are on sadpanda it opens the guide to get past it
    func updateWebView() {
        // Set the URL labels string value to the current URL in the webview
        urlLabel.stringValue = webView.mainFrameURL;
        
        // If the cookies contains a "ipb_member_id" and we arent already on ExHentai...
        if(webView.stringByEvaluatingJavaScriptFromString("document.cookie").containsString("ipb_member_id") && !openedExhentai) {
            /// The URL request to open ExHentai
            let exLoadRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: "http://exhentai.org")!);
            
            // Load the EX request
            webView.mainFrame.loadRequest(exLoadRequest);
            
            // Say we have already opened ExHentai
            openedExhentai = true;
        }
        
        // If we have opened ExHentai and the URL is not just http://exhentai.org...
        if(openedExhentai && !(webView.mainFrameURL == "http://exhentai.org")) {
            // Write the cookies into the Application Supports excookies file
            do {
                // Try to write the cookies
                try webView.stringByEvaluatingJavaScriptFromString("document.cookie").writeToFile(NSHomeDirectory() + "/Library/Application Support/Komikan/excookies", atomically: true, encoding: NSUTF8StringEncoding);
            }
                // If there is an error...
            catch _ as NSError {
                // Do nothing
            }
            
            // Close the window
            loginWindow.close();
        }
        // If we are just on http://exhentai.org (Meaning the user is on a sad panda...)
        else if(webView.mainFrameURL == "http://exhentai.org") {
            // Close the window
            loginWindow.close();
            
            // Open https://a.pomf.cat/lkyaft.png . It is a small flow graph posted on /h/ that tells users how to get past sad panda(Though they really shouldnt need this, im just being kind)
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://a.pomf.cat/lkyaft.png")!);
        }
    }
    
    /// Loads the web view
    func loadWebView() {
        /// The URL request to open E-Hentai
        let ehLoadRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: "http://g.e-hentai.org/home.php")!);
        
        // Load the EH request
        webView.mainFrame.loadRequest(ehLoadRequest);
        
        // Do the initial webview update
        updateWebView();
    }
    
    /// Styles the window
    func styleWindow() {
        // Set the window to the last application window
        loginWindow = NSApplication.sharedApplication().windows.last!;
        
        // Set the window to have a full size content view
        loginWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the titlebar
        loginWindow.titlebarAppearsTransparent = true;
        
        // Hide the title of the window
        loginWindow.titleVisibility = NSWindowTitleVisibility.Hidden;
        
        // Center the window
        loginWindow.setFrame(NSRect(x: (NSScreen.mainScreen()!.frame.width / 2) - (480 / 2), y: (NSScreen.mainScreen()!.frame.height / 2) - (500 / 2), width: 480, height: 500), display: false);
    }
}
