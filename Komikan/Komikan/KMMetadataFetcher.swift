//
//  KMMetadataFetcher.swift
//  Komikan
//
//  Created by Seth on 2016-02-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa
import Alamofire

/// A utility class for fetching metadata from MCD(http://mcd.iosphe.re/)
/// Example usage
//			// Call the search function with the name of a manga(Eg. Nichijou), with a function to be called when finished that takes [KMMetadataInfo]? and NSError?
//			KMMetadataFetcher().searchForManga("Nichijou", completionHandler: searchCompletionHandler);
//		
//			// This will get called when the search is completed
//			func searchCompletionHandler(searchResults : [KMMetadataInfo]?, error : NSError?) {
//			    // For every item in the results of the search...
//			    for(_, currentItem) in searchResults!.enumerate() {
//			        // Print this item's title and Manga Updates id
//			        print("\"" + currentItem.title + "\", id", currentItem.id);
//			    }
//			    
//			    // Call the get series metadata function with the first item from the search results, with a function to be called when finished that //takes a KMSeriesMetadata? and NSError?
//			    KMMetadataFetcher().getSeriesMetadata(searchResults![0], completionHandler: seriesMetadataCompletionHandler);
//			}
//		
//			// This will get called when the metadata fetching is completed
//			func seriesMetadataCompletionHandler(metadata : KMSeriesMetadata?, error : NSError?) {
//			    // Print all the info to the log
//			    print(metadata?.title);
//			    print(metadata?.alternateTitles);
//			    print(metadata?.artists);
//			    print(metadata?.writers);
//			    print(metadata?.coverURLs);
//			    print(metadata?.tags);
//			    print(metadata?.volumes);
//			}

class KMMetadataFetcher {
    /// Searches for a manga with the given title
    ///
    /// Syntax for usage is
    /// KMMetadataFetcher().searchForManga(title, completionHandler: completionHandler);
    ///
    /// and the syntax for the completionHandler is
    /// func completionHandler(searchJSON : [KMMetadataInfo]?, error : NSError?))
    func searchForManga(title : String, completionHandler: ([KMMetadataInfo]?, NSError?) -> ()) -> [KMMetadataInfo] {
        // Return the output of the searchForMangaRequest with the given values
        return searchForMangaRequest(title, completionHandler: completionHandler);
    }
    
    /// Makes the actual search request from searchForManga
    private func searchForMangaRequest(title : String, completionHandler: ([KMMetadataInfo]?, NSError?) -> ()) -> [KMMetadataInfo] {
        // Print to the log what we are searching for
        print("Searching for \"" + title + "\"");
        
        /// The list of KMMetadataInfo that we will return to say what items came up in the search
        var metadataSearchItems : [KMMetadataInfo] = [];
        
        /// The SwiftyJSON object which holds the JSON result of the search
        var searchJSON : JSON = JSON(data: NSData());
        
        // Make the JSON post request to MCD with the title we want to search for...
        Alamofire.request(.POST, "http://mcd.iosphe.re/api/v1/search/", parameters: ["Title": title], encoding: .JSON).responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the search completes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: NSUTF8StringEncoding)!;
            
            // If the response data and the response string converted to NSData are equal...
            if let dataFromResponseJsonString = responseJsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                // Set searchJSON to the JSON object from the response data
                searchJSON = JSON(data: dataFromResponseJsonString);
                
                // For every item in the response JSON...
                for(_, currentItem) in searchJSON["Results"].arrayValue.enumerate() {
                    // Add the current item to the metadata search items
                    metadataSearchItems.append(KMMetadataInfo(title: currentItem[1].stringValue, id: currentItem[0].intValue));
                }
                
