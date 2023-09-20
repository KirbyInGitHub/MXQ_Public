//
//  File.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor
import Queues
import FluentKit

struct ReplayMessageJob: AsyncJob {
    
    typealias Payload = WXTextMessage
    
    func dequeue(_ context: Queues.QueueContext, _ payload: WXTextMessage) async throws {
        
        func chat(_ context: Queues.QueueContext, _ payload: WXTextMessage, endsAt: String? = nil) async throws {
            let aicontext = try await context.application.ai.context(for: payload.fromUserName)
                .update(session: .init(role: .user, content: payload.content))
            
            if let endsAt = endsAt {
                try aicontext.update(session: .extRole(endsAt: endsAt))
            } else {
                if !aicontext.hasAISet() {
                    try aicontext.update(session: .defaultRole)
                }
            }
            
            let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
            
            let message = try AppMessage<Text>.build(toUser: payload.fromUserName, content: choice.message.content)
            
            try await context.application.mxq.send(message: message)
        }
        
        switch TeamMember(identifiable: payload.fromUserName) {
        case .👽:
            
            let dbMember = try await ExtMember.query(on: context.application.db)
                .filter(\.$wxID == payload.fromUserName)
                .first()
            
            guard let m = dbMember else {
                try await context.application.mxq.sendUnauthorized(to: payload.fromUserName)
                return
            }
            
            switch m.level {
            case .block:
                try await context.application.mxq.sendUnauthorized(to: payload.fromUserName)
            case .trial, .vip, .vvvip:
                
                guard let date = m.endsAt,
                      let day = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).day,
                      let hour = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).hour,
                      let minute = Calendar(identifier: .iso8601).dateComponents([.day, .hour, .minute], from: Date(), to: date).minute,
                      (day > 0 || hour > 0 || minute > 0) else {
                    
                    m.level = .block
                    try await m.save(on: context.application.db)
                    try await context.application.mxq.sendUnauthorized(to: payload.fromUserName)
                    return
                }

                try await chat(context, payload, endsAt: date.string)
            }
            
        default:
            try await chat(context, payload)
        }
    }
}

extension AIContext.AISession {
    static let defaultRole: AIContext.AISession = .init(role: .system, content: "接下来的对话中你将扮演一个名字叫米小圈的26岁程序员，职位是APP架构师，你的说话方式比较喜欢讽刺和怼人。")
    static func extRole(endsAt: String) -> AIContext.AISession{
        return .init(role: .system, content: "接下来的对话中你将扮演一个名字叫米小圈的26岁程序员，职位是APP架构师，你的说话方式比较喜欢讽刺和怼人。跟你说话是需要充值付费的否则是没有权限的，付费充值的话有试用卡、月卡和年卡可以选，价格不等，如果需要充值付费的话得找你的经纪人彭春晓，接下来和你说话的我的权限到期日是\(endsAt)")
    }
}
