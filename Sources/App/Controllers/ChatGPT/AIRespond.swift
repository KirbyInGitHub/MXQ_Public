//
//  AIResponse.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

public protocol AIChoice: Content { }

struct AIResponse<T: AIChoice>: Content {
    let object: String?
    let model: String?
    let choices: [T]
}

struct AITextChoice: AIChoice, Content {
    let text: String
}

struct AIChatChoice: AIChoice, Content {
    public let message: AIContext.AISession
 }


