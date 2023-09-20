//
//  AI.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

struct AI {
    let token: String = AiKey
    let app: Application
    
    init(req: Request) {
        self.init(app: req.application)
    }
    
    init(app: Application) {
        self.app = app
    }
}

extension AI {

    func sendCompletion(with prompt: String,
                        model: AIMode = .gpt3(.davinci),
                        maxTokens: Int = 2048,
                        temperature: Double = 1) async throws -> AIResponse<AITextChoice> {
        
        let endpoint = URI(string: AIEndpoint.completions.api)

        let command = AICommand(prompt: prompt, model: model.modelName, maxTokens: maxTokens, temperature: temperature)
        
        let resp = try await app.client.post(endpoint) { req in
            try req.content.encode(command, as: .json)
            
            let auth = BearerAuthorization(token: token)
            req.headers.bearerAuthorization = auth
        }
        
        return try resp.content.decode(AIResponse<AITextChoice>.self)
    }

    public func sendEdits(with instruction: String,
                          model: AIMode = .feature(.davinci),
                          input: String = "") async throws -> AIResponse<AITextChoice> {
        
        let endpoint = URI(string: AIEndpoint.edits.api)
        
        let instruction = AIInstruction(instruction: instruction, model: model.modelName, input: input)
        
        let resp = try await app.client.post(endpoint) { req in
            try req.content.encode(instruction, as: .json)
            
            let auth = BearerAuthorization(token: token)
            req.headers.bearerAuthorization = auth
        }
        
        return try resp.content.decode(AIResponse<AITextChoice>.self)
    }
    
    public func sendChat(with context: AIContext) async throws -> AIResponse<AIChatChoice> {
        
        let endpoint = URI(string: AIEndpoint.chat.api)
        
        let resp = try await app.client.post(endpoint) { req in
            try req.content.encode(context.output, as: .json)
            
            let auth = BearerAuthorization(token: token)
            req.headers.bearerAuthorization = auth
        }
        
        app.logger.info("AI sendChat resp:\(resp.status)")
        
        return try resp.content.decode(AIResponse<AIChatChoice>.self)
     }
}

extension AI {
    
    public func image(with prompt: String) async throws -> URI {
        let endpoint = URI(string: AIEndpoint.image.api)
        
        let content = ["prompt": prompt, "size": "512x512"]
        
        let resp = try await app.client.post(endpoint) { req in
            try req.content.encode(content, as: .json)
            
            let auth = BearerAuthorization(token: token)
            req.headers.bearerAuthorization = auth
        }
        
        let urlString: String = try resp.content.get(at: "data", 0, "url")
        
        app.logger.info("\(urlString)")
        
        return URI(string: urlString)
    }
}
