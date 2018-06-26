//
//  Sentence.swift
//  JobsPills
//
//  Created by Gabriel Tondin on 21/06/18.
//  Copyright © 2018 Gabriel Tondin. All rights reserved.
//

import Foundation

struct Sentence: Codable {
    let chapter: String
    let text: String
    let media: String
    let info: String
    let year: String
    
    private enum CodingKeys: String, CodingKey {
        case chapter = "Chapter"
        case text = "Text"
        case media = "Media"
        case info = "Info"
        case year = "Year"
        
    }
}
