//
//  KMMALLoginViewController.swift
//  Komikan
//
//  Created by Seth on 2016-03-09.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMALLoginViewController: NSViewController {
    
    /// The login window
    var loginWindow : NSWindow = NSWindow();

    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The image view that shows the MAL logo
    @IBOutlet var malLogoImageView: NSImageView!
    
    /// The text field for entering your username
    @IBOutlet var usernameTextField: KMAlwaysActiveTextField!
    
    /// The text field for entering your password
    @IBOutlet var passwordTextField: KMAlwaysActiveSecureTextField!
    
    /// When we press the "Login" button...
    @IBAction func loginButtonPressed(sender: AnyObject) {
        // Verify the credentials entered
        (NSApplication.sharedApplication().delegate as! AppDelegate).malController.verifyCredentials(usernameTextField.stringValue, password: passwordTextField.stringValue, completionHandler: loginCompletionHandler);
    }
    
    /// Called when the login verify request is sent
    func loginCompletionHandler(correct : Bool?, error : NSError?) {
        // If the credentials were correct...
        if(correct!) {
            // Close the window
            loginWindow.close();
        }
        // If the credentials were incorrect...
        else {
            // Shake the window to let the user know it was incorrect
            shakeWindow(4, duration: 0.5);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Shakes the window the given amount of times for the given duration
    func shakeWindow(times : Int, duration : Float) {
        // I did not write this, all credits to http://stackoverflow.com/a/31755773
        
        /// The amount of times the window will shake
        let numberOfShakes : Int = times;
        
        // How many seconds the window will shake
        let durationOfShake : Float = duration;
        
        /// How vigorous the shakes should be
        let vigourOfShake : Float = 0.05;
        
        /// The original frame of the window
        let frame : CGRect = (self.view.window?.frame)!;
        
        /// The animation for the shake of the window
        let shakeAnimation = CAKeyframeAnimation();
        
        /// The path for the window shake
        let shakePath = CGPathCreateMutable();
        
        /// Set the original point of the shake path to the window's origin
        CGPathMoveToPoint(shakePath, nil, NSMinX(frame), NSMinY(frame));
        
        // From 1 to the number of shakes...
        for _ in 1...numberOfShakes {
            // Add a point so it shakes to the left
            CGPathAddLineToPoint(shakePath, nil, NSMinX(frame) - frame.size.width * CGFloat(vigourOfShake), NSMinY(frame));
            
            // Add a point so it shakes to the right
            CGPathAddLineToPoint(shakePath, nil, NSMinX(frame) + frame.size.width * CGFloat(vigourOfShake), NSMinY(frame));
        }
        
        // Close off the shake path
        CGPathCloseSubpath(shakePath);
        
        // SAet the animations path to the shake path
        shakeAnimation.path = shakePath;
        
        // Set the shake animation duration to the given duration
        shakeAnimation.duration = CFTimeInterval(durationOfShake);
        
        // Add the animation to the window
        self.view.window?.animations = ["frameOrigin":shakeAnimation];
        
        // Move the window back to it's original position
        self.view.window?.animator().setFrameOrigin(self.view.window!.frame.origin);
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        loginWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the background of the titlebar
        loginWindow.titlebarAppearsTransparent = true;
        
        // Hide the title
        loginWindow.titleVisibility = .Hidden;
        
        // Set the content view to be full size
        loginWindow.styleMask |= NSFullSizeContentViewWindowMask;
        
        // Hide the minimize and zoom buttons
        loginWindow.standardWindowButton(.MiniaturizeButton)?.hidden = true;
        loginWindow.standardWindowButton(.ZoomButton)?.hidden = true;
        
        // Set the background of the window to be a more vibrant black
        backgroundVisualEffectView.material = .Dark;
        
        // Set the MAL logo to be vibrant
        malLogoImageView.image?.template = true;
    }
}
