//
//  MXQController.swift
//  
//
//  Created by 张鹏 on 2023/2/24.
//

import Vapor
import XMLCoder
import FluentKit

struct MXQController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let tapd = routes.grouped("tapd")
        tapd.post("webhook", use: receivedTAPDWebhook)
        
        let wx = routes.grouped("wx")
        wx.post("message", use: receivedMessage)
        wx.get("message", use: serverVerify)
        
        let member = routes.grouped("member")
        member.post("add", use: addMember)
        member.post("redeem", use: redeem)

    }

    func serverVerify(req: Request) async throws -> String {
        req.logger.info("MXQController serverVerify requset:\(req)")

        let message = try req.query.decode(WXVerifyMessage.self)
        let crypt = try WXBizJsonMsgCrypt(sToken: SToken,
                                          sEncodingAESKey: SEncodingAESKey,
                                          sReceiveId: CorpID)

        let m = try crypt.decryptMsg(msgSignature: message.signature,
                                     timeStamp: message.timestamp,
                                     nonce: message.nonce,
                                     msgEncrypt: message.echostr ?? "")

        req.logger.info("MXQController serverVerify respond:\(m)")

        return m
    }
    
    func receivedMessage(req: Request) async throws -> ClientResponse {
        
        let verify = try req.query.decode(WXVerifyMessage.self)
        let crypt = try WXBizJsonMsgCrypt(sToken: SToken,
                                          sEncodingAESKey: SEncodingAESKey,
                                          sReceiveId: CorpID)
        
        let encryptMessage = try req.content.decode(WXEncryptMessage.self)
        
        let decryptMessage = try crypt.decryptMsg(msgSignature: verify.signature,
                                     timeStamp: verify.timestamp,
                                     nonce: verify.nonce,
                                     msgEncrypt: encryptMessage.encrypt)
        
        let message = try XMLDecoder().decode(WXMessage.self, from: Data(decryptMessage.utf8))
        
        switch message.msgType {
        case .event:
            let eventMsg = try XMLDecoder().decode(WXEventMessage.self, from: Data(decryptMessage.utf8))
            if eventMsg.event == "enter_agent" {
                if let _: Bool = try await req.cache.get("send-help-\(eventMsg.fromUserName)") {
                    return .init()
                } else {
                    try await help(for: req, to: eventMsg.fromUserName)
                    try await req.cache.set("send-help-\(eventMsg.fromUserName)", to: true, expiresIn: .days(1))
                    return .init()
                }
            }
        case .text:
            let content = try XMLDecoder().decode(WXTextMessage.self, from: Data(decryptMessage.utf8))
            let action = try MXQAction(m: content.content)
            
            req.logger.notice("perform action: \(action) for wx user:\(content.fromUserName)")
            
            switch action {
            case .help:
                try await help(for: req, to: content.fromUserName)
            case .task(_):
                try await req.queues(.mxq).dispatch(TAPDTasksJob.self, content)
            case .chat:
                try await req.queues(.mxq).dispatch(ReplayMessageJob.self, content)
            case .timesheet:
                return .init(status: .badRequest)
            case .clear:
                try await clear(for: req, to: content)
            case .aiset:
                try await aiset(for: req, to: content)
            case .redeem:
                try await redeem(for: req, to: content)
                
            }
        default:
            let message = try AppMessage<Text>.build(toUser: message.fromUserName, content: "暂时还不支持该消息类型！")
            try await req.application.mxq.send(message: message)
        }

        return .init()
    }
    
    func addMember(req: Request) async throws -> ClientResponse {
        let member = try req.content.decode(ExtMember.self)
        guard !member.wxID.isEmpty else {
            throw Abort(.badRequest, reason: "member.wxID isEmpty!!!")
        }
        try await member.save(on: req.db)
        return .init()
    }

}

extension MXQController {
    
    func help(for req: Request, to member: String) async throws {

        let teamMember = TeamMember(identifiable: member)
        
        switch teamMember {
        case .👽:
            let dbMember = try await ExtMember.query(on: req.db)
                .filter(\.$wxID == member)
                .first()
            
            guard let m = dbMember else {
                try await req.application.mxq.sendUnauthorized(to: member)
                return
            }
            
            switch m.level {
            case .block:
                try await req.application.mxq.sendUnauthorized(to: member)
            case .trial, .vip, .vvvip:
                guard let date = m.endsAt,
                      let day = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).day,
                      let hour = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).hour,
                      let minute = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).minute,
                      (day > 0 || hour > 0 || minute > 0) else {
                    
                    m.level = .block
                    try await m.save(on: req.db)
                    try await req.application.mxq.sendUnauthorized(to: member)
                    return
                }
                
