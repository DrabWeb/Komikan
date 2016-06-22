//
//  KMImageUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-02-03.
//

import Foundation

extension NSImage {
    /// Resizes the image to the width and height specified
    func resizeImage(width: CGFloat, _ height: CGFloat) -> NSImage {
        // Thanks to http://stackoverflow.com/questions/11949250/how-to-resize-nsimage/30422317#30422317 for the solution
        
        // Create a variable to store the resized image, with the size we specified above
        let resizedImage = NSImage(size: CGSizeMake(width, height));
        
        // Lock draing focus on the image
        resizedImage.lockFocus();
        
        // Set the current graphics contexts image interpolation to high for maximum quality
        NSGraphicsContext.currentContext()!.imageInterpolation = NSImageInterpolation.High;
        
        // Draw this image into the size that we want
        self.drawInRect(NSMakeRect(0, 0, width, height), fromRect: NSMakeRect(0, 0, size.width, size.height), operation: .CompositeCopy, fraction: 1);
        
        // Unlock drawing focus
        resizedImage.unlockFocus();
        
        // Return the resized image
        return resizedImage;
    }
    
    /// Resizes the image by multiplying its size by the factor. Factor should be above zero, or you will get nothing.
    func resizeByFactor(factor : CGFloat) -> NSImage {
        // Get the width the we will resize it to
        let width : CGFloat = self.size.width * factor;
        
        // Get the height that we will resize it to
        let height : CGFloat = self.size.height * factor;
        
        // Resize the image to the width and height we got
        let resizedImage : NSImage = self.resizeImage(width, height);
        
        // Return the resized image
        return resizedImage;
    }
    
    /// Resizes the image to the specified height while maintaining the aspect ratio
    func resizeToHeight(height : CGFloat) -> NSImage {
        // Calculate the aspect ratio of this image(width/height)
        let aspectRatio = self.size.width / self.size.height;
        
        // Get the width(aspect ratio * desired height)
        let width = aspectRatio * height;
        
        // Get the resized image by using the resizeImage function with the passed height and the calcuated width
        let resizedImage = self.resizeImage(width, height);
        
        // Return the resized image
        return resizedImage;
    }
}
