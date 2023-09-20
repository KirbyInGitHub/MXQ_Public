//
//  StoryJobV2.swift
//  
//
//  Created by 张鹏 on 2023/2/25.
//

import Vapor
import Queues

struct StoryJob: AsyncScheduledJob {
    
    func makeMessage(with choice: AIChatChoice) throws -> BotMessage<Markdown> {
        
        let md = """
        📜 **<font color="warning">米小圈周游记</font>**
        
        >\(choice.message.content)
        """
        
        return try BotMessage<Markdown>.build(content: md)
    }
    
    func run(context: QueueContext) async throws {
        
//        let aicontext = try await context.application.ai.context(for: "mi-story")
//            .update(session: .init(role: .system, content: "接下来你将扮演一个名为米小圈的故事家，你比较喜欢讲你环游世界各个国家和城市的故事，一次只讲一个地方。"))
//            .update(session: .init(role: .user, content: "讲一个名为米小圈的男主角环游世界各个国家和城市的故事"))
//        
//        let choice = try await context.application.ai.getAIChatChoice(context: aicontext)
//        try await context.application.bot.send(makeMessage(with: choice), to: [.mi])
    }
}

extension StoryJob: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(11, 59, .am)
        }
    }
}
