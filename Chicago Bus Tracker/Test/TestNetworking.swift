//
//  TestNetworking.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/10/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

class TestNetworking {
    
    static let sharedInstance = TestNetworking()
    
    private init() {
        
    }
    
    var routes = [Route]()
    
    func testgetRoutes() {
        print("Testing getRoutes")
        // Do any additional setup after loading the view, typically from a nib.
        Networking.sharedInstance.getRoutes() {(ctaResponse) in
            if let ctaResponse = ctaResponse {
                if let busTracker = ctaResponse.bustime_response {
                    if let routes = busTracker.routes {
                        for route in routes {
                            self.routes.append(route)
                            print("RT: \(route.rt) RTNM: \(route.rtnm)  RTCLR: \(route.rtclr)")
                        }
                        print("getRoutes Test Succeeded")
                    }else {
                        print("Routes is empty")
                    }
                }
            }else {
                print("getRoutes Test Failed.")
            }
        }
    }
    
    func testgetCTATime() {
        print("Test getCTATime")
        Networking.sharedInstance.getCTATime() {(ctaResponse) in
            if let ctaResponse = ctaResponse {
                //print(ctaResponse)
                if let busTracker = ctaResponse.bustime_response {
                    if let systime = busTracker.tm {
                        print("Time is: \(systime)")
                        print("getCTATime Test Succeeded.")
                    }else {
                        print("Fail to retrieve time")
                    }
                }
            }else {
                print("getCTATime Test Failed.")
            }
        }
        
    }
}
