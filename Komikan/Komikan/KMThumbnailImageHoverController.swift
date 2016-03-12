//
//  KMThumbnailImageHover.swift
//  Komikan
//
//  Created by Seth on 2016-03-12.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMThumbnailImageHoverController : NSObject {
    /// The window controller for the thumbnail hover window
    var thumbnailWindowController : NSWindowController = NSWindowController();
    
    /// The view controller for thumbnailWindowController
    var thumbnailViewController : KMThumbnailImageHoverViewController = KMThumbnailImageHoverViewController();
    
    /// Shows the thumbnail window at the given point(The bottom left matches up to the given point), with the given height(Maintains aspect ratio)
    func showAtPoint(thumbnail : NSImage, point : NSPoint, height : Float) {
        // Set the thumbnail image view's image to the passed thumbnail
        thumbnailViewController.setImage(thumbnail);
        
        // Get the aspect ratio of the image
        let aspectRatio = pixelSizeOfImage(thumbnail).width / pixelSizeOfImage(thumbnail).height;
        
        // Figure out what the width would be if we kept the aspect ratio and set the height to the given height
        let width = Float(aspectRatio) * height;
        
        // Set the size of the thumbnail window to the given height while maintaining aspect ratio
        self.thumbnailWindowController.window?.setFrame(NSRect(x: 0, y: 0, width: Int(width), height: Int(height)), display: false);
        
        // Move the thumbnail window to the given point
        thumbnailWindowController.window?.setFrameOrigin(point);
        
        // Show the thumbnail window
        thumbnailWindowController.window?.orderFront(self);
    }
    
    /// Hides the thumbnail window
    func hide() {
        // Hide the window
        self.thumbnailWindowController.window?.orderOut(self);
    }
    
    /// Returns the pixel size of the passed NSImage
    func pixelSizeOfImage(image : NSImage) -> NSSize {
        /// The NSBitmapImageRep to the image
        let imageRep : NSBitmapImageRep = (NSBitmapImageRep(data: image.TIFFRepresentation!))!;
        
        /// The size of the iamge
        let imageSize : NSSize = NSSize(width: imageRep.pixelsWide, height: imageRep.pixelsHigh);
        
        // Return the image size
        return imageSize;
    }
    
    /// Init/Styling the window
    func styleWindow() {
        // Get the thumbnail window controller
        thumbnailWindowController = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("thumbnailHoverWindowController") as! NSWindowController;
        
        // Set thumbnailViewController
        thumbnailViewController = (thumbnailWindowController.contentViewController as! KMThumbnailImageHoverViewController);
        
        // Load the thumbnail window
        thumbnailWindowController.loadWindow();
        
        // Set the window to be borderless rounded
        thumbnailWindowController.window?.styleMask |= NSFullSizeContentViewWindowMask;
        thumbnailWindowController.window?.standardWindowButton(.CloseButton)?.superview?.superview?.removeFromSuperview();
        
        // Make the background of the window transparent
        thumbnailWindowController.window?.opaque = false;
        thumbnailWindowController.window?.backgroundColor = NSColor.clearColor();
        
        // Dont allow any mouse events on the window
        thumbnailWindowController.window?.ignoresMouseEvents = true;
        
        // Set the thumbnail window to be a higher level than the others
        self.thumbnailWindowController.window?.level++;
    }
}

class KMThumbnailHoverWindow : NSWindow {
    // Dont allow the window to become key
    override var canBecomeKeyWindow : Bool { return false }
}