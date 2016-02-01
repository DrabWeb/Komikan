//
//  KMSidebarSplitView.swift
//  Komikan
//
//  Created by Seth on 2016-01-31.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMSidebarSplitView: NSSplitView {
    
    // Override the dividers thickness so it is 0 and doesnt show
    override var dividerThickness : CGFloat { get { return 0 } }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
