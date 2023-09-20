//
//  AIEndpoint.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

enum AIEndpoint {
    case completions
    case edits
    case chat
    case image
}

extension AIEndpoint {
    var api: String {
        switch self {
        case .completions:
            return "https://api.openai.com/v1/completions"
        case .edits:
            return "https://api.openai.com/v1/edits"
        case .chat:
             return "https://api.openai.com/v1/chat/completions"
        case .image:
            return "https://api.openai.com/v1/images/generations"
        }
    }
}
