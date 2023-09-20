//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

extension Application {
    var ai: AI {
        .init(app: self)
    }
}

extension AI {
    func getAITextChoice(content: String) async throws -> AITextChoice {

        let resp = try await sendCompletion(with: content)
        
        guard let r = resp.choices.first, !r.text.isEmpty else {
            throw Abort(.internalServerError, reason: "AI getAITextChoice isEmpty!!!")
        }
        
        return r
    }
}

extension AI {
    func getAIChatChoice(context: AIContext) async throws -> AIChatChoice {
        
        let resp = try await sendChat(with: context)
        
        guard let r = resp.choices.first, r.message.role == .assistant, !r.message.content.isEmpty else {
            throw Abort(.internalServerError, reason: "AI GetAIChatChoice isEmpty!!!")
        }
        
        try await context.update(session: .init(role: r.message.role, content: r.message.content)).save()
        
        return r
    }
}
