//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor

let CorpID = Environment.get("corpID") ?? ""
let AgentID = Int(Environment.get("agentID") ?? "") ?? 0
let Corpsecret = Environment.get("corpsecret") ?? ""
let SToken = Environment.get("sToken") ?? ""
let SEncodingAESKey = Environment.get("sEncodingAESKey") ?? ""
let AiKey = Environment.get("aiKey") ?? ""
let ChatID = Environment.get("chatID") ?? ""

extension MXQ {
    
    func getToken() async throws -> String {
        
        let token = try await app.cache.get("token", as: String.self)
        
        if let t = token, !t.isEmpty {
            return t
        }
        
        let api = URI(string: "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=\(CorpID)&corpsecret=\(Corpsecret)")

        let resp = try await app.client.get(api)
        
        let t = try resp.content.get(String.self, at: ["access_token"])
        let e = try resp.content.get(Int.self, at: ["expires_in"])
        try await app.cache.set("token", to: t, expiresIn: .seconds(e))
        
        return t
    }
}
