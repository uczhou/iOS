//
//  DataType.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

/// Hold the top level JSON
struct News: Codable {
    var status: String
    var totalResults: Int
    var articles: [Article]
}

/// Article data
struct Article: Codable {
    var title: String
    var author: String?
    var description: String?
    //var urlToImage: URL?
    var source: Source
    var url: URL
    var publishedAt: String
}

struct Source: Codable {
    var id: String?
    var name: String
}

/// Hold the top level JSON of stock information
struct Market: Codable {
    var status: MarketStatus
    var results: [Stock]
}

struct MarketStatus: Codable {
    var code: Int
    var message: String
}

/// Stock data
struct Stock: Codable {
    var symbol: String
    var exchange: String
    var name: String
    var dayCode: String
    var serverTimestamp: String
    var mode: String?
    var lastPrice: Double
    var tradeTimestamp: String
    var netChange: Double
    var percentChange: Double
    var unitCode: String
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var numTrades: Int?
    var dollarVolume: Double?
    var flag: String?
    var volume: Int
    var previousVolume: Int?
    var fiftyTwoWkHigh: Double
    var fiftyTwoWkHighDate: String
    var fiftyTwoWkLow: Double
    var fiftyTwoWkLowDate: String
}

