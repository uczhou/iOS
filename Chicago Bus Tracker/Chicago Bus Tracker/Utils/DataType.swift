//
//  DataType.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/8/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

/// - Custom all the data type used in app

enum OutboundDirection: String {
    case East = "Eastbound"
    case West = "Westbound"
    case North = "Northbound"
    case South = "Southbound"
    //static let allValues = [East, West, North, South]
}

struct CTAResponse: Codable {
    var bustime_response : BusTracker?
    
    enum CodingKeys: String, CodingKey
    {
        case bustime_response = "bustime-response"
    }
}

struct BusTracker: Codable {
    var error: [ErrorMessage]?
    var tm: String?
    var vehicle: [Vehicle]?
    var routes: [Route]?
    var directions: [Direction]?
    var stops: [Stop]?
    var ptr: [Pattern]?
    var prd: [Prediction]?
    var sb: [ServiceBulletin]?
}

struct ErrorMessage: Codable {
    var msg: String
    var rt: String?
    var vid: String?
    var dir: String?
    var pid: String?
}

struct Vehicle: Codable {
    var vid: String
    var tmstmp: String
    var lat: String
    var lon: String
    var hdg: String
    var pid: Int
    var rt: String
    var pdist: Int
    var des: String
    var dly: Bool
    var tablockid: String
    var tatripid: String
    var zone: String?
}

struct Route: Codable {
    var rt: String
    var rtnm: String
    var rtclr: String
}

struct Direction: Codable {
    var dir: String
}

struct Stop: Codable {
    var stpid: String
    var stpnm: String
    var lat: Double
    var lon: Double
}

struct Pattern: Codable {
    var pid: Int
    var ln: Int
    var rtdir: String
    var pt: [PatternDetail]
}

struct PatternDetail: Codable {
    var seq: Int
    var lat: Double
    var lon: Double
    var typ: String
    var stpid: String?
    var stpnm: String?
    var pdist: Int
}

struct Prediction: Codable {
    var tmstmp: String
    var typ: String
    var stpnm: String
    var stpid: String
    var vid: String?
    var dstp: Int
    var rt: String
    var rtdir: String
    var rtdd: String
    var des: String
    var prdtm: String
    var tablockid: String
    var tatripid: String
    var dly: Bool
    var prdctdn: String
    var zone: String?
}

struct ServiceBulletin: Codable {
    var nm: String
    var sbj: String
    var dtl: String
    var brf: String?
    var prty: String
    var srvc: [Service]?
}

struct Service: Codable {
    var rt: String
    var rtdir: String?
    var stpid: String?
    var stpnm: String?
}

struct RouteStops: Codable {
    var route: Route
    var dir: String
    var stops: [Stop]
    var favoriteStop: Stop
}

struct FileMetaData: Codable {
    var filename: String
}

struct NightMode: Codable {
    var nightMode: Bool
}

struct WifiOnly: Codable {
    var wifiOnly: Bool
}

struct RoutePrediction: Codable {
    var rtstp: RouteStops
    var timestamp: String
}

extension DefaultsKeys {
    static let initialLaunch = DefaultsKey<String?>("InitialLaunch")
    static let launchCount = DefaultsKey<Int>("launchCount")
}


