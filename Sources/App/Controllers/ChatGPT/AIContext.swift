//
//  AISession.swift
//  
//
//  Created by 张鹏 on 2023/2/27.
//

import Vapor

extension AIContext {
    
    typealias Input = _Input
    typealias Output = _Output
    
    struct _Input: Content {
        fileprivate let sessions: [AISession]
        
        enum CodingKeys: String, CodingKey {
            case sessions = "messages"
        }
    }
    
    struct _Output: Content {
        let model: String
        fileprivate let sessions: [AISession]
        
        enum CodingKeys: String, CodingKey {
            case sessions = "messages"
            case model
        }
        
        init(model: String = AIMode.chat(.chatgpt).modelName, sessions: [AISession] = []) {
            self.model = model
            self.sessions = sessions
        }
    }
    
    var output: Output {
        .init(model: self.model, sessions: self.sessions)
    }
    
    var storage: Input {
        .init(sessions: self.sessions)
    }
}

final class AIContext: Identifiable {
    
    init(id: String, input: Input, app: Application) {
        self.id = id
        self.sessions = input.sessions
        self.app = app
    }
    
    struct AISession: Content {
        
        enum AIRole: String, Content {
             case system, user, assistant
        }
        
        let role: AIRole
        let content: String

        init(role: AIRole, content: String) {
            self.role = role
            self.content = content
        }
    }
    
    let model: String = AIMode.chat(.chatgpt).modelName
    let id: String
    let app: Application
    fileprivate var sessions: [AISession] = []

    fileprivate func append(session: AISession) {
        let count = self.sessions.reduce("") { $0 + $1.content }.count
        let newCount = session.content.count
        
        func remove(c: Bool) {
            if c && self.sessions.count > 2 {
                self.sessions.remove(at: 1)
                let count = self.sessions.reduce("") { $0 + $1.content }.count
                remove(c: (newCount + count) > 2000)
            }
        }
        
        remove(c: (newCount + count) > 2000)
        self.sessions.append(session)
    }
}

extension AI {

    func context(for id: String) async throws -> AIContext {
        let input = try await self.app.cache.get(id, as: AIContext.Input.self) ?? AIContext.Input(sessions: [])
        let context = AIContext(id: id, input: input, app: app)
        
        return context
    }
}

extension AIContext {

    @discardableResult
    func update(session: AIContext.AISession) throws -> Self {
        
        guard !session.content.isEmpty else {
            throw Abort(.internalServerError, reason: "update AIContext has no content")
        }

        switch session.role {
        case .system:
            sessions.removeAll { $0.role == .system }
            sessions.insert(session, at: 0)
        case .user ,.assistant:
            self.append(session: session)
        }
        return self
    }
    
    @discardableResult
    func save() async throws -> Self {
        try await app.cache.set(id, to: self.storage)
        
        return self
    }
    
    func clear() async throws {
        try await app.cache.delete(id)
    }
}

extension AIContext {
    
    func hasAISet() -> Bool {
        return self.sessions.contains(where: { $0.role == .system })
    }
}
