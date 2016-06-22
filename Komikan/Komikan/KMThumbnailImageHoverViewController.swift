//
//  KMThumbnailHoverViewController.swift
//  Komikan
//
//  Created by Seth on 2016-03-12.
//

import Cocoa

class KMThumbnailImageHoverViewController: NSViewController {

    /// The image view for the thumbnail picture
    @IBOutlet var thumbnailImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Sets the thumbnail image view's image to the given image
    func setImage(image : NSImage) {
        // Set thumbnailImageView's image to the passed image
        thumbnailImageView.image = image;
    }
}
