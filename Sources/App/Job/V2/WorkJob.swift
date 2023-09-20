//
//  WorkJob.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor
import Queues

struct WorkJob: AsyncScheduledJob {
    
    func makeMessage(with choice: AIChatChoice) throws -> ChatMessage<Markdown> {
        
        let md = """
        📃 <font color="info">米小圈搬砖日记 \(Date().string)</font>

        >\(choice.message.content)
        """
        
        return try ChatMessage<Markdown>.build(content: md)
    }
    
    func run(context: QueueContext) async throws {
        
        let aicontext = try await context.application.ai.context(for: "mi-diary")
            .update(session: .init(role: .system, content: "接下来的对话中你将扮演一个名字叫米小圈的26岁程序员，职位是APP架构师，你的死党是姜小牙，同事有铁头、徐豆豆、李黎、车驰，你的主管是魏主管，你的说话方式比较喜欢讽刺和怼人。"))
            .update(session: .init(role: .user, content: "今天的日期是\(Date().string)，写一个男主角叫米小圈的搬砖日记"))
        
        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
        try await context.application.mxq.sendChat(makeMessage(with: choice))
    }
}

extension WorkJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(02, 00, .pm)
        }
    }
}

struct DragonWorkJob: AsyncScheduledJob {
    
    func makeMessage(with choice: AIChatChoice) throws -> BotMessage<Markdown> {
        
        let md = """
        📃 <font color="info">斑点龙打工记 \(Date().string)</font>

        >\(choice.message.content)
        """
        
        return try BotMessage<Markdown>.build(content: md)
    }
    
    func run(context: QueueContext) async throws {
        
        let aicontext = try await context.application.ai.context(for: "dragon-diary")
            .update(session: .init(role: .system, content: "接下来的对话中你将扮演一个名字叫斑点龙的26岁蛋糕店店长，你的朋友们有鳄鱼米米、犀牛冲冲和刺猬阿兜，你的说话方式比较喜欢讽刺和怼人。"))
            .update(session: .init(role: .user, content: "今天的日期是\(Date().string)，写一个男主角叫斑点龙的打工日记"))
        
        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
        try await context.application.bot.send(makeMessage(with: choice), to: [.dragon])
    }
}

extension DragonWorkJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(02, 00, .pm)
        }
    }
}
