//
//  KMAlwaysActiveTextField.swift
//  Komikan
//
//  Created by Seth on 2016-02-26.
//

import Cocoa

class KMAlwaysActiveTextField: NSTextField {
    
    // Always say we can be first responder so we always get the active look
    override var acceptsFirstResponder : Bool {
        return true;
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

class KMAlwaysActiveSecureTextField: NSSecureTextField {
    
    // Always say we can be first responder so we always get the active look
    override var acceptsFirstResponder : Bool {
        return true;
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
}
