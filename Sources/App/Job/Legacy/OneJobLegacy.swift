//
//  File.swift
//  
//
//  Created by zhangpeng on 2020/12/16.
//

import Vapor
import Queues

extension OneJobLegacy {
    
    func getOneLegacy(context: QueueContext) async throws -> BotMessage<News> {
        
        let api = URI(string: "http://api.tianapi.com/txapi/one/index?key=23640564bf27019f20151e95132c9a52&date=\(Date().string)")
        
        let resp = try await context.application.client.get(api)
        
        let ones = try resp.content.get(Array<OneModel>.self, at: ["newslist"])
        
        guard let one = ones.first else { throw Abort(.internalServerError) }
        
        let items = [News.Item.init(title: one.date, description: one.word, url: one.imgurl, picurl: one.imgurl)]
        
        return try BotMessage<News>.build(content: items)
    }
}

struct OneJobLegacy: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        
        let one = try await getOneLegacy(context: context)
        try await context.application.bot.send( one, to: [.dragon, .nia])
    }
}

extension OneJobLegacy: JobCollection {
    
    static func boot(app: Application) {
        days.forEach { day in
            app.queues.schedule(Self.self())
                .using(Calendar.local)
                .weekly()
                .on(day)
                .at(09, 00, .am)
        }
    }
}
