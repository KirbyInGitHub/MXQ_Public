//
//  AIMode.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

public enum AIMode: Content {
    case gpt3(GPT3)
    case codex(Codex)
    case feature(Feature)
    case chat(Chat)
    
    public var modelName: String {
        switch self {
        case .gpt3(let model): return model.rawValue
        case .codex(let model): return model.rawValue
        case .feature(let model): return model.rawValue
        case .chat(let model): return model.rawValue
        }
    }

    public enum GPT3: String, Content {
        case davinci = "text-davinci-003"
        case curie = "text-curie-001"
        case babbage = "text-babbage-001"
        case ada = "text-ada-001"
    }

    public enum Codex: String, Content {
        case davinci = "code-davinci-002"
        case cushman = "code-cushman-001"
    }
    
    public enum Feature: String, Content {
        case davinci = "text-davinci-edit-001"
    }

     public enum Chat: String, Content {
         case chatgpt = "gpt-3.5-turbo"
         case chatgpt0301 = "gpt-3.5-turbo-0301"
     }
}
