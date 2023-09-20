//
//  AICommand.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

struct AICommand: Content {
    let prompt: String
    let model: String
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case model
        case maxTokens = "max_tokens"
        case temperature
    }
}
