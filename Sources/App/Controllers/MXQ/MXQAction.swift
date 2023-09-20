//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

enum TaskAction {
    case list
    case new
    case delete
    case add
}

enum MXQAction {
    case chat
    case help
    case task(TaskAction)
    case timesheet
    case clear
    case aiset
    case redeem
    
    init(m: String?) throws {
        guard let m = m, !m.isEmpty else {
            self = .chat
            throw Abort(.internalServerError, reason: "MXQ MXQAction is empty!!!")
        }
        
        switch CaseInsensitiveString(m) {
        case "帮助", "help":
            self = .help
        case "/任务列表":
            self = .task(.list)
        case let m where m.lowercaseString.hasPrefix("/填工时"):
            self = .task(.add)
        case let m where m.lowercaseString.hasPrefix("/创建任务"):
            self = .task(.new)
        case let m where m.lowercaseString.hasPrefix("/删除任务"):
            self = .task(.delete)
        case "/清除记忆":
            self = .clear
        case let m where m.lowercaseString.hasPrefix("/兑换码"):
            self = .redeem
        case let m where m.lowercaseString.hasPrefix("/人设"):
            self = .aiset
        default:
            self = .chat
        }
        
    }
}
