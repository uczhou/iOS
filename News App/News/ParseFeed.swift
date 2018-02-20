//
//  ParseFeed.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

class ParseFeed {
    
    /// Retrieve news stories and pass back a `News` object in the completion block `completion()`
    /// - Attributions: Assignment write-up
    /// - Parameter url: A `String` of the url
    /// - Parameter completion: A closure to run on the converted JSON
    func getNews(url: String, completion:@escaping (News?) -> Void) {
        
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
                // Covert JSON to `News`
                let decoder = JSONDecoder()
                let news = try decoder.decode(News.self, from: data)
                
                // Call the completion block closure and pass the News as argument to the completion block.
                completion(news)
            } catch {
                print("Error serializing/decoding JSON: \(error)")
            }
        })
        
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }
    
    /// Convert a `String` type time to `Date` type time
    /// - Attribution: https://stackoverflow.com/questions/42524651/convert-nsdate-to-string-in-ios-swift
    /// - Parameter dateString: A `String` of the time
    /// - Return: A `Date` type time
    func getReadableDate(dateString: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dateString)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let finalDate = calendar.date(from:components)!
        
        return finalDate
    }
    
    /// Convert a `Date` type time to `String`
    /// - Parameter date: A `Date` type time
    /// - Return: A `String` with "yyyy-MM-dd" format to represent the time
    func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /// Create URL String
    /// - Parameter hours: hours before current time
    /// - Parameter baseURL: base url
    /// - Parameter apiKey: api key used to query data
    /// - Return: A URL String with specified time and apiKey
    func getURL(hours: Double, baseURL: String, apiKey: String) -> String {
        let now = Date()
        let hour:TimeInterval = 3600.0
        let prev = now - hours*hour
        
        let nowString = self.getDateString(date: now)
        let prevString = self.getDateString(date: prev)
        return "\(baseURL)&from=\(prevString)&to=\(nowString)&sortby=popularity&apiKey=\(apiKey)"
    }
    
}
