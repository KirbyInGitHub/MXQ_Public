//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/4/27.
//

import Vapor

struct AlertController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let reserve = routes.grouped("sentry")
        reserve.post("alert", use: alert)
    }
    
    func alert(req: Request) async throws -> String {
        
        guard let header = req.headers.first(name: "sentry-hook-resource") else { return "sentry-hook-resource is empty!!!" }

        let alert = try Alert(req: req)
        let md = try await alert.md()
        
        req.logger.info("md:\(md)\n")
        
        guard alert.resource != .installation || alert.resource != .comment else {
            return "ok"
        }
        
        switch alert.to {
        case .bot:
            let message = try BotMessage<Markdown>.build(content: md)
            try await req.application.bot.send(message, to: [alert.toBot])
            
        case .user:
            
            for u in alert.toUsers {
                let message = try AppMessage<Markdown>.build(toUser: u, content: md)
                try await req.application.mxq.send(message: message)
            }
            
        case .chat:

            let message = try ChatMessage<Markdown>.build(chatid: alert.toChat, content: md)
            
            try await req.application.mxq.sendChat(message)
            
        case .unknown: throw Abort(.internalServerError, reason: "Alert to")
        }
        
        return header
    }

}
