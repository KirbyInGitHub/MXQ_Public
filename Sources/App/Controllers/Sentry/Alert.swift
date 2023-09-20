//
//  Alert.swift
//  
//
//  Created by 张鹏 on 2023/5/5.
//

import Vapor

struct Alert {
    
    enum Level: String, Content {
        
        case error
        case issue
        case resolved
        case warning
        case critical
        case info
        case 🌀
    }
    
    enum Resource: String {
        case installation
        case event = "event_alert"
        case issue
        case metric = "metric_alert"
        case error
        case comment
    }
    
    enum To {
        case user
        case bot
        case chat
        case unknown
    }
    
    let req: Request
    let resource: Resource
    let to: To
    let toUsers: [String]
    let toBot: String
    let toChat: String
    
    init(req: Request) throws {
        guard let header = req.headers.first(name: "sentry-hook-resource"),
        let resource = Alert.Resource(rawValue: header) else { throw "sentry-hook-resource is empty!!!" }
        
        self.req = req
        self.resource = resource
        
        let users: String? = req.query["to_users"]
        let bot: String? = req.query["to_bot"]
        let chat: String? = req.query["to_chat"]

        toUsers = users?.components(separatedBy: ",") ?? []
        toBot = bot ?? ""
        toChat = chat ?? ""
        
        switch (toUsers.isEmpty, toChat.isEmpty, toBot.isEmpty) {
            case (true, true, true): to = .unknown
            case (false, _, _): to = .user
            case (true, false, _): to = .chat
            case (true, true, false): to = .bot
        }
        
        req.logger.info("req: \(req), users: \(toUsers), bot: \(toBot)")
    }
}

extension Alert {
    
    fileprivate func action() throws -> String {
        switch self.resource {
        case .installation, //created or deleted
                .event, //triggered
                .issue, //created, resolved, assigned, or ignored
                .metric, //critical, warning, resolved
                .error, //created
                .comment: //created, updated, or deleted
            return try self.req.content.get(at: ["action"])
        }
    }
    
    fileprivate func title() throws -> String {
        switch self.resource {
        case .installation: return ""
        case .event:
            return try req.content.get(at: ["data","event", "message"])
        case .issue:
            return try req.content.get(at: ["data","issue", "title"])
        case .metric:
            return try req.content.get(at: ["data","description_title"])
        case .error:
            return try req.content.get(at: ["data","error", "title"])
        case .comment: return ""
        }
    }
    
    fileprivate func culprit() throws -> String {
        switch self.resource {
        case .installation: return ""
        case .event:
            let desc: String = try req.content.get(at: ["data", "event", "culprit"])
            if desc.isEmpty {
                return try req.content.get(at: ["data", "triggered_rule"])
            }
            return desc
        case .issue:
            return try req.content.get(at: ["data", "issue", "culprit"])
        case .metric:
            let desc: String = try req.content.get(at: ["data", "description_text"])
            
            var descs = desc.components(separatedBy: " ")
    
            if let fisrt = descs.first, let value = Double(fisrt) {
                let d = value <= 1 ? String(format: "%.2f", value * 100.0) + "%" : String(format: "%.2f", value)
                descs.removeFirst()
                descs.insert(d, at: 0)
                
                return descs.joined(separator: " ")
            }
            
            return desc
        case .error:
            return try req.content.get(at: ["data", "error", "culprit"])
        case .comment: return ""
        }
    }
    
    fileprivate func url() throws -> String {
        switch self.resource {
        case .installation: return ""
        case .event:
            return try req.content.get(at: ["data","event", "web_url"])
        case .issue:
            return try req.content.get(at: ["data", "issue", "web_url"])
        case .metric:
            return try req.content.get(at: ["data", "web_url"])
        case .error:
            return try req.content.get(at: ["data", "error", "web_url"])
        case .comment: return ""
        }
    }
    
    fileprivate func level() throws -> Level {
        switch self.resource {
        case .installation: return .🌀
        case .event:
            let level: Level = try req.content.get(at: ["data", "event", "level"]) //error,issue
            return level
            
        case .issue:
            let level: Level = try req.content.get(at: ["data", "issue", "level"]) //error
            return level
            
        case .metric:
            let level: Level = try req.content.get(at: ["action"]) //critical, warning, resolved
            return level
            
        case .error:
            let level: Level = try req.content.get(at: ["data", "error", "level"]) //error
            return level
            
        case .comment: return .🌀
        }
    }
    
    fileprivate func project() throws -> String {
        switch self.resource {
        case .installation: return ""
        case .event:
            return "Event Alert"
            
        case .issue:
            return "Issue Alert"
            
        case .metric:
            return try req.content.get(at: ["data", "metric_alert", "projects", 0])
            
        case .error:
            return "Error Alert"
            
        case .comment:
            return "Comment Alert"
        }
    }
}

extension Alert {
    
    func md() async throws -> String {
        
        let l = try level()
        let t = try title()
        let c = try culprit()
        let u = try url()
        let p = try project()
        
        let md = """
        \(l.emoji) <font color="\(l.color)">\(t)</font>
        
        >项目：\(p)
        >描述：\(c)
        >[Sentry](\(u))
        """
        
        return md
    }
}

extension Alert.Level {
    
    var color: String {
        switch self {
        case .warning, .issue, .info: return "warning"
        case .critical, .error: return "warning"
        case .resolved: return "info"
        case .🌀: return ""
        }
    }
    
    var emoji: String {
        switch self {
        case .warning, .issue, .info: return "⚠️"
        case .critical, .error: return "💥"
        case .resolved: return "🎉"
        case .🌀: return "🌀"
        }
    }
}
