//
//  KMImageFilterUtilities.swift
//  Komikan
//
//  Created by Seth on 2016-01-29.
//

import Foundation
import AppKit

class KMImageFilterUtilities {
    func applyColorAndSharpness(_ image : NSImage, saturation : CGFloat, brightness : CGFloat, contrast : CGFloat, sharpness : CGFloat) -> NSImage {
        // Store the original image
        var originalImage = image;
        
        // Create a variable for the input image as a CIImage
        var inputImage = CIImage(data: (originalImage.tiffRepresentation)!);
        
        // Create the filter for the color controls
        var filter = CIFilter(name: "CIColorControls");
        
        // Load the defaults for the filter
        filter!.setDefaults();
        
        // Set the filters image to the input image
        filter!.setValue(inputImage, forKey: kCIInputImageKey);
        
        // Set the saturation
        filter!.setValue(saturation, forKey: "inputSaturation");
        
        // Set the brightness
        filter!.setValue(brightness, forKey: "inputBrightness");
        
        // Set the contrast
        filter!.setValue(contrast, forKey: "inputContrast");
        
        // Create the output image as a CIImage
        var outputImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage;
        
        // Create the rect for the output image as its full size
        var outputImageRect = NSRectFromCGRect(outputImage.extent);
        
        // Create the color controlled image, with the full size
        let colorControlledImage = NSImage(size: outputImageRect.size);
        
        // Lock focus on the image
        colorControlledImage.lockFocus();
        
        // Draw the image onto the NSImage
        outputImage.draw(at: NSZeroPoint, from: outputImageRect, operation: .copy, fraction: 1.0);
        
        // Unlock the images focus
        colorControlledImage.unlockFocus();
        
        // Set originalImage to the color controlled image
        originalImage = colorControlledImage;
        
        // Set inputImage to the color controlled image as a CIImage
        inputImage = CIImage(data: (originalImage.tiffRepresentation)!);
        
        // Set filter to the sharpen filter
        filter = CIFilter(name: "CISharpenLuminance");
        
        // Load the filter defaults
        filter!.setDefaults();
        
        // Set the filters image to be the input image
        filter!.setValue(inputImage, forKey: kCIInputImageKey);
        
        // Set its sharpness
        filter!.setValue(sharpness, forKey: "inputSharpness");
        
        // Set outputImage to the filters image as a CGImage
        outputImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage;
        
        // Set outputImageRect to the now sharpened images full size
        outputImageRect = NSRectFromCGRect(outputImage.extent);
        
        // Create sharpenedImage, and set it to have the size of the output image
        let sharpenedImage = NSImage(size: outputImageRect.size);
        
        // Lock focus on the image
        sharpenedImage.lockFocus();
        
        // Draw the output image onto sharpenedImage
        outputImage.draw(at: NSZeroPoint, from: outputImageRect, operation: .copy, fraction: 1.0);
        
        // Unlock the focus
        sharpenedImage.unlockFocus();
        
        // Return the now color controlled and sharpened image
        return sharpenedImage;
    }
    
    func applyColorAndSharpnessMultiple(_ images : [NSImage], saturation : CGFloat, brightness : CGFloat, contrast : CGFloat, sharpness : CGFloat) -> [NSImage] {
        // Create the variable that will hold all the filtered images
        var filteredImages : [NSImage] = [NSImage()];
        
        // For every image in the passed images...
        for(_, currentImage) in images.enumerated() {
            // Create the variable for storing this images filtered version, and set it to the current image filtered with the passed amounts
            let filteredImage : NSImage = applyColorAndSharpness(currentImage, saturation: saturation, brightness: brightness, contrast: contrast, sharpness: sharpness);
            
            // Append the new filtered image onto filteredImages
            filteredImages.append(filteredImage);
        }
        
        // Remove the first element from the filteredImages array, its always blank
        filteredImages.removeFirst();
        
        // Return the fitered images
        return filteredImages;
    }
}
