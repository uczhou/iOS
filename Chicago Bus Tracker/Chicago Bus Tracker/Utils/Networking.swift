
//
//  Networking.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/7/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import Reachability

/// - Networking: Used to handle all network related tasks
class Networking {
    
    static let sharedInstance = Networking()
    
    let apikey = "9sg3j2V9XJAbCezGZFU8U3Xxk"
    private init() {}
 
    /// - Check whether device has access to internet
    func isConnectionAvailabel() ->Bool {
        let reachability = Reachability()!
        if reachability.connection == Reachability.Connection.none {
            return false
        }else {
            return true
        }
    }
    
    /// - Retrieve data from CTA
    func getData(feedURL: String, completion:@escaping (CTAResponse?) -> Void) {
        // Transform the `feedURL` parameter argument to a `URL`
        print("Printing from getData: \(feedURL)")
        
        guard let url = NSURL(string: feedURL) else {
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
            
            self.parseJson(data: data){ (ctaResponse)  in
                completion(ctaResponse)
            }
            
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }
    
    /// Parse Json data
    func parseJson(data: Data, completion:@escaping (CTAResponse?) -> Void) {
        // Serialize the raw data into our custom structs
        print("----------Start parsing Json data-----------")
        do {
            // Covert JSON to `Topic`
            let decoder = JSONDecoder()
            let ctaResponse = try decoder.decode(CTAResponse.self, from: data)
            print(ctaResponse)
            print("-----------Finished parsing data------------")
            // Call the completion block closure and pass the News as argument to the completion block.
            completion(ctaResponse)
        } catch {
            print("Error serializing/decoding JSON: \(error)")
        }
        
    }
    
    /// - get CTA system time
    func getCTATime(completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/gettime?key=\(apikey)&format=json"
        //print(feedURL)
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get vehicle information of queried route
    func getVehiclesByRt(rt: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getvehicles?key=\(apikey)&rt=\(rt)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get vehicle information of queried vehicle id
    func getVehiclesByVid(vid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getvehicles?key=\(apikey)&vid=\(vid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get all routes information under operation.
    func getRoutes(completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getroutes?key=\(apikey)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get directions of queried route
    func getDirections(rt: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getdirections?key=\(apikey)&rt=\(rt)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get all stops of queried route
    func getStops(rt: String, dir: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getstops?key=\(apikey)&rt=\(rt)&dir=\(dir)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get patterns of queried route
    func getPatternsByRt(rt: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getpatterns?key=\(apikey)&rt=\(rt)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get patterns of queried pid
    func getPatternsByPid(pid: Int, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getpatterns?key=\(apikey)&pid=\(pid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get patterns of queried stpid
    func getPredictionsByStpid(stpid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getpredictions?key=\(apikey)&stpid=\(stpid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get predictions by stpid and rt
    func getPredictionsByStpidRt(rt: String, stpid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getpredictions?key=\(apikey)&rt=\(rt)&stpid=\(stpid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get predictions by vid
    func getPredictionsByVid(vid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getpredictions?key=\(apikey)&vid=\(vid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get service bulletins by rt
    func getServiceBulletinsByRt(rt: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getservicebulletins?key=\(apikey)&rt=\(rt)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get service bulletins by stpid
    func getServiceBulletinsByStpid(stpid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getservicebulletins?key=\(apikey)&stpid=\(stpid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get service bulletins by rt rtdir
    func getServiceBulletinsByRtRtdir(rt: String, rtdir: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getservicebulletins?key=\(apikey)&rt=\(rt)&rtdir=\(rtdir)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
    /// - get service bulletins by rt rtdir and stpid
    func getServiceBulletinsByRtRtdirStpid(rt: String, rtdir: String, stpid: String, completion:@escaping (CTAResponse?) -> Void) {
        let feedURL = "http://ctabustracker.com/bustime/api/v2/getservicebulletins?key=\(apikey)&rt=\(rt)&rtdir=\(rtdir)&stpid=\(stpid)&format=json"
        getData(feedURL: feedURL) { (ctaResponse) in
            completion(ctaResponse)
        }
    }
    
}