                let md = """
                🖥 **你好，我是前台应用部的智能助理`米小圈`，当前支持功能清单：**
                
                > AI陪聊
                > 如需清除上下文： 发送 `/清除记忆`
                > 如需充值： 发送 `/兑换码 CODE`
                
                > <font color="warning">当前\(m.level == .trial ? "试用" : "会员有效")期还剩：\(day)天\(hour)小时\(minute)分钟，\(m.level == .trial ? "请及时充值" : "需要其他功能请加大充值力度。")。</font>🧐
                """
                
                let message = try AppMessage<Markdown>.build(toUser: m.wxID, content: md)
                try await req.application.mxq.send(message: message)
            }

        default:
            let m = """
            🖥 **你好，我是前台应用部的智能助理`米小圈`，当前支持功能清单：**
            
            > AI陪聊: 如需清除上下文： 发送 `/清除记忆`
            > TAPD任务清单：发送 `/任务列表`
            > TAPD任务工时填写：发送 `/填工时 任务名称(关键字、ID）+N`
            > TAPD任务创建（todo）：发送 `/创建任务 任务名称`
            
            > <font color="warning">需要其他功能请提需求或者自行开发。</font>🧐
            """
            
            let message = try AppMessage<Markdown>.build(toUser: teamMember, content: m)
            
            try await req.application.mxq.send(message: message)
        }
    }
}

extension MXQController {
    
    func clear(for req: Request, to content: WXTextMessage) async throws {
        try await req.ai.context(for: content.fromUserName).clear()
    }
}

extension MXQController {
    
    func aiset(for req: Request, to content: WXTextMessage) async throws {
        
        let aiset = content.content.replacingOccurrences(of: "/人设", with: "")
        
        try await req.ai.context(for: content.fromUserName)
            .update(session: .init(role: .system, content: aiset))
            .save()
    }
}

extension MXQController {
    
    func redeem(for req: Request, to content: WXTextMessage) async throws {
        let code = content.content.replacingOccurrences(of: "/兑换码", with: "").replacingOccurrences(of: " ", with: "")
        let resutl = try await VipCard.query(on: req.db).filter(\.$number == code).first()
        
        guard let card = resutl, !card.used else {
            let message = try AppMessage<Text>.build(toUser: content.fromUserName, content: "抱歉，兑换码无效，请核实后再试！")
            try await req.application.mxq.send(message: message)
            return
        }
        
        let member = try await ExtMember.query(on: req.db)
            .filter(\.$wxID == content.fromUserName)
            .first() ?? ExtMember(name: content.fromUserName, wxID: content.fromUserName, level: card.level)
        
        let endsAt: Date = {
            if let e = member.endsAt, e > Date() {
                return e
            }
            return Date()
        }()
        
        let level: ExtMember.Level = {
            switch (member.level, card.level) {
            case (.vvvip, _), (_, .vvvip) : return .vvvip
            case (.vip, .trial), (.vip, .vip), (.trial, .vip), (.block, .vip) : return .vip
            case (.block, .trial), (.trial, .trial) : return .trial
            case (_, .block) : return .block
            }
        }()
        
        let newEndsAt = endsAt + card.level.period.days
        
        member.endsAt = newEndsAt
        member.level = level
        
        do {
            try await member.save(on: req.db)
        } catch {
            let message = try AppMessage<Text>.build(toUser: member.wxID, content: "兑换码使用使用失败，请联系我的经纪人。")
            
            try await req.application.mxq.send(message: message)
        }
        
        card.used = true
        card.member = member.wxID
        try await card.save(on: req.db)
        
        let message = try AppMessage<Text>.build(toUser: member.wxID, content: "兑换码使用成功，会员有效期 +\(card.level.period)天。")
        
        try await req.application.mxq.send(message: message)
    }
    
    func redeem(for req: Request) async throws -> ClientResponse {
        let card = try req.content.decode(VipCard.self)
        guard !card.number.isEmpty else {
            throw Abort(.badRequest, reason: "vip card number isEmpty!!!")
        }
        try await card.save(on: req.db)
        return .init()
    }
}

