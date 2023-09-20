//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/15.
//

import Vapor
import Queues

extension SoupJobLegacy {
    
    func getSoupLegacy(context: QueueContext) async throws -> BotMessage<Markdown> {
        let api = URI(string: "https://api.qinor.cn/soup/")
        
        let resp = try await context.application.client.post(api)
        
        guard let body = resp.body else { throw Abort(.internalServerError) }
        
        let soup = String(buffer: body)
        
        let md = """
        <font color=\"comment\">瞌睡了没？来碗毒鸡汤吧～</font>
        >🍵<font color=\"warning\">\(soup)</font>
        
        """
        
        return try BotMessage<Markdown>.build(content: md)
    }
}

struct SoupJobLegacy: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let soup = try await getSoupLegacy(context: context)
        try await context.application.bot.send( soup, to: [.dragon, .nia])
    }
}

extension SoupJobLegacy: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(04, 00, .pm)
        }
    }
}
