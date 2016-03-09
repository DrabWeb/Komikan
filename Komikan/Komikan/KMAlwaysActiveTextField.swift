//
//  KMAlwaysActiveTextField.swift
//  Komikan
//
//  Created by Seth on 2016-02-26.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMAlwaysActiveTextField: NSTextField {
    
    // Always say we can be first responder so we always get the active look
    override var acceptsFirstResponder : Bool {
        return true;
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}

class KMAlwaysActiveSecureTextField: NSSecureTextField {
    
    // Always say we can be first responder so we always get the active look
    override var acceptsFirstResponder : Bool {
        return true;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
}
