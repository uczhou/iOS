//
//  Topics.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/15/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

struct Topics: Codable {
    var RelatedTopics: [Topic]
}

struct Topic: Codable {
    var Text: String?
    var FirstURL: String?
    var Result: String?
}

