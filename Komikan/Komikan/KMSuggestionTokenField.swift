//
//  KMSuggestionTextField.swift
//  Komikan
//
//  Created by Seth on 2016-03-13.
//

import Cocoa

class KMSuggestionTokenField: NSTokenField, NSTokenFieldDelegate {
    
    /// All the suggestions for the user when typing
    var suggestions : [String] = [];
    
    /// Are the suggestions case insensitive?
    var caseInsensitive : Bool = true;
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<UnsafeMutablePointer<Int>>?) -> [Any]? {
        
        /// All the suggestions we will show
        var matchingSuggestions : [String] = [];
        
        // For every item in this token field's suggestions...
        for(_, currentPossibleSuggestion) in suggestions.enumerated() {
            // If the suggestions are case sensitive...
            if(!caseInsensitive) {
                // If the range of the currently entered string starts at the beginning of the string...
                if(currentPossibleSuggestion.range(of: substring)?.lowerBound == currentPossibleSuggestion.startIndex) {
                    // Add the current suggestion to the suggestions to display
                    matchingSuggestions.append(currentPossibleSuggestion);
                }
            }
            // If the suggestions are case insensitive...
            else {
                // If the range of the currently entered string starts at the beginning of the string...
                if(currentPossibleSuggestion.lowercased().range(of: substring.lowercased())?.lowerBound == currentPossibleSuggestion.startIndex) {
                    // Add the current suggestion to the suggestions to display
                    matchingSuggestions.append(currentPossibleSuggestion);
                }
            }
        }
        
        // Return the matching suggestions
        return matchingSuggestions;
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.delegate = self;
    }
}