                // Return the search items
                completionHandler(metadataSearchItems, nil);
            }
        };
        
        // Return the search items
        return metadataSearchItems;
    }
    
    /// Gets the metadata from a KMMetadataInfo and returns it as a KMSeriesMetadata
    /// Usage is the same as searchForManga,so look there for syntax
    func getSeriesMetadata(metadata : KMMetadataInfo, completionHandler: (KMSeriesMetadata?, NSError?) -> ()) -> KMSeriesMetadata {
        // Return the output of the getSeriesMetadataRequest with the given values
        return getSeriesMetadataRequest(metadata, completionHandler: completionHandler);
    }
    
    /// Makes the actual search request from searchForManga
    private func getSeriesMetadataRequest(metadata : KMMetadataInfo, completionHandler: (KMSeriesMetadata?, NSError?) -> ()) -> KMSeriesMetadata {
        // Print to the log what we are searching for
        print("Getting metadata for \"" + metadata.title + "\"");
        
        /// The KMSeriesMetadata we will receive from MCD and return at the end
        var seriesMetadata : KMSeriesMetadata = KMSeriesMetadata();
        
        /// The SwiftyJSON object which holds the JSON result of the GET request
        var responseJSON : JSON = JSON(data: NSData());
        
        // Make the get request to MCD with the series ID...
        Alamofire.request(.GET, "http://mcd.iosphe.re/api/v1/series/" + String(metadata.id) + "/", encoding: .JSON).responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: NSUTF8StringEncoding)!;
            
            // If the response data and the response string converted to NSData are equal...
            if let dataFromResponseJsonString = responseJsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                // Set responseJSON to the JSON object from the response data
                responseJSON = JSON(data: dataFromResponseJsonString);
                
                // Get the title
                seriesMetadata.title = responseJSON["Title"].stringValue;
                
                // For every item in the series' alternate titles...
                for(_, currentAlternateTitle) in responseJSON["AlternativeTitles"].arrayValue.enumerate() {
                    // Add the current alternate title
                    seriesMetadata.alternateTitles.append(currentAlternateTitle.stringValue);
                }
                
                // For every item in the series' artists...
                for(_, currentArtist) in responseJSON["Artists"].arrayValue.enumerate() {
                    // Add the current artist
                    seriesMetadata.artists.append(currentArtist.stringValue);
                }
                
                // For every item in the series' writers...
                for(_, currentAuthor) in responseJSON["Authors"].arrayValue.enumerate() {
                    // Add the current author
                    seriesMetadata.writers.append(currentAuthor.stringValue);
                }
                
                // For evert item in the Covers array...
                for(_, currentCoverGroup) in responseJSON["Covers"].enumerate() {
                    // For every item the this cover group...
                    for(_, currentCover) in currentCoverGroup.1.enumerate() {
                        // If this is the front cover...
                        if(currentCover.1["Side"].stringValue == "front") {
                            // If there is a "Normal" object...
                            if(currentCover.1["Normal"].isExists()) {
                                // Add the current cover URL to the series metadata
                                seriesMetadata.coverURLs.append(NSURL(string: currentCover.1["Normal"].stringValue)!);
                            }
                            else {
                                // Use the full size "Raw" URL
                                seriesMetadata.coverURLs.append(NSURL(string: currentCover.1["Raw"].stringValue)!);
                            }
                        }
                    }
                }
                
                // For every item in the series' tags...
                for(_, currentTag) in responseJSON["Tags"].arrayValue.enumerate() {
                    // Add the current tag
                    seriesMetadata.tags.append(currentTag.stringValue);
                }
                
                // Set the volume count
                seriesMetadata.volumes = responseJSON["Volumes"].intValue;
                
                // Return the series metadata
                completionHandler(seriesMetadata, nil);
            }
        };
        
        // Return the series metadata
        return seriesMetadata;
    }
}

/// Holds metadata responses(Title and ID)
class KMMetadataInfo {
    /// The title of this manga
    var title : String = "";
    
    // The ID of this manga
    var id : Int = -1;
    
    /// Init with a title and ID
    init(title : String, id : Int) {
        self.title = title;
        self.id = id;
    }
}

/// Holds metadata for a series from MCD
class KMSeriesMetadata {
    /// The main title of this series
    var title : String = "";
    
    /// The alternate titles of this series(Like translated, Japanese, ETC.)
    var alternateTitles : [String] = [];
    
    /// All the artists for this series
    var artists : [String] = [];
    
    /// All the writers for this series
    var writers : [String] = [];
    
    /// The URLs to the compressed cover images
    var coverURLs : [NSURL] = [];
    
    /// All the tags of this series
    var tags : [String] = [];
    
    /// All the volumes that exist for this series
    var volumes : Int = 0;
    
    /// A blank init
    init() {
        
    }
}