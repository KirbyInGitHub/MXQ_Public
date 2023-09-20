//
//  EatJobV2.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor
import Queues

struct EatJob: AsyncScheduledJob {
    
    func makeMessage(with choice: AIChatChoice) throws -> ChatMessage<Markdown> {
        
        let emoji = ["🥪", "🥙", "🌮", "🌯", "🫕", "🍜", "🍲", "🍛", "🍱", "🥟"].randomElement()!
        
        let md = """
        <font color="comment">人是铁饭是钢，一顿不吃饿得慌。</font>
        
        >\(emoji)<font color=\"warning\">\(choice.message.content)</font>
        """

        return try ChatMessage<Markdown>.build(content: md)
    }
    
    func run(context: QueueContext) async throws {
        
        let aicontext = try await context.application.ai.context(for: "mi-eat")
            .update(session: .init(role: .system, content: "接下来的对话中你将扮演一个名字叫米小圈的26岁程序员，你天天加班到深夜，你的说话方式比较喜欢挖苦人。"))
            .update(session: .init(role: .user, content: "写一个50字以内的今天下午4点前预定加班餐的提醒，同时提醒同事们早点回家。"))
        
        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
        try await context.application.mxq.sendChat(makeMessage(with: choice))
    }
}

extension EatJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(03, 00, .pm)
        }
    }
}

struct DragonEatJob: AsyncScheduledJob {
    
    func makeMessage(with choice: AIChatChoice) throws -> BotMessage<Markdown> {
        
        let emoji = ["🥪", "🥙", "🌮", "🌯", "🫕", "🍜", "🍲", "🍛", "🍱", "🥟"].randomElement()!
        
        let md = """
        <font color="comment">人是铁饭是钢，一顿不吃饿得慌。</font>
        
        >\(emoji)<font color=\"warning\">\(choice.message.content)</font>
        """

        return try BotMessage<Markdown>.build(content: md)
    }
    
    func run(context: QueueContext) async throws {
        
        let aicontext = try await context.application.ai.context(for: "dragon-eat")
            .update(session: .init(role: .system, content: "接下来的对话中你将扮演一个名字叫斑点龙的26岁蛋糕店店长，你的同事们有鳄鱼米米、犀牛冲冲和刺猬阿兜，你们经常加班，你的说话方式比较喜欢挖苦人。"))
            .update(session: .init(role: .user, content: "写一个50字以内的今天下午4点前预定加班餐的提醒，同时提醒同事们早点回家。"))
        
        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
        try await context.application.bot.send(makeMessage(with: choice), to: [.dragon])
    }
}

extension DragonEatJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(03, 00, .pm)
        }
    }
}
