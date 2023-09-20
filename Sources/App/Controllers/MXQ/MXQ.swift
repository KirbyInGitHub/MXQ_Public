//
//  MXQ.swift
//  
//
//  Created by 张鹏 on 2023/3/16.
//

import Vapor

struct MXQ {
    
    let app: Application
    
    init(req: Request) {
        self.init(app: req.application)
    }
    
    init(app: Application) {
        self.app = app
    }
}

extension MXQ {
    
    enum MsgType {
        case text, markdown
    }
}

extension MXQ {
    
    public func send<C: MessageContent>(message: AppMessage<C>) async throws {
        
        guard !message.toUser.isEmpty else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        
        let token = try await getToken()
        
        let api = URI(string: "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=\(token)")
    
        let resp = try await app.client.post(api, content: message)
        
        app.logger.info("MXQ send message for: \(message.toUser) resp: \(resp)")
    }
    
    public func sendUnauthorized(to member: String) async throws {
        
        guard !member.isEmpty else {
            throw Abort(.internalServerError, reason: "MXQ Send Msg, user is empty!!!")
        }
        
        let m = """
        🖥 **你好，我是前台应用部的智能助理`米小圈`，当前无访问权限！**
        
        > <font color="warning">请联系我的经纪人`彭春晓`进行充值。</font>🤪
        """
        
        let message: AppMessage<Markdown> = try AppMessage.build(toUser: member, content: m)
        
        let token = try await getToken()
        
        let api = URI(string: "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=\(token)")
    
        let resp = try await app.client.post(api, content: message)
        
        app.logger.info("MXQ send message for: \(member) resp: \(resp)")
    }
}

extension MXQ {
    
    public func sendChat<C: MessageContent>(_ message: ChatMessage<C>) async throws {
        
        guard !message.chatid.isEmpty else {
            throw Abort(.internalServerError, reason: "MXQ Send chat msg, chatid is empty!!!")
        }
        
        let token = try await getToken()
        
        let api = URI(string: "https://qyapi.weixin.qq.com/cgi-bin/appchat/send?access_token=\(token)")
    
        let resp = try await app.client.post(api, content: message)
        
        app.logger.info("MXQ sendChat: \(resp)")
    }
}
