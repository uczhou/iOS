//
//  SearchUtils.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/15/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import UIKit

class SearchUtils {
    
    // Static class variable
    static let sharedInstance = SearchUtils()
    
    /// This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    /// Retrieve news stories and pass back a `News` object in the completion block `completion()`
    /// - Attributions: Assignment write-up
    /// - Parameter url: A `String` of the url
    /// - Parameter completion: A closure to run on the converted JSON
    func getTopics(url: String, completion:@escaping (Topics?) -> Void) {
        startNetworking()
        // Transform the `url` parameter argument to a `URL`
        guard let url = NSURL(string: url) else {
            fatalError("Unable to create NSURL from string")
        }
        
        // Create a url session and data task
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                fatalError("Error: \(error!.localizedDescription)")
            }

            // Ensure there is data and unwrap it
            guard let data = data else {
                fatalError("Data is nil")
            }
            
            // Serialize the raw data into our custom structs
            do {
                // Covert JSON to `Topic`
                let decoder = JSONDecoder()
                let topics = try decoder.decode(Topics.self, from: data)

                // Call the completion block closure and pass the News as argument to the completion block.
                completion(topics)
            } catch {
                print("Error serializing/decoding JSON: \(error)")
            }
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        stopNetworking()
    }
    
    func startNetworking() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopNetworking() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
